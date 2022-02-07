#INCLUDE "Protheus.ch"

/*/{Protheus.doc} User Function ADLOG077P
    (Bloqueio do campo ZV4_Placa, para não deixar alterar.)
    @type  Function
    @author ADRIANO SAVOINE
    @since 10/08/2021
    @history Ticket: 18125 - 10/08/2021 - ADRIANO SAVOINE - Programa para tratar a Edição do campo ZV4_PLACA, impedindo a alteração do mesmo se não estiver no Parametro.
    /*/

User Function ADLOG077P()

Local lRet := .F.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Bloqueio do campo ZV4_Placa, para não deixar alterar.')


    IF INCLUI 
        lRet := .T. 
     ELSEIF ALTERA .AND. RetCodUsr() $ GetMV("MV_#ALTPLC")
        lRet := .T.
    ELSE 
        lRet := .F.
    EndIf    
    

Return lRet
