#include 'rwmake.ch'

/*/{Protheus.doc} User Function MA020TOK
	PE no Ok do cadastro de Fornecedor
	@type  Function
	@author Ana Helena
	@since 28/12/2010
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history ticket 39 - FWNM - 12/11/2020 - Projeto RM
/*/
User Function MA020TOK()   
                       
	Local _lRetCGC := .F. 

	If M->A2_EST = 'EX'
		_lRetCGC := .T.	
	Else
		If Empty(M->A2_CGC)
			_lRetCGC := .F.
		Else
			_lRetCGC := .T.	
		Endif
	Endif

	If !_lRetCGC
		Alert("Campo CGC é obrigatorio - PE MA020TOK")
	Endif     

	//Chamado 032707 - WILLIAM COSTA 02/09/2017
	IF _lRetCGC
		
		IF ALLTRIM(M->A2_LOCAL) <> '' .AND. ;
			(ALLTRIM(M->A2_XTIPO) == '1' .OR. ALLTRIM(M->A2_XTIPO) == '2')
			
			DBSELECTAREA("NNR")
			NNR->(DBSETORDER(1))
			NNR->(DBGOTOP())
			IF !DBSEEK(xfilial("NNR") + ALLTRIM(M->A2_LOCAL))
				
				RecLock("NNR",.T.)  
				
					NNR->NNR_FILIAL	:= xFilial("NNR")
					NNR->NNR_CODIGO	:= ALLTRIM(M->A2_LOCAL)
					NNR->NNR_DESCRI	:= IIF(ALLTRIM(M->A2_XTIPO) == '1','INCUBATORIO-','INTEGRADO-') + ALLTRIM(M->A2_LOCAL)
					NNR->NNR_TIPO	:= '1'
						
				NNR->( MsUnLock() ) 
				
				MsgINFO("Olá " + Alltrim(cusername) + ", Local de Armazém Criado: " + ALLTRIM(M->A2_LOCAL), "MA020TOK - Criação de Almoxarifado")
							
			ENDIF
				
			NNR->( DBCLOSEAREA() )  
			
				
		ENDIF

	ENDIF            

	// Ticket 39 - Projeto RM - FWNM - 12/11/2020
	If AllTrim(M->A2_XRM) == "S" 
	
		// Obriga preenchimento do campo informativo
		If Empty(AllTrim(M->A2_XRMFUNC))
		
			_lRetCGC := .f.
			Alert("Obrigatório informar o número da coligada, chapa e do funcionário/pensionista quando integra RM = Sim")
			Return _lRetCGC

		EndIf

		// Consiste fornecedor RM
		If _lRetCGC

			If Upper(Left(AllTrim(M->A2_COD),1)) <> "F"

				_lRetCGC := .f.
				Alert("Fornecedores que integram RM precisam ter o código iniciando com F")
				Return _lRetCGC

			EndIf

		EndIf

		// Consiste fornecedor RM
		If _lRetCGC

			If Len(AllTrim(M->A2_COD)) <> TamSX3("A2_COD")[1]

				_lRetCGC := .f.
				Alert("Fornecedores que integram RM precisam ter 6 caracteres e iniciar com F")
				Return _lRetCGC

			EndIf

		EndIf

	Else

		If Upper(Left(AllTrim(M->A2_COD),1)) == "F"

			_lRetCGC := .f.
			Alert("Fornecedores que NÃO integram RM NÃO podem ter o código iniciando com F")
			Return _lRetCGC

		EndIf

	EndIf
	//    
             
Return(_lRetCGC)
