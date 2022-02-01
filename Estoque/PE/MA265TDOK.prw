#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.ch'

/*/{Protheus.doc} User Function MA265TDOK
	Ponto de entrada para tratar a validacao dos campos de enderecar produtos MATA265
	@type  Function
	@author William Costa
	@since 08/05/2018
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 62276 - Fernando Macieira - 13/10/2021 - Endere�amento autom�tico - Armaz�ns de terceiros 70 a 74
	@history Ticket 62276 - Fernando Macieira - 06/12/2021 - Endere�amento autom�tico - Armaz�ns de terceiros 70 a 74 - Projeto Industrializa��o - Alguns casos o EXECAUTO retorna ERRO
	@history Ticket 67479 - Fernando Macieira - 01/02/2022 - Endere�amento produto 383104 - Retorno Coopeval
/*/
USER FUNCTION MA265TDOK()
	
	Local lRet        := .T.
	Local nCont       := 0
	Local nPosLocaliz := 0
	Local nPosData    := 0
	Local nEstorno    := 0
	
	nPosLocaliz := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_LOCALIZ" } )
	nPosData    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_DATA" 	 } )
	nEstorno    := Ascan( aHeader, { |x| Alltrim( x[2] ) == "DB_ESTORNO" } )
	
	FOR nCont:=1 TO LEN(aCols)
	
		IF aCols[nCont][nEstorno] <> 'S' //Regra para validar somente a linha que n�o tem estorno
		
			If IsInCallStack("u_CHKSDA") .or. IsInCallStack("u_UpSDASDB") // @history Ticket 67479 - Fernando Macieira - 01/02/2022 - Endere�amento produto 383104 - Retorno Coopeval

				lRet := .t.

			Else

				IF aCols[nCont][nPosData] <> M->DA_DATA   
				
					MsgStop("OL� " + Alltrim(cUserName) + ", S� � permitido endere�ar produto com a mesma data da entrada", "MA265TDOK-02 - VALIDA ENDERE�AMENTO")
					lRet        := .F.
					
				ENDIF

			EndIf
			
		ENDIF
	NEXT

RETURN(lRet)
