#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#Include "FWMVCDef.ch"
STATIC nCont       := 0
STATIC cCodStatic  := ''    
STATIC cLojaStatic := ''
STATIC lRetAnexo   := .T.
/*/{Protheus.doc} User Function CUSTOMERVENDOR                                                      
	Programa revisado no chamado 050013 por Adriano Savoine,esse
	programa libera os campos na SA2 apos validar na ADCOM027P   
	foi verificado que o mesmo após inserir o anexo não validava 
	novamente as informações por considerar diferente o cliente  
	anterior visto para a nova consulta e quando é o mesmo não   
	verificava.
	@type  Function
	@author Ricardo Lima
	@since 17/01/2019
	@version 01
	@history Everson, 13/10/2020, Chamado 2607. Tratamento para atualizar as informações de nome e nome reduzido no cadastro de transportadora.                                                  
	@history Everson, 18/10/2020, Chamado 18465. Envio de informações ao barramento.                                                  
/*/
User Function CUSTOMERVENDOR()

    Local aParam     := PARAMIXB
    Local lRet       := .T.
    Local oObj       := ""
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local lIsGrid    := .F.
    Local cCod       := ''    
    Local cLoja      := ''
	Local oModel     := FwModelActive()
	Local cNumero	 := ""
	Local cOperacao	 := ""
	Local nOperation := 0	
    
    If aParam <> NIL
    
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := (Len(aParam) > 3)
		nOperation  := oObj:GetOperation()

        IF cIdPonto   == "FORMPRE"     .AND. ;
			cIdModel  == "SA2MASTER"   .AND. ;
			aParam[4] == "CANSETVALUE" .AND. ;
			oObj:OFORMMODEL:noperation == 4
			cCod  := oObj:ADATAMODEL[1][2][2]  
			cLoja := oObj:ADATAMODEL[1][3][2]
			cUserFinanceiro := ''
			cUserFinanceiro := CarUsuFin()
				
			IF __cUserId $ cUserFinanceiro
	
				SqlAnexos(cCod,cLoja)
					
				IF !TRC->(EOF()) //Se existe anexo deixa entrar no fornecedor adicionado no codigo para correção do chamado: 050013 por Adriano Savoine 23/07/2019;

							lRetAnexo   := .T.
							nCont       := 0
							cCodStatic  := cCod    
							cLojaStatic := cLoja					

					END   
					TRC->(dbCloseArea())
				ENDIF

				IF cCodStatic  <> cCod    
					cLojaStatic <> cLoja	
					lRetAnexo   := .T.
					nCont       := 0
					cCodStatic  := cCod    
					cLojaStatic := cLoja
				ENDIF
            
                nCont:= nCont + 1 
                
                IF lRetAnexo == .F.
            
            	Return(lRetAnexo) // para retornar Falso para todos quando acontecer.
            
            ENDIF   
            
            IF nCont == 1
                
				cUserFinanceiro := ''
				cUserFinanceiro := CarUsuFin()
				
				IF __cUserId $ cUserFinanceiro
			
					SqlAnexos(cCod,cLoja)
					
					IF TRC->(EOF()) //Se não existe anexo não deixa entrar no fornecedor
					
						MsgStop("OLÁ " + Alltrim(cUserName) + ", Fornecedor sem anexo, impossivel continuar, se faz necessário informar os anexos antes.", "CUSTOMERVENDOR-01")
						lRet      := .F. 
						lRetAnexo := .F.  
				
						END   
						TRC->(dbCloseArea())
				
					ENDIF
				
				ENDIF
        
        ENDIF

		//Everson - 13/10/2020. Chamado 2607.
		If cIdPonto == "MODELCOMMITNTTS"
			autSA4(SA2->A2_CGC,Alltrim(SA2->A2_NOME),Alltrim(SA2->A2_NREDUZ))

			//Everson, 18/10/2020, Chamado 18465.
			If oModel <> NIL

				cNumero := oModel:GetModel("SA2MASTER"):GetValue("A2_COD")

				If nOperation == MODEL_OPERATION_INSERT
					cOperacao := "I"

				ElseIf nOperation == MODEL_OPERATION_UPDATE
					cOperacao := "A"

				ElseIf nOperation == MODEL_OPERATION_DELETE
					cOperacao := "D"

				EndIf

				If ! Empty(cOperacao) .And. ! Empty(cNumero)
					grvBarr(cOperacao, cNumero)

				EndIf

			EndIf
			
		EndIf
		//
        
    ENDIF

Return(lRet)
/*/{Protheus.doc} CarUsuFin
	
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
STATIC FUNCTION CarUsuFin()

	Local cRet := ''
	
	SqlUsuFin()
	While TRB->(!EOF())

        cRet := cRet + TRB->PB1_CODIGO + '/'
        
		TRB->(dbSkip())
	ENDDO
	TRB->(dbCloseArea())

RETURN(cRet)
/*/{Protheus.doc} CarUsuFin
	
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
STATIC FUNCTION SqlUsuFin()

	BeginSQL Alias "TRB"
		%NoPARSER%  
			SELECT PB1_CODIGO,PB1_NOME,PB1_NIVEL 
			FROM %TABLE:PB1%
			WHERE PB1_FILIAL  = ''
				AND PB1_NIVEL  >= '4'
				AND PB1_NIVEL  <= '6'
				AND D_E_L_E_T_ <> '*'
			ORDER BY PB1_NIVEL
	EndSQl             

RETURN(NIL)
/*/{Protheus.doc} CarUsuFin
	
	@type  Static Function
	@author user
	@since 
	@version 01
	/*/
STATIC FUNCTION SqlAnexos(cCod,cLoja)

	BeginSQL Alias "TRC"
		%NoPARSER%  
			SELECT AC9_CODENT,AC9_CODOBJ
			FROM %TABLE:AC9%
			WHERE AC9_FILIAL = ''
				AND AC9_ENTIDA = 'SA2'
				AND LEFT(AC9_CODENT,6) = %EXP:cCod%
				AND RIGHT(RTRIM(AC9_CODENT),2) = %EXP:cLoja%
				AND D_E_L_E_T_ <> '*'
			
				ORDER BY AC9_CODENT
	EndSQl             
    
RETURN(NIL)  
/*/{Protheus.doc} autSA4
	Atualiza o cadastro de transportadora.
	@type  Static Function
	@author Everson
	@since 13/10/2020
	@version 01
	/*/
Static Function autSA4(cCGC,cNome,cNmRdz)

	//Variáveis.
	Local aArea	:= GetArea()

	//
	DbSelectArea("SA4")
	SA4->(DbSetOrder(3))
	If SA4->(DbSeek( FWxFilial("SA4") + cCGC))
		RecLock("SA4",.F.)
			SA4->A4_NOME   := cNome
			SA4->A4_NREDUZ := cNmRdz
		SA4->(MsUnlock())
	EndIf

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} grvBarr
    Salva o registro para enviar ao barramento.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function grvBarr(cOperacao, cNumero)

    //Variáveis.
    Local aArea := GetArea()

	U_ADFAT27C("SA2", 1, "cadastro_de_fornecedores_protheus", cOperacao, FWxFilial("SA2") + cNumero)

    RestArea(aArea)

Return Nil
