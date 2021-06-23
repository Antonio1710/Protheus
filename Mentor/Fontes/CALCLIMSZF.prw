#INCLUDE "PROTHEUS.CH"                                              
	
User Function CALCLIMSZF(_cCodRede,cNomeRede,cTipoRede)

Local _nLimRede   := 0
Local nLimiteAprv := M->PB3_LIMAPR   && Chamado 032248 Sigoli 11/01/2016 
Local lRede  	  := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If !Empty(_cCodRede)
		
		DbSelectArea("PB3")
		nOrden = IndexOrd()           
		nRecno := Recno()
		DbSetOrder(13)
		
		If PB3->( DbSeek( xFilial('PB3')+ _cCodRede))
	    	lRede := .F.
			While !PB3->( EOF()) .AND. alltrim(PB3->PB3_CODRED) = alltrim(M->PB3_CODRED)
				IF PB3->PB3_BLOQUE = '2'
						lRede := .T.       //existe loja ativa na rede
				EndIF
			PB3->( DbSkip() )
			Enddo
		
		Else
			lRede := .T.   //sigoli 01/06/2017 Chamado: 035009		
		EndIF		
		  	
	  	DbSelectArea("PB3")
		DbSetOrder(nOrden)
		DbGoto(nRecno)  
		
	EndIf
	                       
	IF UPPER(ALLTRIM(cTipoRede)) <> 'A' //LIMITES DIFERENTES DE ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA
	
		DbSelectArea( 'SZF' )
		dbGoTop()
		DbSetOrder( 3 )
		If SZF->( DbSeek( xFilial('SZF') + _cCodRede))
			While !Eof() .and. SZF->ZF_REDE == _cCodRede
				_nLimRede += SZF->ZF_LCREDE
			SZF->(dbSkip())
			Enddo                
	    Else  && Chamado 032248 Sigoli 11/01/2016 
	        If nLimiteAprv > 0
	        	_nLimRede :=  nLimiteAprv
	    	EndIF
	    Endif
	ELSE // LIMITES COM ASSOCIACAO COMERCIAL CHAMADO 022332 - WILLIAM COSTA	                                      
	
		DbSelectArea( 'SZF' )
		dbGoTop()
		DbSetOrder( 2 )
		If SZF->( DbSeek( xFilial('SZF') + cNomeRede))
		
			_nLimRede += SZF->ZF_LCREDE
	  
		Else && Chamado 032248 Sigoli 11/01/2016 
	    
	        If nLimiteAprv > 0
	        	_nLimRede :=  nLimiteAprv
	    	EndIF
	   	
	   	EndIF //FECHA IF
		
	ENDIF //FECHA IF  
	DBCLOSEARE("SZF")
	//inicio reposicionar SZF CHAMADO 022332 - WILLIAM COSTA
	
	IF UPPER(ALLTRIM(SZF->ZF_TPREDE)) <> 'A'
		DbSelectArea("SZF")
		dbGoTop()
		DbSetOrder(3)   //WILLIAM COSTA AQUI ELE SOMA O LIMITE NA TELA DE CREDITO APROVADO CHAMADO 022332
		If SZF->( DbSeek( xFilial("SZF")+_cCodRede))   
		
	    ENDIF
	ENDIF
	
	//Final reposicionar SZF CHAMADO 022332 - WILLIAM COSTA
	
	IF lRede == .F.
	   MsgAlert("Todas as lojas da rede estão inativas. Limite inicial zero")
		_nLimRede := 0
	EndIF

Return(_nLimRede)