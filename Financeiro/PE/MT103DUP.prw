#include "totvs.ch"

/*/{Protheus.doc} User Function MT103DUP
    permite manter ou n�o o Acols com as datas de vencimentos e valores de duplicatas quando for efetuada a confirma��o para a grava��o da nota fiscal.
    As valida��es dos Acols, dever� ser retornada atrav�s do Ponto de Entrada que poder� utilizar os par�metros enviados para tais valida��es.
    As valida��es existentes nos par�metros: MV_CONFDUP, MV_LIMPAG e MV_LIMREC continuam inalteradas e funcionando normalmente.
    Essa PE n�o fornece  o conte�do digitado pelo usu�rio (datas de vencimentos digitadas)
    @type  Function
    @author Fernando Macieira
    @since 08/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 74270 - Criar trava no sistema para impedir lan�amentos de titulos vencidos
    @history ticket 75023 - Fernando Macieira - 20/06/2022 - Condi��o de Pagamento de Titulos
/*/
User Function MT103DUP()

    Local lRet     := .F. // .T. = N�O PERMITE / .F. = PERMITE (alterar a aba duplicatas)
    Local aDupAtu  := ParamIxb[1]  
    Local aDupNew  := ParamIxb[2]
    Local i, ii
    Local lVencDayOk := GetMV("MV_#E2VENC",,.t.)

    // @history ticket 75023 - Fernando Macieira - 20/06/2022 - Condi��o de Pagamento de Titulos
    Public lMT103DUP  := .f. // Vari�vel ser� usada no MT100TOK para consistir o conte�do do acols/folder duplicata
    
    // Valida��es Novo Conte�do
    For i:=1 to Len(aDupNew)
        If lVencDayOk
            If aDupNew[i,1] < msDate()
                lRet := .t.
                Alert("[MT103DUP-01] - Inclus�o de t�tulo vencido n�o permitido! As nova condi��o de pagamento informada n�o ser� modificada...")
                lMT103DUP  := lRet // Vari�vel ser� usada no MT100TOK para consistir o conte�do do acols/folder duplicata
                Return lRet
            EndIf
        Else
            If aDupNew[i,1] <= msDate()
                lRet := .t.
                Alert("[MT103DUP-02] - Inclus�o de t�tulo vencido/vencendo hoje n�o permitido! As nova condi��o de pagamento informada n�o ser� modificada...")
                lMT103DUP  := lRet // Vari�vel ser� usada no MT100TOK para consistir o conte�do do acols/folder duplicata
                Return lRet
            EndIf
        EndIf
    Next i

    // Valida��es conte�do originals
    For ii:=1 to Len(aDupAtu)
        If lVencDayOk
            If aDupAtu[ii,2] < msDate()
                lRet := .t.
                Alert("[MT103ATU-03] - Inclus�o de t�tulo vencido n�o permitido! Verifique a condi��o de pagamento/database utilizada...")
                lMT103DUP  := lRet // Vari�vel ser� usada no MT100TOK para consistir o conte�do do acols/folder duplicata
                Return lRet
            EndIf
        Else
            If aDupAtu[ii,2] <= msDate()
                lRet := .t.
                Alert("[MT103ATU-04] - Inclus�o de t�tulo vencido/vencendo hoje n�o permitido! Verifique a condi��o de pagamento/database utilizada...")
                lMT103DUP  := lRet // Vari�vel ser� usada no MT100TOK para consistir o conte�do do acols/folder duplicata
                Return lRet
            EndIf
        EndIf
    Next ii

Return lRet

/*/{Protheus.doc} User Function ChkVencto
    Usado no X3_VLDUSER campo E2_VENCTO
    @type  Function
    @author FWNM
    @since 09/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 74270 - Criar trava no sistema para impedir lan�amentos de titulos vencidos
/*/
User Function X3VencE2()

    Local lRet       := .t.
    Local lVencDayOk := GetMV("MV_#E2VENC",,.t.)

    If Left(AllTrim(FunName()),3) <> "FIN"
        If lVencDayOk
            If M->E2_VENCTO < msDate()
                lRet := .f.
                Alert("Vencimento informado n�o permitido, pois vai gerar t�tulo vencido... Verifique...")
            EndIf
        Else
            If M->E2_VENCTO <= msDate()
                lRet := .f.
                Alert("Vencimento informado n�o permitido, pois vai gerar t�tulo vencido/vencimento hoje... Verifique...")
            EndIf
        EndIf
    EndIf
    
Return lRet
