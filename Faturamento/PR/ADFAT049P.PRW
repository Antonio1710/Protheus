
/*/{Protheus.doc} User Function ADFAT049P
    Job para obter os registros de carregamento do Gemba.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT049P() // U_ADFAT049P()


    RPCSetType(3)
	RpcSetEnv("01","03",,,,GetEnvServer(),{ })

        U_ADFAT491()

	RpcClearEnv()

Return Nil
/*/{Protheus.doc} User Function ADFAT491
    Processa obtenção dos registros de carregamento do Gemba.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 10/05/2022
    @version 01
/*/
User Function ADFAT491()

    //Variáveis.
    Local lBarramento := GetMv("MV_#ADF491",,.T.) //Registros de pesagem vindos do barramento.
    
    If lBarramento
        U_ADFAT29J()
    
    Else
        U_ADFAT50D()

    EndIf

    U_ADFAT50B()

Return Nil
