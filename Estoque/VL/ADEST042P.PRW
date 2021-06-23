#include "rwmake.ch"
#include "PRTOPDEF.CH"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADEST042P
    chamado 051400 || OS 052730 || ALMOXARIFADO || FABIO || 8410 || BAIXA REQUISICAO
    Validação de campo D3_TM para não deixar certos usuários dar baixas em requisições
    sem ser o tipo 501
    @author William
    @since 21/10/2019
    @version 01
    
/*/

/*/{Protheus.doc} User Function ADEST042P
    chamado T.I
    Quando é rodado o estorno de inventário não tem a variavel de memoria M no sistema gerando 
    error log onde foi corrigido.
    sem ser o tipo 501
    @author William
    @since 22/10/2019
    @version 02
    
/*/

User Function ADEST042P()

    Local lRet := .T.

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Validação de campo D3_TM para não deixar certos usuários dar baixas em requisições')

    IF __cUserID $ GetMv('MV_#USUD3T',.F.,"001460/002105/001889/002108/002045/001574")

        // *** INICIO chamado T.I 22/10/2019 - Ajuste Váriavel de Memória
        IF M->D3_TM <> NIL

            IF ALLTRIM(M->D3_TM) <> '' //TRATAR ERROS QUANDO NAO TEM VALOR EM MEMORIA DO REGISTRO

                IF ALLTRIM(M->D3_TM) <> '501' // chamado 051400 - WILLIAM COSTA 22/10/2019 - Movimentação 501

                    MsgAlert("OLÁ " + Alltrim(cUserName) + ", você não tem permissão para fazer movimentação no Estoque sem ser Movimento 501, Fale com Coordenador de Estoque ", "ADEST042P-MV_#USUD3T-01")
                    lRet:= .F.

                ENDIF
            ENDIF
        ENDIF
        // *** FINAL chamado T.I 22/10/2019 - Ajuste Váriavel de Memória
    ENDIF
    
Return(lRet)   