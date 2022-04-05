#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} ADFAT044P
    Job para processamento de registros recebidos do barramento.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 05/04/2022
    @version 01
/*/
User Function ADFAT044P() // U_ADFAT044P()

    //Variáveis.

	RpcSetEnv("01", "05",,,,GetEnvServer(),{ })

        U_ADFAT29A()

    RpcClearEnv()

Return Nil
