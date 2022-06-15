#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} ADFAT056P
    Job para geração de pedidos de venda entre filiais.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 31/05/2022
    @version 01
    @history Everson, 01/06/2022, ticket 18465 - Corrijida filial.
/*/
User Function ADFAT056P() // U_ADFAT056P()

    //Variáveis.

	// RPCSetType(3)
	RpcSetEnv("01", "05",,,,GetEnvServer(),{ }) //Everson, 01/06/2022, ticket 18465.

        U_ADFAT29F()

    RpcClearEnv()

Return Nil
