#include "protheus.ch"
#include "parmtype.ch"
/*
// ##########################################################################################
// Modulo : SIGAFIN
// Fonte  : ITEM
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/03/18 | Ricardo Lima      | Atualiza cadastro de produto no SalesForce | 
// ---------+-------------------+--------------------------------------------+---------------
//          |                   |                                            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
*/

User Function ITEM()
 
    Local aParam := PARAMIXB
    Local oModel := FwModelActive()
    Local cB1_XSALES := ""
    Local cB1_COD := ""
    Local xRet := .T.
         
    // VERIFICA SE APARAM NÃO ESTÁ NULO
    If aParam <> NIL
        oObj := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid := (Len(aParam) > 3)
         
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
             
        EndIf
     
    EndIf

Return xRet