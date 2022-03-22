#include "protheus.ch"
#include "parmtype.ch"
#Include "FWMVCDef.ch"
/*/{Protheus.doc} User Function ITEM                                                      
    Atualiza cadastro de produto no SalesForce
	@type  Function
	@author Ricardo Lima
	@since 02/03/2018
	@version 01
	@history Everson, 18/10/2020, Chamado 18465. Envio de informações ao barramento.                                                  
/*/
User Function ITEM()
 
    Local aParam     := PARAMIXB
    Local oModel     := FwModelActive()
    Local cB1_XSALES := ""
    Local cB1_COD    := ""
    Local cNumero    := ""
    Local cOperacao  := ""
    Local nOperation := 0
    Local xRet       := .T.
         
    // VERIFICA SE APARAM NÃO ESTÁ NULO
    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
        nOperation  := oObj:GetOperation()
         
        //  VERIFICA SE O PONTO EM QUESTÃO É O FORMPOS
        If cIdPonto = "FORMCOMMITTTSPOS"
         
            // VERIFICA SE OMODEL NÃO ESTÁ NULO
            If oModel <> NIL
             
                cB1_XSALES := oModel:GetModel("SB1MASTER"):GetValue("B1_XSALES") // ATRIBUI VALOR A VARIÁVEL POR MEIO DO MODELO DE DADOS
                If FindFunction("U_ADVEN069P") .And. cB1_XSALES == "2"
                    xRet := .T.
                    cB1_COD := oModel:GetModel("SB1MASTER"):GetValue("B1_COD")
                    U_ADVEN069P( Alltrim(cB1_COD) , .F. )
                EndIf
                 
            EndIf
             
        ElseIf cIdPonto == "MODELCOMMITNTTS" .And. oModel <> NIL //Everson, 18/10/2020, Chamado 18465.

            cNumero := oModel:GetModel("SB1MASTER"):GetValue("B1_COD")

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

Return xRet
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

	U_ADFAT27C("SB1", 1, "cadastro_de_produtos_protheus", cOperacao, FWxFilial("SB1") + cNumero)

    RestArea(aArea)

Return Nil
