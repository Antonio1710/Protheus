

User Function JobTest() // U_JobTest()

    RPCClearEnv()
	RPCSetType(3)
	RpcSetEnv("01","05",,,,GetEnvServer(),{ })

        U_ADVEN050P("",.T.,," AND C5_NUM IN ('9BFDU9') ",,,,,,,1)

        // FOR nCont3 := 1 TO 2
        //     STATICCALL(ADLOG006P,CRIAWEBSERVICE)
        // NEXT nCont3

        // cFilter := " D2_FILIAL ='" + FWxFilial("SD2") + "' .And. D2_DOC = '000059405' .And. D2_SERIE = '01 ' .And. D2_CLIENTE = '052250' .And. D2_LOJA = '00' "

        // 	U_ADFAT27D(;
		// 	   "SF2", 1, FWxFilial("SF2") + "00005940501 05225000",;
		// 	   "SD2", 3, FWxFilial("SD2") +  "00005940501 05225000", "D2_COD+D2_ITEM",cFilter,;
		// 	   "documentos_de_saida_protheus", "I",;
		// 	   .T., .T.,.T., Nil)

        // DbSelectArea("SF2")
        // SF2->(DbSetOrder(1))
        // SF2->(DbSeek( FWxFilial("SF2") +   "00005940501 05225000") )

        // DbSelectArea("SD2")
        // SD2->(DbSetOrder(3))
        // SD2->(DbSeek( FWxFilial("SD2") + "00005940501 "))

        // STATICCALL(M460FIM, grvBarr,"I",  "00005940501 05225000", "000059405", "01 ")


    RpcClearEnv()

Return Nil
