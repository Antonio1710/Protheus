#Include "Protheus.ch"

/*/{Protheus.doc} User Function MNTA280BT
    Adiciona Botões na Rotina Solicitação de Serviço 
    Chamado 18732.
    @type  Function
    @author Tiago Stocco
    @since 18/10/2021
    @version 01
/*/
User Function MNTA280BT()

Local aRot := {}
Aadd(aRot,{ "Altera Executante" ,"u_ADMNT016P(TQB->(RECNO()))",3,0,0 ,NIL} )

Return(arot)
