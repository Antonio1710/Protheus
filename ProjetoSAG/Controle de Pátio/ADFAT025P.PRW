
/*/{Protheus.doc} User Function ADFAT025P
    Job para obter os registros de pesagem do Guardian.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 03/12/2021
    @version 01
/*/
User Function ADFAT025P() // U_ADFAT025P()

    RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })
		
		U_ADFT2412()
        U_ADFT2413()

	RpcClearEnv()

Return Nil
