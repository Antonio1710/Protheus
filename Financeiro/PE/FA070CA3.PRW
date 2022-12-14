#INCLUDE "PROTHEUS.CH"

/*{Protheus.doc} User Function FA070CA3
	O ponto de entrada FA070CA3 sera executado antes da entrada na rotina cancelamento de baixa do contas a receber, para verificar se esta pode ou nao ser cancelada.N?o deixar apertar o bot?o excluir somente se for o tipo R.A
	@type  Function
	@author William Cosata
	@since 21/09/2020
	@version 01
*/    

User Function FA070CA3()

    Local lRet     := .T.    

    IF PARAMIXB == 6 // Bot?o Excluir

        IF GetMv("MV_#EXCBAI",,.F.) == .F.

            IF ALLTRIM(SE1->E1_TIPO) <> 'RA'

                MSGSTOP("OL? " + Alltrim(cUserName) + ", S? ? permitido excluir baixa se for R.A, use o bot?o cancelamento de baixa, obrigado.", "FA070CA3-01")

                lRet     := .F.    

            ENDIF
        ENDIF
    ENDIF

Return(lRet)
