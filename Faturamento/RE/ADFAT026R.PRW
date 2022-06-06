#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "FWPrintSetup.ch"
#Include "RPTDEF.CH"

/*/{Protheus.doc} User Function ADFAT026R
    Impressão de ticket de pesagem.
    Chamado 18465.
    @type  Function
    @author Everson
    @since 06/12/2021
    @version 01
    @history Everson, 02/06/2022, ticket 18465, alterado a informação da pessoa no ticket de pesagem de ração.
/*/
User Function ADFAT026R(cTicket, cTpOrdem, cCP, lJob) // U_ADFAT026R("0000070", "R")

    //Variáveis.
    Local aArea  := GetArea()
    Local cCabec2:= ""
    Local cTpRac := ""

    Default lJob := .F.

    If cTpOrdem == "IMPRORC"
        romRacao(cCP)
        RestArea(aArea)
        Return Nil

    EndIf

    If Empty(cTicket)
        Help(Nil, Nil, "Função ADFAT026R(ADFAT026R)", Nil, "Informe o ticket de pesagem.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(1))
    If ! ZIG->(DbSeek( FWxFilial("ZIG") + cTicket ))
        Help(Nil, Nil, "Função iTktOP(ADFAT026R)", Nil, "Ticket de pesagem " + cTicket + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf 

    If cFilAnt == "03"
        cCabec2 := "CNPJ: 60.037.058/0004-84 EST. S CARLOS A RIB BONITO, KM 157 - ZONA RURAL - (016) 2106-3501 - São Carlos"
        cTpRac := "Frango"

    ElseIf cFilAnt == "05"
        cCabec2 := "CNPJ:  60.037.058/0018-80 EST. S CARLOS A RIB BONITO, KM 154 - ZONA RURAL - (016)  - São Carlos"
        cTpRac := "Matrizes"

    EndIf

    If cTpOrdem == "O"
       iTktOP(cTicket, cCabec2, cTpRac)

    ElseIf cTpOrdem == "E"
       iTktEn(cTicket, cCabec2, cTpRac)

    ElseIf cTpOrdem == "S"
        iTktSa(cTicket, cCabec2, cTpRac)

    ElseIf cTpOrdem == "R"
       iTktRc(cTicket, cCabec2, cTpRac, lJob)

    ElseIf cTpOrdem == "IMPROVD"
        romVenda(cTicket)

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
Static Function iTktOP(cTicket, cCabec2, cTpRac)

    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cCodPes   := ""
    Local oHash     := getCodP(cTicket)
    Local cCarga    := ""

    If ! U_ADFAT16A(ZIG->ZIG_ORDEM)
        Help(Nil, Nil, "Função iTktOP(ADFAT026R)", Nil, "Ordem de pesagem " + ZIG->ZIG_ORDEM + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cCarga := ZIF->ZIF_ROTEIR

    oPrinter := FWMSPrinter():New(cTicket, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)

    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro São Carlos", oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ticket de Pesagem - Outras Pesagens - " + cTicket, oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(120,  20, "Agrupador: ", oFt16B)
            oPrinter:Say(120, 100, ZIG->ZIG_ORDEM, oFt14N)

            oPrinter:Say(145,  20, "Histórico: ", oFt16B)
            oPrinter:Say(145, 100, "Outras Pesagens", oFt14N)

            oPrinter:Say(165,  20, "Transp.", oFt16B)
            oPrinter:Say(165, 100,  Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME"), oFt14N)

            oPrinter:Say(185,  20, "Motorista: ", oFt16B)
            oPrinter:Say(185, 100, Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI"), oFt14N)

        //Coluna 2.   
            oHash:Get("3", cCodPes)
            oPrinter:Say(265, 210, "Peso Bruto: ", oFt16B)
            oPrinter:SayAlign(252, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESFIM, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(252, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2 + " " + cCodPes, oFt14N, 555, 12,,0, 1)

            oHash:Get("2", cCodPes)
            oPrinter:Say(285, 210, "Peso Inicial: ", oFt16B)
            oPrinter:SayAlign(272, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(272, 360,DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes, oFt14N, 555, 12,,0, 1)
   
            oPrinter:Say(305, 210, "Líquido: ", oFt16B)
            oPrinter:SayAlign(292, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESOLI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(292, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2, oFt14N, 555, 12,,0, 1)        


        //Coluna 3.
            oPrinter:Say(120, 420, "Placa: ", oFt16B)
            oPrinter:Say(120, 490, ZIG->ZIG_PLACA, oFt14N)

        oPrinter:Say(400,  20, "Ass. Motorista:________________________________________________________________", oFt14N)

    oPrinter:EndPage()
    
    oPrinter:Setup()

    If oPrinter:nModalResult == PD_OK
        oPrinter:Preview()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} iTktOP
    Imprimir ticket de pesagem do tipo "Outras".
    @type  Static Function
    @author Everson
    @since 14/12/2021
    @version 01
/*/
Static Function iTktEn(cTicket, cCabec2, cTpRac)

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

    If ! U_ADFAT16A(ZIG->ZIG_ORDEM)

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

        @ Li,nCol1 PSAY "Transp.: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
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

        @ Li,nCol1 PSAY "Transp.: " + Posicione("SA4", 1, FWxFilial("SA4") + ZIG->ZIG_TRANSP, "A4_NOME")
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

Return Nil
/*/{Protheus.doc} iTktRc
    Processa impressão de ticket de pesagem do tipo "Ração".
    @type  Static Function
    @author Everson
    @since 09/03/2022
    @version 01
/*/
Static Function iTktRc(cTicket, cCabec2, cTpRac, lJob) // U_ADFAT026R("0000070", "R")

    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20N    := TFont():New("Arial",20,20,,.F.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cLote     := ""
    Local cDtFab    := ""
    Local cDtVld    := ""
    Local cCarga    := ""
    Local oHash     := getCodP(cTicket)
    Local cCodPes   := ""
    Local cVersao   := ""
    Local cDtLoj    := ""
    Local cCdGrjd   := ""
    Local cDtAbt    := ""
    Local cFase     := ""
    Local cEnd      := ""
    Local cImpress  := Alltrim(cValToChar(GetMv("MV_#IMPCPT", , "")))
    Local cPreFx    := "Impressão Ticket: "

    Default lJob    := .F.

    If ! lJob .And. ! U_ADFAT16A(ZIG->ZIG_ORDEM)
        Help(Nil, Nil, "Função iTktRc(ADFAT026R)", Nil, "Ordem de pesagem " + ZIG->ZIG_ORDEM + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If lJob .And. Empty(cImpress)
        U_ADFAT173(cPreFx + " sem impressora configurada(MV_#IMPCPT)", ZIG->ZIG_ORDEM, "", "PROTHEUS")
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    If ZI8->( DbSeek( FWxFilial("ZI8") + ZIF->ZIF_LOTE) )
        cLote  := Alltrim(cValToChar(ZI8->ZI8_DESLOT))

    EndIf

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))
    SA2->(DbGoTop())
    If SA2->( DbSeek( FWxFilial("SA2") + ZIF->ZIF_FORNEC + ZIF->ZIF_LJFORN) )
        cEnd   := Alltrim(SA2->A2_END) + ", " + Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN) + " - " + Alltrim(SA2->A2_EST)

    End

    //Everson - 02/06/2022. Chamado 18465.
    If ! U_ADFAT32G( ZIF->ZIF_ORDRAC)
        Help(Nil, Nil, "Função iTktRc(ADFAT026R)", Nil, "Ordem de ração " + ZIF->ZIF_ORDRAC + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    cCarga := ZIF->ZIF_ROTEIR
    cDtFab := DToC(ZIG->ZIG_DTPES2)
    cDtVld := DToC(ZIG->ZIG_DTPES2 + 30)
    cVersao:= Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_DESSAG" )
    cCdGrjd:= Posicione("ZIR", 1, FWxFilial("ZIR") + ZIF->ZIF_ORDRAC, "ZIR_CODGRJ" )
    cDtLoj := DToC(Posicione("ZIS", 1, FWxFilial("ZIS") + cCdGrjd, "ZIS_DTALOJ"))
    cDtAbt := DToC(Posicione("ZIS", 1, FWxFilial("ZIS") + cCdGrjd, "ZIS_DTALOJ") + 48)
    cFase  := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_SGPSAG" )))

    oPrinter := FWMSPrinter():New(cTicket, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)

    If lJob
        oPrinter:lServer  := .F.
        oPrinter:nDevice  := IMP_SPOOL
        oPrinter:cPrinter := cImpress
        oPrinter:SetPortrait()

    EndIf
 
    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro Fábrica de Ração " + cTpRac, oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ticket de Pesagem - Saída de Ração - " + cTicket, oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(120,  20, "Roteiro: ", oFt16B)
            oPrinter:Say(120, 100, cCarga, oFt14N)

            oPrinter:Say(145,  20, "Histórico: ", oFt16B)
            oPrinter:Say(145, 100, "", oFt14N)

            oPrinter:Say(165,  20, "Placa: ", oFt16B)
            oPrinter:Say(165, 100, ZIG->ZIG_PLACA, oFt14N)

            oPrinter:Say(185,  20, "Pessoa: ", oFt16B)
            oPrinter:Say(185, 100, ZIR->ZIR_DESGRJ, oFt14N) //Everson - 02/06/2022. Chamado 18465.

            oPrinter:Say(205,  20, "Endereço: ", oFt16B)
            oPrinter:Say(205, 100, cEnd, oFt14N)

            oPrinter:Say(225,  20, "Fase: ", oFt16B)
            oPrinter:Say(225, 100, cFase, oFt14N)

            oPrinter:Say(325,  20, "Lacres: ", oFt16B)
            oPrinter:Say(325, 100, getLacres(ZIF->ZIF_NUMERO), oFt14N)

            oPrinter:Say(345,  20, "Caixas: ", oFt16B)
            oPrinter:Say(345, 100, getCaixas(ZIF->ZIF_NUMERO), oFt14N)

        //Coluna 2.
            oPrinter:Say(120, 210, "Ord. Pes: ", oFt16B)
            oPrinter:Say(120, 280, ZIG->ZIG_ORDEM, oFt14N)

            oPrinter:Say(165, 210, "Motorista: ", oFt16B)
            oPrinter:Say(165, 280, Posicione("ZVC", 1, FWxFilial("ZVC") + ZIG->ZIG_MOTORI, "ZVC_MOTORI"), oFt14N)

            oPrinter:Say(185, 210, "Data Aloj.: ", oFt16B)
            oPrinter:Say(185, 280, cDtLoj, oFt14N)
            
            oPrinter:Say(225, 210, "Versão: ", oFt16B)
            oPrinter:Say(225, 280, cVersao, oFt14N)

            oHash:Get("3", cCodPes)
            oPrinter:Say(265, 210, "Peso Bruto: ", oFt16B)
            oPrinter:SayAlign(252, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESFIM, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(252, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2 + " " + cCodPes, oFt14N, 555, 12,,0, 1)

            oHash:Get("2", cCodPes)
            oPrinter:Say(285, 210, "Peso Inicial: ", oFt16B)
            oPrinter:SayAlign(272, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(272, 360,DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes, oFt14N, 555, 12,,0, 1)
   
            oPrinter:Say(305, 210, "Líquido: ", oFt16B)
            oPrinter:SayAlign(292, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESOLI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(292, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2, oFt14N, 555, 12,,0, 1)

        //Coluna 3.
            oPrinter:Say(120, 420, "Ord. Crg: ", oFt16B)
            oPrinter:Say(120, 490, ZIF->ZIF_ORDRAC, oFt14N)

            If cFilAnt == "03"
                oPrinter:Say(185, 420, "Abate: ", oFt16B)
                oPrinter:Say(185, 490, cDtAbt, oFt14N)

            EndIf

            oPrinter:Say(225, 420, "Lote: ", oFt16B)
            oPrinter:Say(225, 490, cLote, oFt14N)

        oPrinter:Line(355, 20, 355, 555)
        oPrinter:SayAlign(360, 20, "PRÓXIMO ENVIO", oFt20N, 555, 30,,2)
        oPrinter:Line(385, 20, 385, 555)

        oPrinter:Say(395, 20,  "Data: ", oFt12N)
        oPrinter:Say(395, 210, "Tipo: ", oFt12N)
        oPrinter:Say(395, 420, "Qtde: ", oFt12N)

        oPrinter:Say(425,  20, "Ass. Recebedor:________________________________________________________________", oFt14N)
        oPrinter:Say(450,  20, "Observações do Motorista:________________________________________________________", oFt14N)
        oPrinter:Say(470,  20, "Granjeiro (Nome/Assinatura):______________________________________________________", oFt14N)
        oPrinter:Say(490,  20, "Data/Hora Recebimento:__/__/_____ __:___ Estoque Silo (Antes Decarga):_________________", oFt14N)

        //Imagem.
            oPrinter:SayBitmap (495, 20, "\img_ticket_racao\" + FWxFilial("ZIG") + "\" + cFase + ".png", 555, 330)
            oPrinter:Say(785,  70, cLote,  oFt16B)
            oPrinter:Say(785, 250, cDtFab, oFt16B)
            oPrinter:Say(785, 420, cDtVld, oFt16B)

    oPrinter:EndPage()
    
    If ! lJob

        oPrinter:Setup()

        If oPrinter:nModalResult == PD_OK
            oPrinter:Preview()

        EndIf

    Else


        oPrinter:Print()

        RecLock("ZIG", .F.)
            ZIG->ZIG_ENVIAD := "1"
        ZIG->(MsUnlock())

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} getLacres
    Obtém lacres.
    @type  Static Function
    @author Everson
    @since 09/03/2022
    @version 01
/*/
Static Function getLacres(cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()
    Local cLacres   := ""

    DbSelectArea("ZIT")
    ZIT->(DbSetOrder(3))
    If ! ZIT->(DbSeek( FWxFilial("ZIT") + cNmOrdem))
        RestArea(aArea)
        Return cLacres

    EndIf

    While ! ZIT->(Eof()) .And. ZIT->ZIT_FILIAL == FWxFilial("ZIT") .And. ZIT->ZIT_ORDEM == cNmOrdem

        cLacres += Alltrim(cValToChar(ZIT_LACRE)) + ", "

        ZIT->(DbSkip())

    End

    RestArea(aArea)

Return cLacres
/*/{Protheus.doc} getCaixas
    Obtém caixas.
    @type  Static Function
    @author Everson
    @since 09/03/2022
    @version 01
/*/
Static Function getCaixas(cNmOrdem)

    //Variáveis.
    Local aArea     := GetArea()
    Local cCaixas   := ""

    DbSelectArea("ZIZ")
    ZIZ->(DbSetOrder(3))
    If ! ZIZ->(DbSeek( FWxFilial("ZIZ") + cNmOrdem))
        RestArea(aArea)
        Return cCaixas

    EndIf

    While ! ZIZ->(Eof()) .And. ZIZ->ZIZ_FILIAL == FWxFilial("ZIZ") .And. ZIZ->ZIZ_ORDEM == cNmOrdem

        cCaixas += Alltrim(cValToChar(ZIZ_CAIXA)) + ", "

        ZIZ->(DbSkip())

    End

    RestArea(aArea)

Return cCaixas
/*/{Protheus.doc} getCxCad
    Obtém caixas do cadastro do veículo.
    @type  Static Function
    @author Everson
    @since 31/05/2022
    @version 01
/*/
Static Function getCxCad(cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local cCaixas   := ""

    DbSelectArea("ZIX")
    ZIX->(DbSetOrder(1))
    If ! ZIX->(DbSeek( FWxFilial("ZIX") + cPlaca))
        RestArea(aArea)
        Return cCaixas

    EndIf

    While ! ZIX->(Eof()) .And. ZIX->ZIX_FILIAL == FWxFilial("ZIX") .And. ZIX->ZIX_PLACA == cPlaca

        cCaixas += Alltrim(cValToChar(ZIX->ZIX_NUMERO)) + ", "

        ZIX->(DbSkip())

    End

    RestArea(aArea)

Return cCaixas
/*/{Protheus.doc} iTktSa
    Processa impressão de ticket de pesagem do tipo "Saída".
    @type  Static Function
    @author Everson
    @since 09/03/2022
    @version 01
/*/
Static Function iTktSa(cTicket, cCabec2, cTpRac) // U_ADFAT026R("0000070", "R")

    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cCodPes   := ""
    Local oHash     := getCodP(cTicket)
    Local cPedS     := ""
    Local cProduto  := ""
    Local cCarga    := """
    Local cEnd      := ""

    If ! U_ADFAT16A(ZIG->ZIG_ORDEM)
        Help(Nil, Nil, "Função iTktRc(ADFAT026R)", Nil, "Ordem de pesagem " + ZIG->ZIG_ORDEM + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    If ZIF->ZIF_CLIFOR == "F"
        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))
        SA2->(DbGoTop())
        If SA2->( DbSeek( FWxFilial("SA2") + ZIF->ZIF_FORNEC + ZIF->ZIF_LJFORN) )
            cEnd   := Alltrim(SA2->A2_END) + ", " + Alltrim(SA2->A2_BAIRRO) + " - " + Alltrim(SA2->A2_MUN) + " - " + Alltrim(SA2->A2_EST)
        
        EndIf

    ElseIf ZIF->ZIF_CLIFOR == "C"
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1))
        SA1->(DbGoTop())
        If SA1->( DbSeek( FWxFilial("SA1") + ZIF->ZIF_FORNEC + ZIF->ZIF_LJFORN) )
            cEnd   := Alltrim(SA1->A1_END) + ", " + Alltrim(SA1->A1_BAIRRO) + " - " + Alltrim(SA1->A1_MUN) + " - " + Alltrim(SA1->A1_EST)

        EndIf

    EndIf

    DbSelectArea("SC6")
    SC6->(DbSetOrder(17))
    If SC6->(DbSeek( FWxFilial("SC6") + ZIF->ZIF_NUMERO))
        cPedS := SC6->C6_NUM
        cProduto := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_DESSAG")))

    EndIf

    cCarga := ZIF->ZIF_ROTEIR

    oPrinter := FWMSPrinter():New(cTicket, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)

    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro São Carlos", oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ticket de Pesagem - Saídas - " + cTicket, oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(120,  20, "Agrupador: ", oFt16B)
            oPrinter:Say(120, 100, ZIG->ZIG_ORDEM, oFt14N)

            oPrinter:Say(145,  20, "Histórico: ", oFt16B)
            oPrinter:Say(145, 100, "", oFt14N)

            oPrinter:Say(165,  20, Iif(ZIF->ZIF_CLIFOR == "C", "Cliente: ", "Fornec:"), oFt16B)
            oPrinter:Say(165, 100,  ZIF->ZIF_FORNEC + "/" + ZIF->ZIF_LJFORN + " " + ZIF->ZIF_NMFOR, oFt14N)

            oPrinter:Say(185,  20, "Endereço: ", oFt16B)
            oPrinter:Say(185, 100, cEnd, oFt14N)

            oPrinter:Say(225,  20, "Produto: ", oFt16B)
            oPrinter:Say(225, 100, cProduto, oFt14N)

        //Coluna 2.   
            oHash:Get("3", cCodPes)
            oPrinter:Say(265, 210, "Peso Bruto: ", oFt16B)
            oPrinter:SayAlign(252, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESFIM, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(252, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2 + " " + cCodPes, oFt14N, 555, 12,,0, 1)

            oHash:Get("2", cCodPes)
            oPrinter:Say(285, 210, "Peso Inicial: ", oFt16B)
            oPrinter:SayAlign(272, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESINI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(272, 360,DToC(ZIG->ZIG_DTPES1) + " " + ZIG->ZIG_HRPES1 + " " + cCodPes, oFt14N, 555, 12,,0, 1)
   
            oPrinter:Say(305, 210, "Líquido: ", oFt16B)
            oPrinter:SayAlign(292, 240, Alltrim(cValToChar(Transform(ZIG->ZIG_PESOLI, "@E 999,999,999.99"))), oFt14N, 100, 12,,1, 1)
            oPrinter:SayAlign(292, 360, DToC(ZIG->ZIG_DTPES2) + " " + ZIG->ZIG_HRPES2, oFt14N, 555, 12,,0, 1)        


        //Coluna 3.
            oPrinter:Say(120, 420, "Placa: ", oFt16B)
            oPrinter:Say(120, 490, ZIG->ZIG_PLACA, oFt14N)

            oPrinter:Say(145, 420, "Pedido: ", oFt16B)
            oPrinter:Say(145, 490, cPedS, oFt14N)

        oPrinter:Say(400,  20, "Ass. Motorista:________________________________________________________________", oFt14N)

    oPrinter:EndPage()
    
    oPrinter:Setup()

    If oPrinter:nModalResult == PD_OK
        oPrinter:Preview()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} romVenda
    Impressão de romaneio de pedido de venda.
    @type  Static Function
    @author Everson
    @since 28/03/2022
    @version 01
/*/
Static Function romVenda(cTicket)
    
    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cPedS     := ""
    Local cProduto  := ""
    Local cDtFab    := ""
    Local cDtVld    := ""
    Local cTpRac    := ""
    Local cCarga    := ""
    Local cVersao   := ""
    Local aStatus   := RetSX3Box(GetSX3Cache("ZIG_INICIA", "X3_CBOX"),,,1)
    Local nStatus   := 0
    Local cStatus   := ""
    Local cPlacaFor := ""

    If ! U_ADFAT16A(ZIG->ZIG_ORDEM)
        Help(Nil, Nil, "Função iTktRc(ADFAT026R)", Nil, "Ordem de pesagem " + ZIG->ZIG_ORDEM + " não localizada.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("SC6")
    SC6->(DbSetOrder(17))
    If SC6->(DbSeek( FWxFilial("SC6") + ZIF->ZIF_NUMERO))
        cPedS := SC6->C6_NUM

    EndIf
    
    cProduto := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_DESSAG")))

    cCarga := ZIF->ZIF_ROTEIR
    cDtFab := DToC(ZIG->ZIG_DTPES2)
    cDtVld := DToC(ZIG->ZIG_DTPES2 + 30)
    cVersao:= Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_DESSAG" )

    If cFilAnt == "03"
        cCabec2 := "CNPJ: 60.037.058/0004-84 EST. S CARLOS A RIB BONITO, KM 157 - ZONA RURAL - (016) 2106-3501 - São Carlos"
        cTpRac := "Frango"

    ElseIf cFilAnt == "05"
        cCabec2 := "CNPJ:  60.037.058/0018-80 EST. S CARLOS A RIB BONITO, KM 154 - ZONA RURAL - (016)  - São Carlos"
        cTpRac := "Matrizes"

    EndIf

    oPrinter := FWMSPrinter():New(ZIF->ZIF_NUMERO, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)

    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro São Carlos", oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ordem de Carregamento", oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(120,  20, "Agrp/Ordem: ", oFt16B)
            oPrinter:Say(120, 100, Iif(!Empty(ZIF->ZIF_AGRUPA), ZIF->ZIF_AGRUPA, ZIF->ZIF_NUMERO), oFt14N)

            oPrinter:Say(145,  20, Iif(ZIF->ZIF_CLIFOR == "C", "Cliente: ", "Fornec:"), oFt16B)
            oPrinter:Say(145, 100,  ZIF->ZIF_FORNEC + "/" + ZIF->ZIF_LJFORN + " " + ZIF->ZIF_NMFOR, oFt14N)

        //Coluna 2.      

        //Coluna 3.
            oPrinter:Say(120, 420, "Emissão: ", oFt16B)
            oPrinter:Say(120, 490, DToC(ZIF->ZIF_DATA), oFt14N)

            cPlacaFor := Left(ZIF->ZIF_PLACA,3) + "-" + Right(ZIF->ZIF_PLACA,4)

            oPrinter:Say(165, 420, "Placa: ", oFt16B)
            oPrinter:Say(165, 490, cPlacaFor, oFt14N)

            oPrinter:FwMSBAR("CODE128" , 015, 036, cPlacaFor,oPrinter,.F. ,Nil ,Nil ,0.017 ,1 ,Nil ,Nil,"A" ,.F. )


        nStatus  := AScan(aStatus, {|x| Alltrim(cValToChar(x[2]))  == Alltrim(cValToChar(ZIG->ZIG_INICIA))})
        cStatus  := aStatus[nStatus,3]
        oPrinter:Say(165,  20, "Situação: ", oFt16B)
        oPrinter:Say(165, 100, cStatus, oFt14N)

        oPrinter:Say(205,  20, "Sequência: ", oFt16B)
        oPrinter:Say(205, 115, ZIG->ZIG_SEQTKT, oFt14N)
        
        oPrinter:Say(225,  20, "Produto: ", oFt16B)
        oPrinter:Say(225, 115, Iif(Empty(cProduto),ZIF->ZIF_PRDSAG,cProduto), oFt14N)

        oPrinter:Say(245,  20, "Quantidade: ", oFt16B)
        oPrinter:Say(245, 115, Alltrim(cValToChar(Transform(ZIF->ZIF_QUANT, "@E 99,999,999.999"))), oFt14N)

        oPrinter:Say(265,  20, "Cod. Protheus: ", oFt16B)
        oPrinter:Say(265, 115, ZIF->ZIF_PRDPRO, oFt14N)


        oPrinter:Say(305,  20, "Observações:", oFt16B)
        oPrinter:Say(340,  20, "____________________________________________________________________________", oFt14N)
        oPrinter:Say(380,  20, "____________________________________________________________________________", oFt14N)
        oPrinter:Say(420,  20, "____________________________________________________________________________", oFt14N)

        oPrinter:Say(500,  20, "________________________________", oFt14N)
        oPrinter:Say(525,  20, ZIF->ZIF_NMFOR, oFt14N)
        
        oPrinter:Say(500, 350, "____________________________", oFt14N)
        oPrinter:Say(525, 350, "Controle Expedição", oFt14N)

    oPrinter:EndPage()
    
    oPrinter:Setup()

    If oPrinter:nModalResult == PD_OK
        oPrinter:Preview()

    EndIf

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} romRacao
    Impressão de romaneio de ração.
    @type  Static Function
    @author Everson
    @since 31/05/2022
    @version 01
/*/
Static Function romRacao(cCP)
    
    //Variáveis.
    Local aArea := GetArea()
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local oPrinter  := Nil
    Local oFt24B    := TFont():New("Arial",24,24,,.T.,,,,.F.,.F.)
    Local oFt20B    := TFont():New("Arial",20,20,,.T.,,,,.F.,.F.)
    Local oFt16B    := TFont():New("Arial",16,16,,.T.,,,,.F.,.F.)
    Local oFt14B    := TFont():New("Arial",14,14,,.T.,,,,.F.,.F.)
    Local oFt14N    := TFont():New("Arial",16,16,,.F.,,,,.F.,.F.)
    Local oFt12N    := TFont():New("Arial",12,12,,.F.,,,,.F.,.F.)
    Local cTpRac    := ""
    Local cPlacaFor := ""
    Local cMotorista:= ""
    Local cFase     := ""
    Local cProd     := ""
    Local nLinha    := 0

    If cFilAnt == "03"
        cCabec2 := "CNPJ: 60.037.058/0004-84 EST. S CARLOS A RIB BONITO, KM 157 - ZONA RURAL - (016) 2106-3501 - São Carlos"
        cTpRac := "Frango"

    ElseIf cFilAnt == "05"
        cCabec2 := "CNPJ:  60.037.058/0018-80 EST. S CARLOS A RIB BONITO, KM 154 - ZONA RURAL - (016)  - São Carlos"
        cTpRac := "Matrizes"

    EndIf

    If ! U_ADFAT17U(cCP)
        Help(Nil, Nil, "Função romRacao(ADFAT026R)", Nil, "Controle de pátio " + cCP + " não localizado.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(1))
    ZIF->(DbGoTop())
    If ! ZIF->(DbSeek( FWxFilial("ZIF") + cCP ))
        Help(Nil, Nil, "Função romRacao(ADFAT026R)", Nil, "Não há ordem de pesagem vinculada ao controle de pátio " + cCP + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil

    Endif

    DbSelectArea("ZVC")
    ZVC->(DbSetOrder(1))
    ZVC->(DbGoTop())
    If ZVC->(DbSeek( FWxFilial("ZVC") + ZIB->ZIB_MOTORI ))
        cMotorista := Alltrim(cValToChar(ZVC->ZVC_MOTORI))

    EndIf

    oPrinter := FWMSPrinter():New(ZIF->ZIF_NUMERO, IMP_PDF, lAdjustToLegacy, , lDisableSetup,,,,,,,,2)

    oPrinter:StartPage()

        oPrinter:SayBitmap (5, 20, "\img_ticket_racao\logotipo.png", 56.5, 50)
        oPrinter:SayAlign(30, 20, "Adoro São Carlos", oFt24B, 555, 30,,2)
        oPrinter:Say(50, 480, DToC(Date()) + " " + Time(), oFt12N)

        oPrinter:SayAlign(55, 20, cCabec2, oFt12N, 555, 20,,2,0)
        oPrinter:Line(70, 20, 070, 555)
        oPrinter:SayAlign(75, 20, "Ordem de Carregamento Detalhada", oFt20B, 555, 100,,2)

        //Coluna 1.
            oPrinter:Say(120,  20, "Roteiro: ", oFt16B)
            oPrinter:Say(120, 100, ZIF->ZIF_ROTEIR, oFt14N)

            oPrinter:Say(145,  20, "Motorista:", oFt16B)
            oPrinter:Say(145, 100,  cMotorista, oFt14N)

            oPrinter:Say(170,  20, "Caixas:", oFt16B)
            oPrinter:Say(170, 100, getCxCad(ZIB->ZIB_PLACA), oFt14N)

        //Coluna 2.      

        //Coluna 3.
            oPrinter:Say(120, 420, "Emissão: ", oFt16B)
            oPrinter:Say(120, 490, DToC(ZIF->ZIF_DATA), oFt14N)

            cPlacaFor := Left(ZIB->ZIB_PLACA,3) + "-" + Right(ZIB->ZIB_PLACA,4)

            oPrinter:Say(165, 420, "Placa: ", oFt16B)
            oPrinter:Say(165, 490, cPlacaFor, oFt14N)
            oPrinter:FwMSBAR("CODE128" , 015, 036, cPlacaFor,oPrinter,.F. ,Nil ,Nil ,0.017 ,1 ,Nil ,Nil,"A" ,.F. )

        oPrinter:Say(245, 395, "|", oFt14B)
        oPrinter:Say(245, 400, "Expedição", oFt14B)
        
        oPrinter:Say(265, 020, "Cod. Externo", oFt14B)
        oPrinter:Say(265, 100, "Fase", oFt14B)
        oPrinter:Say(265, 140, "Granja", oFt14B)
        oPrinter:Say(265, 210, "Caixas", oFt14B)
        oPrinter:Say(265, 270, "Produto", oFt14B)
        oPrinter:Say(265, 350, "Quant.", oFt14B)
        oPrinter:Say(265, 395, "|", oFt14B)

        oPrinter:Say(265, 400, "Prod", oFt14B)
        oPrinter:Say(265, 440, "Versão", oFt14B)
        oPrinter:Say(265, 490, "Lote", oFt14B)
        oPrinter:Say(265, 520, "Silo", oFt14B)
        oPrinter:Say(265, 550, "Lacre", oFt14B)

        oPrinter:Line(270, 020, 270, 590)

        
        nLinha := 285
        While ! ZIF->(Eof()) .And. ZIF->ZIF_FILIAL == FWxFilial("ZIF") .And. ZIF->ZIF_CTPATI == cCP
            
            cFase  := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_SGPSAG" )))
            cProd  := Alltrim(cValToChar(Posicione("ZIM", 1, FWxFilial("ZIM") + ZIF->ZIF_PRDSAG, "ZIM_DESSAG" )))
            cQuant := Alltrim(cValToChar(Transform(ZIF->ZIF_QUANT, "@E 999,999,999")))

            If ! U_ADFAT32G(ZIF->ZIF_ORDRAC)
                 ZIF->(DbSkip())
                 Loop

            EndIf

            oPrinter:Say(nLinha, 020, ZIF->ZIF_NUMERO, oFt12N)
            oPrinter:Say(nLinha, 100, cFase, oFt12N)
            oPrinter:Say(nLinha, 140, ZIR->ZIR_DESGRJ, oFt12N)
            oPrinter:Say(nLinha, 210, "", oFt12N)
            oPrinter:Say(nLinha, 270, cProd, oFt12N)
            oPrinter:Say(nLinha, 350, cQuant, oFt12N)
            oPrinter:Say(nLinha, 395, "|", oFt14B)

            nLinha += 5

            oPrinter:Line(nLinha, 020, nLinha, 590)

            nLinha += 25

            ZIF->(DbSkip())

        End

        nLinha += 30

        oPrinter:Say(nLinha,  20, "Observações:", oFt16B)
        oPrinter:Say(nLinha+20,  20, "____________________________________________________________________________", oFt14N)
        oPrinter:Say(nLinha+40,  20, "____________________________________________________________________________", oFt14N)
        oPrinter:Say(nLinha+60,  20, "____________________________________________________________________________", oFt14N)

        oPrinter:Say(nLinha+90,  20, "________________________________", oFt14N)
        oPrinter:Say(nLinha+130,  20, cMotorista, oFt14N)
        
        oPrinter:Say(nLinha+90, 350, "____________________________", oFt14N)
        oPrinter:Say(nLinha+130, 350, "Controle Expedição", oFt14N)

    oPrinter:EndPage()
    
    oPrinter:Setup()

    If oPrinter:nModalResult == PD_OK
        oPrinter:Preview()

    EndIf

    RestArea(aArea)

Return Nil
