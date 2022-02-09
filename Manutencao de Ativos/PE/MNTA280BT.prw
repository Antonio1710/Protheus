#Include "Protheus.ch"

/*/{Protheus.doc} User Function MNTA280BT
    Adiciona Botões na Rotina Solicitação de Serviço 
    Chamado 18732.
    @type  Function
    @author Tiago Stocco
    @since 18/10/2021
    @version 01
    @history Chamado n. TI - Leonardo P. Monteiro - 09/02/2022 - Retirada da fun��o U_ADINF009P.

/*/
User Function MNTA280BT()

Local aRot := {}

//U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Botões na Rotina Solicitação de Serviço')

Aadd(aRot,{ "Altera Executante" ,"u_ADMNT016P(TQB->(RECNO()))",3,0,0 ,NIL} )

Return(arot)
