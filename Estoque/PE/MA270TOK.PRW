#INCLUDE "Protheus.ch"
#INCLUDE "TBICONN.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} User Function MA270TOK
    (Ponto de entrada para validar os dados informados pelo usuário, quando executado o botão de confirmação)
    @type  Function
    @author Adriano Savoine
    @since 10/01/2020
    @version 01
    @history CHAMADO: 054390 - 10/01/2019 - ADRIANO SAVOINE - Programa exibe a mensagem de Alerta quando existir o produto já inserido no inventario para a data e local.
    /*/

User Function MA270TOK()

    LOCAL lRet := .T.
    LOCAL aAreaAnt := GETAREA()
   
    IF lRet .And. Inclui //CHAMADO: 054390 - 10/01/2019 - ADRIANO SAVOINE

        SB7->(dbSetOrder(1))

        IF SB7->(dbSeek(xFilial("SB7")+DTOS(M->B7_DATA)+M->B7_COD+M->B7_LOCAL))
           
            Alert('O produto ' + ALLTRIM(M->B7_COD) + ' já existe nesse Inventario para o almoxarifado ' + ALLTRIM(M->B7_LOCAL) + ' na data ' + DTOC(M->B7_DATA) + ' verifique!!!')

            lRet:=.F.

        ENDIF
       
      
    ENDIF // CHAMADO: 054390 - 10/01/2019 - ADRIANO SAVOINE

    RESTAREA(aAreaAnt)   // Retorna o ambiente anterior 

Return lRet
