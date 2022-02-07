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
    @type  Static Function
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

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    If ZIG->( DbSeek( FWxFilial("ZIG") + cNmOrdem ) )
        If ZIG->ZIG_INICIA $"3/4/5" //Pesagem final, pesagem sequestrada, sequestro liberado.
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

    DbSelectArea("ZI8")
    ZI8->(DbSetOrder(1))
    If ! ZI8->( DbSeek( FWxFilial("ZI8") + cLote ) )
        MsgInfo("Lote não localizado " + cLote + ".", "Função ADQUA31(ADQUA003P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ZI8->ZI8_PRDPRT <> ZIF->ZIF_PRDPRO
        MsgInfo("Lote " + cLote + " inválido para o produto " + ZIF->ZIF_PRDPRO + ".", "Função ADQUA31(ADQUA003P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If ! lAgrupa
        U_ADFT165(ZIF->ZIF_NUMERO, "ZIF_LOTE", cLote, "")

    Else
        DbSelectArea("ZIF")
        ZIF->(DbSetOrder(3))
        If ! ZIF->( DbSeek( FWxFilial("ZIF") + cNmOrdem ) )
            MsgInfo("Ordem de pesagem não localizada " + cNmOrdem + ".", "Função ADQUA31(ADQUA003P)")
            RestArea(aArea)
            Return Nil

        EndIf

        Begin Transaction

            While ! ZIF->(Eof()) .And. FWxFilial("ZIF") == ZIF->ZIF_FILIAL .And.;
                  ZIF->ZIF_AGRUPA == cNmOrdem 
                  
                  
                If ZIF->ZIF_PRDPRO == ZI8->ZI8_PRDPRT

                    If ! U_ADFT165(ZIF->ZIF_NUMERO, "ZIF_LOTE", cLote, "")
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
