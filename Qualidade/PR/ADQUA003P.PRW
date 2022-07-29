#Include "Totvs.ch"
#Include "FWMVCDef.ch"

Static cTbMast := "ZIF"
Static cTitulo := "Lote Manual do Produto"

/*/{Protheus.doc} User Function ADQUA003P
    Lote Manual do Produto
    Cad Lote Manual
    Chamado 18465.
    @type  Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
User Function ADQUA003P() // U_ADQUA003P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADQUA003P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:SetFilterDefault(" " + cTbMast + "_FILIAL = '" + FWxFilial(cTbMast) + "' ")

    oBrowse:SetMenuDef("ADQUA003P")

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
    Local aRotina := {}

    ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ADFAT016P" 	OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Apontar lote" ACTION "U_ADQUA31()" 	    OPERATION 10 ACCESS 0

Return aRotina
/*/{Protheus.doc} ADQUA31
    Atualização do lote do produto.
    @type  User Function
    @author Everson
    @since 27/12/2021
    @version 01
/*/
User Function ADQUA31()

    //Variáveis.
    Local aArea     := GetArea()
    Local cNmOrdem  := Iif(!Empty(ZIF->ZIF_AGRUPA), ZIF->ZIF_AGRUPA, ZIF->ZIF_NUMERO)
    Local lAgrupa   := Iif(!Empty(ZIF->ZIF_AGRUPA), .T., .F.)
    Local cLote     := ""

    If ZIF->ZIF_TPMOVI <> "E" //Ordem de entrada.
        MsgInfo("Tipo de ordem de pesagem inválida.", "Função ADQUA31(ADQUA003P)")
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    If ZIG->( DbSeek( FWxFilial("ZIG") + cNmOrdem ) )
        If ZIG->ZIG_INICIA <> "1"
            MsgInfo("Ordem de pesagem não pode ter o lote alterado.", "Função ADQUA31(ADQUA003P)")
            RestArea(aArea)
            Return Nil

        EndIf

    EndIf

    If ! Pergunte("ADQUA003P", .T.)
        RestArea(aArea)
        Return Nil

    EndIf

    cLote := MV_PAR01

    If Empty(cLote)
        MsgInfo("Necessário informar o lote do produto.", "Função ADQUA31(ADQUA003P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! U_ADFAT18D(cLote, ZIF->ZIF_PRDSAG , ZIF->ZIF_PRDPRO)
        RestArea(aArea)
        Return Nil

    EndIf

    If ! lAgrupa
        U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_LOTE", cLote, "")

    Else
  
        If ! U_ADFAT16F(cNmOrdem)
            MsgInfo("Agrupador " + cNmOrdem + " não localizado.", "Função ADQUA31(ADQUA003P)")
            RestArea(aArea)
            Return Nil

        EndIf

        Begin Transaction

            While ! ZIF->(Eof()) .And. FWxFilial("ZIF") == ZIF->ZIF_FILIAL .And.;
                  ZIF->ZIF_AGRUPA == cNmOrdem 
                  
                  
                If ZIF->ZIF_PRDPRO == ZI8->ZI8_PRDPRT

                    If ! U_ADFAT165(ZIF->ZIF_NUMERO, "ZIF_LOTE", cLote, "")
                        DisarmTransaction()
                        Break

                    EndIf

                EndIf

                ZIF->(DbSkip())

            End

        End Transaction

    EndIf

    RestArea(aArea)

Return Nil
