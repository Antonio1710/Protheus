#Include  'Protheus.ch' 

/*/{Protheus.doc} User Function M310PPED
	Ponto de Entrada para realizar a liberacao de pedido bloqueado por estoque
    na transferencia entre filiais
	@type  Function 
	@author Andre Mendes - Obify
	@since  28/04/21 
	@version 01
    @history Chamado 8566 	- André Mendes 	        - 29/04/2021 - Transferência entre Filiais
    @history Chamado 14436 	- Leonardo P. Monteiro 	- 20/05/2021 - Correção de error.log gerado na liberação automática no SB9.
/*/

User Function M310PPED() 

    Local aPvlNfs   := {}
    Local aBloqueio := {{"","","","","","","",""}}
    Local nI
	
    Private _nQtdLiber := 0
	Private lLiber	 := .F.
	Private	lTrans	 := .F.
	Private	lCredito := .T.
	Private	lEstoque := .T.
	Private	lAvCred	 := .F.
	Private	lAvEst	 := .F.

    // Liberacao de pedido
    Ma410LbNfs(2,@aPvlNfs,@aBloqueio)
    // Checa itens liberados
    Ma410LbNfs(1,@aPvlNfs,@aBloqueio)

    If !(Empty(aBloqueio) .And. !Empty(aPvlNfs))
  
        for nI := 1 to Len(aBloqueio)
           
            IF SC6->(DbSeek(xFilial('SC6')+aBloqueio[nI][01]+aBloqueio[nI][02]+aBloqueio[nI][04]))
                if dbseek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
                    //SC6->(MaLiberOk({SC5->C5_NUM},.T.))
					//@history Chamado 14436 	- Leonardo P. Monteiro 	- 20/05/2021 - Correção de error.log gerado na liberação automática no SB9.
                    If empty(SC9->C9_BLCRED)   //somente se ja não houver bloqueio
						Reclock("SC9",.F.)
						SC9->C9_BLEST := ""
                        SC9->C9_BLCRED := ""
                        MsUnlock("SC9")
                    ENDIF
                    
                ELSE
                    //@history Chamado 14436 	- Leonardo P. Monteiro 	- 20/05/2021 - Correção de error.log gerado na liberação automática no SB9.
                    IF VALTYPE(aBloqueio[nI][05]) == "C"
                        _nQtdLiber := val(aBloqueio[nI][05])
                    else
                        _nQtdLiber := aBloqueio[nI][05]
                    ENDIF
                    MaLibDoFat( SC6->( Recno() ), @_nQtdLiber, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
                
                ENDIF  
            ENDIF
            
        next

    Endif

Return

