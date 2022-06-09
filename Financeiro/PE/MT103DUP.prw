#include "totvs.ch"

/*/{Protheus.doc} User Function MT103DUP
    permite manter ou não o Acols com as datas de vencimentos e valores de duplicatas quando for efetuada a confirmação para a gravação da nota fiscal.
    As validações dos Acols, deverá ser retornada através do Ponto de Entrada que poderá utilizar os parâmetros enviados para tais validações.
    As validações existentes nos parâmetros: MV_CONFDUP, MV_LIMPAG e MV_LIMREC continuam inalteradas e funcionando normalmente.
    Essa PE não fornece  o conteúdo digitado pelo usuário (datas de vencimentos digitadas)
    @type  Function
    @author Fernando Macieira
    @since 08/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 74270 - Criar trava no sistema para impedir lançamentos de titulos vencidos
/*/
User Function MT103DUP()

    Local lRet     := .F. // .T. = NÃO PERMITE / .F. = PERMITE (alterar a aba duplicatas)
    Local aDupAtu  := ParamIxb[1]  
    Local aDupNew  := ParamIxb[2]
    Local i, ii
    
    // Validações Novo Conteúdo
    For i:=1 to Len(aDupNew)
        If aDupNew[i,1] <= msDate()
            lRet := .t.
            Alert("[MT103DUP-01] - Inclusão de título vencido não permitido! As nova condição de pagamento informada não será modificada...")
            Return lRet
        EndIf
    Next i

    // Validações conteúdo originals
    For ii:=1 to Len(aDupAtu)
        If aDupAtu[ii,2] <= msDate()
            lRet := .t.
            Alert("[MT103ATU-02] - Inclusão de título vencido não permitido! Verifique a condição de pagamento/database utilizada...")
            Return lRet
        EndIf
    Next ii

Return lRet
