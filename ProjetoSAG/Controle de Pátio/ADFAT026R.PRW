#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function ADFAT026R
    Impressão de ticket de pesagem "Outras"
    Chamado 18465.
    @type  Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
User Function ADFAT026R(cTicket, cTpOrdem)

    //Variáveis.
    Local aArea  := GetArea()
    Local cCabec2:= "   CNPJ:60.037.058/0004-84 EST.S.CARLOSARIB.BONITOKM257,-RURAL-Fone:01621063500"

    If Empty(cTicket)
        Help(Nil, Nil, "Função ADFAT026R(ADFAT026R)", Nil, "Informe o ticket de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->(DbSeek( FWxFilial("ZIG") + cTicket ))
        Help(Nil, Nil, "Função iTktOP(ADFAT026R)", Nil, "Ticket de pesagem " + cTicket + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        Return Nil

    EndIf 

    If cTpOrdem == "O"
       iTktOP(cTicket, cCabec2)

    ElseIf cTpOrdem == "E"
       iTktEn(cTicket, cCabec2)

    ElseIf cTpOrdem == "S"
       

    ElseIf cTpOrdem == "R"
       

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getCodP
    Obtém código de pesagem.
    @type  Static Function
    @author Everson
    @since 07/12/2021
    @version 01
/*/
Static Function getCodP(cTicket)

    //Variáveis.
    Local aArea := GetArea()
    Local oHash := tHashMap():New()

    DbSelectArea("ZIH")
    ZIH->(DbSetOrder(1))
    If ZIH->( DbSeek( FWxFilial("ZIH") + cTicket ) )

        While ! ZIH->(Eof()) .And. ZIH->ZIH_FILIAL == FWxFilial("ZIH") .And. ZIH->ZIH_TKTPRO == cTicket

            If ZIH->ZIH_CODOPE $ "2/3"
                oHash:Set(ZIH->ZIH_CODOPE, ZIH->ZIH_CODIGO)

            EndIf

            ZIH->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return oHash
/*/{Protheus.doc} iTktOP
    Imprimir ticket de pesagem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 14/12/2021
    @version 01
/*/
Static Function iTktOP(cTicket, cCabec2)

    //Variáveis.
    Local wnrel
    Local cString    := "ZIG"
    Local cTitulo    := "Ticket de Pesagem - Outras"
    Local cNomeProg  := "ADFAT026R" 
    Local cTamanho   := "P"

    private aReturn := { "Zebrado", 1,"Administracao", 1, 2,"", "",1 }
	
    wnrel:= SetPrint(cString, cNomeProg, "", @cTitulo, "", "", "", .F., .F., .F., cTamanho,, .F.)

    SetDefault(aReturn, cString, ,.T.)

    RptStatus({|lEnd| prcTktOP(@lEnd,wnRel,cString,cTamanho,cNomeProg,cTicket, cCabec2)},cTitulo)

Return Nil
/*/{Protheus.doc} prcTktOP
    Processa impressão de ticket de pesagem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 06/12/2021
    @version 01
/*/
Static Function prcTktOP(lEnd,wnrel,cString,cTamanho,cNomeProg,cTicket,cCabec2)

    //Variáveis.
    Local cCabec1   := ""
    Local cRodaTxt  := oemtoansi("Rodapé")
    Local nCntImpr  := 0
    Local nTipo     := 0
    Local nCol1     := 002
    Local nCol2     := 050
    Local nCol3     := 045
    Local oHash     := getCodP(cTicket)
    Local cCodPes   := ""

    Private oFont16n:= TFont():New("TIMES",9,15,.T.,.F.,5,.T.,5,.T.,.F.)

    nCntImpr := 0

    Li := 80

    m_pag := 1

    nTipo := 15

    cTitulo:= oemtoansi("AD'ORO SÃO CARLOS")

    cCabec1:= "              Ticket de Pesagem Outras - Peso Inicial - " + ZIG->ZIG_NUMERO

    cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, Li)

        nCntImpr++ 
        Li++

        @ Li,nCol1 PSAY "Agrupador:  " + ZIG->ZIG_ORDEM
        @ Li,nCol2 PSAY "Placa: " + ZIG->ZIG_PLACA
        Li++
        Li++

        @ Li,nCol1 PSAY "Histórico:  Outras Pesagens"
        @ Li,nCol2 PSAY "Pedido: "
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Transportadora: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Motorista: " +  Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Fase: "
        Li++
        Li++

        @ Li,nCol1 PSAY "Produto: "
        Li++
        Li++
        Li++

        oHash:Get("2", cCodPes)
        @ Li,nCol1 PSAY "Peso Inicial:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes
        Li++
        Li++
        Li++

        @ Li,nCol1 PSAY "Expeditor de Ração:____________________" 
        @ Li,nCol3 PSAY "Assinatura:______________________" 

    Roda(nCntImpr, cRodaTxt, cTamanho)

    Li := 80
    cCabec1:= "              Ticket de Pesagem Outras - Peso Final - " + ZIG->ZIG_NUMERO
    cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, Li)

        nCntImpr++ 
        Li++

        @ Li,nCol1 PSAY "Agrupador:  " + ZIG->ZIG_ORDEM
        @ Li,nCol2 PSAY "Placa: " + ZIG->ZIG_PLACA
        Li++
        Li++

        @ Li,nCol1 PSAY "Histórico:  Outras Pesagens"
        @ Li,nCol2 PSAY "Pedido: "
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Transportadora: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Motorista: " +  Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Fase: "
        Li++
        Li++

        @ Li,nCol1 PSAY "Produto: "
        Li++
        Li++
        Li++

        oHash:Get("2", cCodPes)
        @ Li,nCol1 PSAY "Peso Inicial:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes
        Li++
        oHash:Get("3", cCodPes)
        @ Li,nCol1 PSAY "Peso Final:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESFIM,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2 + " " + cCodPes
        Li++
        @ Li,nCol1 PSAY "Peso Líquido:" 
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESOLI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2
        
        Li++
        Li++
        Li++

        @ Li,nCol1 PSAY "Expeditor de Ração:____________________ " 
        @ Li,nCol3 PSAY "Assinatura:______________________" 

        Li++
        Li++

    Roda(nCntImpr, cRodaTxt, cTamanho)

    Set Device to Screen

    If aReturn[5] = 1 
        Set Printer To dbCommitAll() 
        OurSpool(wnrel)

    endIf

    MS_FLUSH()

return Nil
/*/{Protheus.doc} iTktOP
    Imprimir ticket de pesagem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 14/12/2021
    @version 01
/*/
Static Function iTktEn(cTicket, cCabec2)

    //Variáveis.
    Local wnrel
    Local cString    := "ZIG"
    Local cTitulo    := "Ticket de Pesagem - Entrada"
    Local cNomeProg  := "ADFAT026R" 
    Local cTamanho   := "P"

    private aReturn := { "Zebrado", 1,"Administracao", 1, 2,"", "",1 }
	
    wnrel:= SetPrint(cString, cNomeProg, "", @cTitulo, "", "", "", .F., .F., .F., cTamanho,, .F.)

    SetDefault(aReturn, cString, ,.T.)

    RptStatus({|lEnd| prcTktEn(@lEnd,wnRel,cString,cTamanho,cNomeProg,cTicket, cCabec2)},cTitulo)

Return Nil
/*/{Protheus.doc} prcTktEn
    Processa impressão de ticket de pesagem do tipo "Entrada".
    @type  Static Function
    @author Everson
    @since 14/12/2021
    @version 01
/*/
Static Function prcTktEn(lEnd,wnrel,cString,cTamanho,cNomeProg,cTicket,cCabec2)

    //Variáveis.
    Local cCabec1   := ""
    Local cRodaTxt  := oemtoansi("Rodapé")
    Local nCntImpr  := 0
    Local nTipo     := 0
    Local nCol1     := 002
    Local nCol2     := 050
    Local nCol3     := 045
    Local oHash     := getCodP(cTicket)
    Local cCodPes   := ""
    Local cAgrupador:= ""
    Local cOrdens   := ""
    Local cNFPed    := ""
    Local cFornec   := ""
    Local cAux      := ""
    Local cCidade   := ""
    Local cProduto  := ""

    Private oFont16n:= TFont():New("TIMES",9,15,.T.,.F.,5,.T.,5,.T.,.F.)

    DbselectArea("ZIF")
    ZIF->(DbSetOrder(2))
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + ZIG->ZIG_ORDEM ))

        ZIF->(DbSetOrder(3))
        If ! ZIF->(DbSeek( FWxFilial("ZIF") + ZIG->ZIG_ORDEM ))
            Help(Nil, Nil, "Função prcAgrp(ADFAT017P)", Nil, "Ordem de pesagem " + ZIG->ZIG_ORDEM + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
            Return Nil

        EndIf

    EndIf

    While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF")

        cAgrupador := ZIF->ZIF_AGRUPA

        cOrdens += ZIF->ZIF_NUMERO + " "

        cNFPed  += "NF:" + Alltrim(cValToChar(ZIF->ZIF_NF + "/" + ZIF->ZIF_SERIE)) + " Ped.C.:" + Alltrim(cValToChar(ZIF->ZIF_PEDCOM)) + " "

        If ! (ZIF->ZIF_NMFOR $cFornec)
            cFornec += ZIF->ZIF_NMFOR + " "

        EndIf

        cAux := Alltrim(Posicione("SA2", 1, FWxFilial("SA2") + ZIF->ZIF_FORNEC + ZIF->ZIF_LJFORN ,"A2_MUN")) + "-" + Alltrim(Posicione("SA2", 1, FWxFilial("SA2") + ZIF->ZIF_FORNEC + ZIF->ZIF_LJFORN ,"A2_EST"))

        If ! (cAux $cCidade)
            cCidade += cAux + " "

        EndIf

        cAux := Posicione("SB1", 1, FWxFilial("SB1") + ZIF->ZIF_PRDPRO ,"B1_DESC")

        If ! (cAux $cProduto)
            cProduto += cAux

        EndIf

        ZIF->(DbSkip())

        If ZIG->ZIG_AGRUPA == "1" .And. ZIF->ZIF_AGRUPA <> ZIG->ZIG_ORDEM
            Exit

        ElseIf ZIG->ZIG_AGRUPA == "2" .And. ZIF->ZIF_NUMERO <> ZIG->ZIG_ORDEM
            Exit

        EndIf

    End

    nCntImpr := 0

    Li := 80

    m_pag := 1

    nTipo := 15

    cTitulo:= oemtoansi("AD'ORO SÃO CARLOS")

    cCabec1:= "              Ticket de Pesagem Entradas - Peso Inicial - " + ZIG->ZIG_NUMERO
    
    cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, Li)

        nCntImpr++ 
        Li++

        @ Li,nCol1 PSAY "Agrupador:  " + cAgrupador

        @ Li,nCol2 PSAY "Placa: " + ZIG->ZIG_PLACA
        Li++
        Li++

        @ Li,nCol1 PSAY "Ordem(ns): " + cOrdens
        Li++
        Li++

        @ Li,nCol1 PSAY "Histórico: " + cNFPed
        Li++
        Li++

        @ Li,nCol1 PSAY "Transportadora: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Motorista: " +  Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Fornecedor: " + cFornec
        Li++
        Li++

        @ Li,nCol1 PSAY "Cidade: " + cCidade
        Li++
        Li++

        @ Li,nCol1 PSAY "Produto: " + cProduto
        Li++
        Li++
        Li++

        oHash:Get("2", cCodPes)
        @ Li,nCol1 PSAY "Peso Inicial:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes
        Li++
        Li++
        Li++

        @ Li,nCol1 PSAY "Obs. Lab.:" 

    Roda(nCntImpr, cRodaTxt, cTamanho)

    Li := 80
    cCabec1:= "              Ticket de Pesagem Entradas - Peso Final - " + ZIG->ZIG_NUMERO
    cabec(cTitulo, cCabec1, cCabec2, cNomeProg, cTamanho, Li)

        nCntImpr++ 
        Li++

        @ Li,nCol1 PSAY "Agrupador:  " + cAgrupador

        @ Li,nCol2 PSAY "Placa: " + ZIG->ZIG_PLACA
        Li++
        Li++

        @ Li,nCol1 PSAY "Ordem(ns): " + cOrdens
        Li++
        Li++

        @ Li,nCol1 PSAY "Histórico: " + cNFPed
        Li++
        Li++

        @ Li,nCol1 PSAY "Transportadora: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Motorista: " +  Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI")
        Li++
        Li++ 

        @ Li,nCol1 PSAY "Fornecedor: " + cFornec
        Li++
        Li++

        @ Li,nCol1 PSAY "Cidade: " + cCidade
        Li++
        Li++

        @ Li,nCol1 PSAY "Produto: " + cProduto
        Li++
        Li++
        Li++

        oHash:Get("2", cCodPes)
        @ Li,nCol1 PSAY "Peso Inicial:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes
        Li++
        oHash:Get("3", cCodPes)
        @ Li,nCol1 PSAY "Peso Final:"
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESFIM,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2 + " " + cCodPes
        Li++
        @ Li,nCol1 PSAY "Peso Líquido:" 
        @ Li,020 PSAY Alltrim(cValToChar(Transform(ZIG->ZIG_PESOLI,"@E 99,999,999,999"))) + "KG " + DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2
        Li++

        nPesLiq := ZIG->ZIG_PESOLI
        nPesOrd := ZIG->ZIG_PESORD
        @ Li,nCol1 PSAY "Dif(Liq-Ord):" 
        @ Li,020 PSAY Alltrim(cValToChar(Transform(nPesLiq - nPesOrd,"@E 99,999,999.999"))) + "KG " + Alltrim(cValToChar(Transform(Iif(nPesOrd<=0,0,((nPesLiq-nPesOrd)/nPesOrd)*100),"@E 99,999,999.999"))) + "%"
        
        Li++
        Li++
        Li++

        @ Li,nCol3 PSAY "Motorista:______________________" 

        Li++
        Li++

    Roda(nCntImpr, cRodaTxt, cTamanho)

    Set Device to Screen

    If aReturn[5] = 1 
        Set Printer To dbCommitAll() 
        OurSpool(wnrel)

    endIf

    MS_FLUSH()

return Nil
