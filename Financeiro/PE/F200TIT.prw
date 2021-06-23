#Include "Protheus.ch"

/*/{Protheus.doc} User Function F200TIT
	PE executado na recepcao do arqruivo cnab
	@type  Function
	@author Everaldo Casaroli
	@since 27/12/2007
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
/*/
USER FUNCTION F200TIT()

	Local _aArea   := GetArea()      

	// @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
	Local aAreaSE1 := SE1->( GetArea() ) 
	Local cIDCNAB  := cNumTit
	//

	If SE1->( !EOF() ) // @history ticket 745 - FWNM - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado

		If !Empty(AllTrim(cIDCNAB))

			SE1->( dbSetOrder(19) ) // E1_IDCNAB
			If SE1->( dbSeek(cIDCnab) )

				IF ALLTRIM(SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO))==ALLTRIM(SE5->(E5_CLIFOR + E5_LOJA + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO))
				
					RecLock( "SE1", .F. )
						SE1->E1_PORTADO 	:= SE5->E5_BANCO
						SE1->E1_AGEDEP		:= SE5->E5_AGENCIA
						SE1->E1_CONTA		:= SE5->E5_CONTA
					SE1->( MsUnlock() )
			
				ENDIF

				//Inicio: 14/02/2017 - Fernando Sigoli Chamado:033013
				//E1_XDTDISP - campo utilizado no relatorio de conciliação financeira
				While SE5->( !Eof() ) .and. SE1->E1_PREFIXO = SE5->E5_PREFIXO .and. SE1->E1_NUM = SE5->E5_NUMERO .and. SE1->E1_PARCELA = SE5->E5_PARCELA .and. SE5->E5_BANCO <> '' .and. SE5->E5_TIPO = 'NF';
							.and. SE1->E1_CLIENTE = SE5->E5_CLIFOR .and. SE1->E1_LOJA = SE5->E5_LOJA
								
						If !EMPTY(SE1->E1_BAIXA).and. EMPTY(SE1->E1_XDTDISP)  //.and. SE1->E1_TIPO = 'AB-'    
							RecLock("SE1",.F.)
								Replace E1_XDTDISP With SE5->E5_DTDISPO
							SE1->( MsUnlock() )
						EndIF
						
					SE5->( DbSkip() )
				Enddo
				//Fim: 14/02/2017 - Fernando Sigoli Chamado:033013

			EndIf
		
		EndIf
	
	EndIf
	
	RestArea( _aArea )
	RestArea( aAreaSE1 )

RETURN
