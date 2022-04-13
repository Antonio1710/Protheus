
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

        U_ADFAT251()

	RpcClearEnv()

Return Nil
/*/{Protheus.doc} User Function ADFAT251
    Processa obtenção dos registros de pesagem do Guardian.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 01/04/2022
    @version 01
/*/
User Function ADFAT251()

    //Variáveis.
    Local lBarramento := Nil

    lBarramento := GetMv("MV_#ADF251",,.T.) //Registros de pesagem vindos do barramento.
    
    If lBarramento
        U_ADFAT29H()
    
    Else
        U_ADFAT24C()

    EndIf

    U_ADFAT24D()

Return Nil
