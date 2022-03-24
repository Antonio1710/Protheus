#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} ADFAT033P
    Aprovação os registros de ordem de carregamento de ração.
    Aprovação Ordem de Ração
    Chamado 18465.
    @type  User Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
User Function ADFAT033P()

    //Variáveis.
    Local aArea     := GetArea()
    Local oJanela   := Nil
    Local oPnMaster := Nil
    Local aOrdens   := {}
    Local oOrdens   := Nil

    carOrd(@aOrdens)

    oJanela			  := MsDialog():Create()
	oJanela:cName     := "oJanela"
	oJanela:cCaption  := "Aprovação de Ordens Carregamento de Ração"
	oJanela:nLeft     := 34
	oJanela:nTop      := 222
	oJanela:nWidth    := 1200
	oJanela:nHeight   := 600
	oJanela:lShowHint := .F.
	oJanela:lCentered := .T.

        TButton():New(005, 520,"Reprovar" , oJanela, {|| U_ADFAT33A(aOrdens, "3"), oJanela:End() },035,011,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New(005, 560,"Aprovar"  , oJanela, {|| U_ADFAT33A(aOrdens, "2"), oJanela:End() },035,011,,,.F.,.T.,.F.,,.F.,,,.F. )

        oPnMaster := TPanel():New(020,0,,oJanela,,,,,,600,260)

        oOrdens := FwBrowse():New()
        oOrdens:SetOwner(oPnMaster)
        oOrdens:SetDataArray(.T.)
        oOrdens:SetArray(aOrdens)
        oOrdens:DisableConfig()
        oOrdens:DisableReport()

        oOrdens:AddMarkColumns({|| Iif(aOrdens[oOrdens:nAt,01], "LBOK", "LBNO")},;
            {|| selecReg(oOrdens, aOrdens)},; 
            {|| selecTReg(oOrdens, aOrdens) })
    
        oOrdens:addColumn({"Numero"   , {||aOrdens[oOrdens:nAt,02]}, "C", "@!", 1, 10    , , .F. , , .F.,, "aOrdens[oOrdens:nAt,02]",, .F., .T., , "ETDESPES1"})
        oOrdens:addColumn({"Granja"   , {||aOrdens[oOrdens:nAt,03]}, "C", "@!", 1, 05    , , .F. , , .F.,, "aOrdens[oOrdens:nAt,03]",, .F., .T., , "ETDESPES2"})
        oOrdens:addColumn({"Granjada" , {||aOrdens[oOrdens:nAt,04]}, "C", "@!", 1, 15    , , .F. , , .F.,, "aOrdens[oOrdens:nAt,04]",, .F., .T., , "ETDESPES3"})
        oOrdens:addColumn({"Produto"  , {||aOrdens[oOrdens:nAt,05]}, "C", "@!", 1, 060   , , .F. , , .F.,, "aOrdens[oOrdens:nAt,05]",, .F., .T., , "ETDESPES4"})
        
        oOrdens:setEditCell( .T. , { || .T. } )
    
        oOrdens:Activate(.T.)

    oJanela:Activate(,,,.T.,{||.T.},, {|| })

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} carOrd
    Carrega ordens de ração pendentes de aprovação.
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
Static Function carOrd(aOrdens)

    //Variáveis.
    Local aArea  := GetArea()
    Local cQuery := " SELECT * FROM " + RetSqlName("ZIR") + " AS ZIR WHERE ZIR_FILIAL = '" + FWxFilial("ZIR") + "' AND ZIR_STATUS = '1' AND ZIR.D_E_L_E_T_ = '' "

    aOrdens := {}
    
    If Select("D_ORD") > 0
        D_ORD->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "D_ORD"
    DbSelectArea("D_ORD")
    While ! D_ORD->(Eof())
        Aadd(aOrdens,{.F., D_ORD->ZIR_NUMERO, D_ORD->ZIR_INTCOD, D_ORD->ZIR_DESGRJ, D_ORD->ZIR_DESC})
        D_ORD->(DbSkip())
    End
    D_ORD->(DbCloseArea())

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT33A
    Processa aprovação.
    @type  Static Function
    @author Everson
    @since 21/02/2022
    @version 01
/*/
User Function ADFAT33A(aOrdens, cStatus)

    //Variáveis.
    Local aArea := GetArea()
    Local cMsg  := Iif(cStatus == "2", "aprovar", "reprovar")
    Local nAux  := 1

    If ! MsgYesNo("Deseja " + cMsg + " os registros selecionados?","Função ADFAT33A(ADFAT033P)")
        RestArea(aArea)
        Return Nil
        
    EndIf

    For nAux := 1 To Len(aOrdens)
        U_ADFAT32A(aOrdens[nAux][2], cStatus)

    Next nAux

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} selecReg
    Marca registro.
    @type  Static Function
    @author Everson
    @since 22/02/2022
    @version 01
/*/
Static Function selecReg(oBrowse, aArquivo)

    aArquivo[oBrowse:nAt,01] := !aArquivo[oBrowse:nAt,1]
    oBrowse:Refresh()

Return Nil
/*/{Protheus.doc} selecTReg
    Marca todos os registros.
    @type  Static Function
    @author Everson
    @since 22/02/2022
    @version 01
/*/
Static Function selecTReg(oBrowse, aArquivo)

    //Variáveis.
    Local nAux := 1

    For nAux := 1 to len(aArquivo)
        aArquivo[nAux,01] := !aArquivo[nAux,01]

    Next

    oBrowse:Refresh()

Return Nil
