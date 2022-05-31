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
/*/
User Function ADFAT056P() // U_ADFAT056P()

    //Variáveis.

	// RPCSetType(3)
	RpcSetEnv("01", "03",,,,GetEnvServer(),{ })

        U_ADFAT29F()

    RpcClearEnv()

Return Nil
