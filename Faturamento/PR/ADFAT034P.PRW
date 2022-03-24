#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "Topconn.ch"

Static cTbMast  := "ZIR"
Static cTitulo  := "Roteiro de Ordens de Carregamento de Ração"
Static cOrdSelec:= "XXXXXX"

/*/{Protheus.doc} User Function ADFAT034P
    Roteiro de ordens de carregamento de ração.
    Rot Car Racao
    Chamado 18465.
    @type  Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT034P() // U_ADFAT034P()

    //Variáveis.
    Local oBrowse := FwLoadBrw("ADFAT034P")

    oBrowse:Activate()

Return Nil
/*/{Protheus.doc} BrowseDef
    @type  Static Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
Static Function BrowseDef()

    //Variáveis.
    Local oBrowse := FwMBrowse():New()
    Local cFilter := " ZIR_ORAGRP <> '' "

    (cTbMast)->(DbSetFilter( {|| &cFilter }, cFilter ))

    oBrowse:SetAlias(cTbMast)
    oBrowse:SetDescription(cTitulo)

    oBrowse:AddLegend("ZIR->ZIR_STATUS = '1'", "Blue",  "Pendente")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '2'", "Green", "Aprovada")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '3'", "Black", "Não aprovada")
    oBrowse:AddLegend("ZIR->ZIR_STATUS = '4'", "Red",   "Pesada")
    oBrowse:SetSeeAll(.F.)

Return oBrowse
/*/{Protheus.doc} MenuDef
    @type  Static Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
Static Function MenuDef()

    //Variáveis.
	Local aRotina 	:= {}

	ADD OPTION aRotina TITLE "Pesquisar"    ACTION "PesqBrw"          	OPERATION 1   ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "U_ADFAT34A(2)" 	    OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina TITLE "Incluir" 	    ACTION "U_ADFAT34A(3)" 	    OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"      ACTION "U_ADFAT34A(4)" 	    OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE "Excluir" 	    ACTION "U_ADFAT34A(5)" 	    OPERATION MODEL_OPERATION_DELETE   ACCESS 0

Return aRotina
/*/{Protheus.doc} ADFAT34A
    Validação para alteração e exclusão de registro.
    @type  User Function
    @author Everson
    @since 20/12/2021
    @version 01
/*/
User Function ADFAT34A(nOpc)

    //Variáveis.
    Local aArea     := GetArea()
    Local oJanela   := Nil
    Local aColsVcPt := {}
    Local dData     := Iif(nOpc == 3, Date(), ZIR->ZIR_DTCAR)
    Local cPlaca    := Iif(nOpc == 3, Space(7), ZIR->ZIR_PLACA)
    Local oPlaca    := Nil
    Local oRoteiro  := Nil
    Local oDtCar    := Nil
    Local lEditTg   := .T.
    Local oConfirm  := Nil
    
    Private cCarga  := Iif(nOpc == 3, GetSxeNum("ZIR","ZIR_NUMERO"), ZIR->ZIR_ORAGRP)
    Private oVecPt  := Nil
    Private aHVcPt  := {}

    cOrdSelec:= "XXXXXX"

    If nOpc == 5 .And. ! U_ADFAT34H(cCarga)
        MsgInfo("Roteiro possui ordem de pesagem vinculada a ticket de pesagem, o roteiro não pode ser excluído.","Função ADFAT34A(ADFAT034P)")
        RestArea(aArea)
        Return Nil

    EndIf

    If nOpc == 2 .Or. nOpc == 5
        lEditTg := .F.

    ElseIf nOpc = 4
        lEditTg := U_ADFAT34H(cCarga)

    EndIf

    oJanela			  := MsDialog():Create()
	oJanela:cName     := "oJanela"
	oJanela:cCaption  := cTitulo
	oJanela:nLeft     := 34
	oJanela:nTop      := 222
	oJanela:nWidth    := 1200
	oJanela:nHeight   := 600
	oJanela:lShowHint := .F.
	oJanela:lCentered := .T.

        oRoteiro := TGet():New(005,005,{|u| if( PCount() > 0, cCarga := u, cCarga ) } ,oJanela,50,010,,,,,,,,.T.,,,,,,,,,,"cCarga",,,,,,,"Roteiro",1)
        oRoteiro:bWhen := {|| .F. }

        oPlaca := TGet():New(005,060,{|u| if( PCount() > 0, cPlaca := u, cPlaca ) } ,oJanela,050,010,,,,,,,,.T.,,,,,,,,,,"cPlaca",,,,,,,"Placa",1)
        oPlaca:cF3 := "ZV4"
        oPlaca:bWhen := {|| lEditTg }
        oPlaca:bValid := {|| Iif(Empty(cPlaca), .T., vldCaixa(cPlaca) ) }
        
        oDtCar := TGet():New(005,115,{|u| if( PCount() > 0, dData := u, dData ) } ,oJanela,050,010,,,,,,,,.T.,,,,,,,,,,"dData",,,,,,,"Dt Carregamento",1)
        oDtCar:bWhen := {|| lEditTg }

        Aadd(aHVcPt,{" ","LEG"    	,"@BMP"      ,001, 0,.T.,"","","","R","","",.F.,"V","","","",""})
        Aadd(aHVcPt,{"Número" 	    ,"NUMER" ,"" ,TamSx3("ZIR_NUMERO")[1], 0,"","" ,"C","ZIRCAR",""})
        Aadd(aHVcPt,{"Granjada" 	,"GRJDA" ,"" ,TamSx3("ZIR_CODGRJ")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Desc Granjada","DGRJDA","" ,TamSx3("ZIR_DESGRJ")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Granja" 	    ,"GRANJ" ,"" ,TamSx3("ZIR_INTCOD")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Prd SAG" 	    ,"PRDS"  ,"" ,TamSx3("ZIR_PRDSAG")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Prd Protheus" ,"PRDT"  ,"" ,TamSx3("ZIR_PRDPRO")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Descrição"    ,"DEST"  ,"" ,TamSx3("ZIR_DESC")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Quantidade" 	,"QTD"   ,"@E 99,999,999,999.999" ,TamSx3("ZIR_QUANT")[1], TamSx3("ZIR_QUANT")[2],"","" ,"N","",""})
        Aadd(aHVcPt,{"Ord Pesagem"  ,"ORDPES","" ,TamSx3("ZIR_ORDEM")[1], 0,"","" ,"C","",""})
        Aadd(aHVcPt,{"Tkt Pesagem"  ,"TKTPES","" ,TamSx3("ZIG_ORDEM")[1], 0,"","" ,"C","",""})
        			
        oVecPt := MsNewGetDados():New(030,005,260,595,GD_INSERT + GD_UPDATE + GD_DELETE,"U_ADFAT34E()","Allwaystrue()","",Iif(nOpc == 1 .Or. nOpc == 5,{},{"NUMER"}),Nil,999,"U_ADFAT34F()",Nil,"U_ADFAT34G()",oJanela,aHVcPt,@aColsVcPt)

        TButton():New(270,005,"Legenda" ,oJanela,{|| legenda() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        TButton():New(270,510,"Fechar"  ,oJanela,{|| Iif(nOpc == 3, RollbackSx8(), Nil), oJanela:End() },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        
        oConfirm := TButton():New(270,555,"Confirmar"  ,oJanela,{|| Iif(U_ADFAT34B(nOpc, oVecPt, aHVcPt, cCarga, cPlaca, dData), Eval({|| Iif(nOpc == 3, ConfirmSx8(), Nil), oJanela:End()}) ,Nil) },040,010,,,.F.,.T.,.F.,,.F.,,,.F. )
        If nOpc == 2
            oConfirm:Disable()

        EndIf

    oJanela:Activate(,,,.T.,{||.T.},, {|| Iif(nOpc <> 3, carCarg(oVecPt, aHVcPt, cCarga), Nil) })

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT34H
    Verifica se o roteiro não possui ordem com ticket de pesagem.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT34H(cCarga)

	//Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(2))
    If ZIR->( DbSeek( FWxFilial("ZIR") +  cCarga ))

        While ! ZIR->(Eof()) .And. ZIR->ZIR_FILIAL == FWxFilial("ZIR") .And. ZIR->ZIR_ORAGRP == cCarga

            If ! U_ADFAT32E(ZIR->ZIR_ORDEM, "", ZIR->ZIR_NUMERO)
                lRet := .F.
                Exit

            EndIf

            ZIR->(DbSkip())

        End

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} legenda
    Legenda.
    @type  Static Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
Static Function legenda()

	//Variáveis.
	Local aLegenda := {}

	//Aadd(aLegenda,{"BR_VERDE"   ,"Sem vínculo" })
	Aadd(aLegenda,{"BR_AMARELO" ,"Vinculada à ordem de pesagem"})
	Aadd(aLegenda,{"BR_VERMELHO","Vinculada a ticket de pesagem"})

	BrwLegenda("Agrupador", "Legenda", aLegenda)

Return Nil
/*/{Protheus.doc} carCarg
    Carrega Dados da carga.
    @type  Static Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
Static Function carCarg(oVecPt, aHVcPt, cCarga)

    //Variáveis.
    Local aArea     := GetArea()
    Local oCor      := Nil
    Local cTicket   := ""

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(2))
    If ! ZIR->( DbSeek( FWxFilial("ZIR") +  cCarga) )
        RestArea(aArea)
        Return Nil

    EndIf

    DbSelectArea("ZIG")
    ZIG->(DbSetOrder(2))
    ZIG->(DbGoTop())

    oVecPt:aCols := {}

    While ! ZIR->(Eof()) .And. ZIR->ZIR_FILIAL == FWxFilial("ZIR") .And. ZIR->ZIR_ORAGRP == cCarga

        cTicket := ""
        
        Aadd(oVecPt:aCols , Array(Len(aHVcPt) + 1) )
		oVecPt:aCols[Len(oVecPt:aCols), Len(oVecPt:aCols[1]) ] := .F.

        If ! Empty(ZIR->ZIR_ORDEM)

            If ZIG->( DbSeek( FWxFilial("ZIG") + ZIR->ZIR_ORDEM ) )
                oCor := LoadBitmap( GetResources(), "BR_VERMELHO")
                cTicket := ZIG->ZIG_NUMERO

            Else
                oCor := LoadBitmap( GetResources(), "BR_AMARELO")

            EndIf

        Else
            //oCor := LoadBitmap( GetResources(), "BR_VERDE")

        EndIf

		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "LEG" })]	    := oCor
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]	:= ZIR->ZIR_NUMERO
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "GRJDA" })]	:= ZIR->ZIR_CODGRJ
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "DGRJDA" })]	:= ZIR->ZIR_DESGRJ
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "GRANJ"})]	:= ZIR->ZIR_INTCOD
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PRDS" })]	:= ZIR->ZIR_PRDSAG
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "PRDT" })]	:= ZIR->ZIR_PRDPRO
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "DEST" })]	:= ZIR->ZIR_DESC
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "QTD" })] 	:= ZIR->ZIR_QUANT
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDPES" })] 	:= ZIR->ZIR_ORDEM
		oVecPt:aCols[Len(oVecPt:aCols),Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TKTPES" })] 	:= cTicket

        ZIR->(DbSkip())

    End

    oVecPt:Refresh()

    RestArea(aArea)

Return Nil
/*/{Protheus.doc} ADFAT34B
    Salva número da carga.
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT34B(nOpc, oVecPt, aHVcPt, cCarga, cPlaca, dData)

    //Variáveis.
    Local aArea     := GetArea()
    Local nAux      := 1
    Local cOrdemC   := ""
    Local cOrdemP   := ""
    Local lRet      := .T.
    Local nTotReg   := 0
    Local lTicket   := .F.
    Local cOrdInC   := ""
    
    If Len(oVecPt:aCols) <= 0
        MsgInfo("Não há registros a serem processados.","Função ADFAT34B(ADFAT034P)")
        RestArea(aArea)
        Return .F.

    EndIf

    If Empty(cCarga) .Or. Empty(cPlaca) .Or. Empty(dData)
        MsgInfo("Por favor, verifique a carga, placa e data de carregamento.","Função ADFAT34B(ADFAT034P)")
        RestArea(aArea)
        Return .F.

    EndIf

    Begin Transaction

        If nOpc == 5 .And. ! U_ADFAT34H(cCarga)
            MsgInfo("Roteiro possui ordem de pesagem vinculada a ticket de pesagem, o roteiro não pode ser excluído.","Função ADFAT34B(ADFAT034P)")
            DisarmTransaction()
            lRet := .F.
            Break

        EndIf

        For nAux := 1 To Len(oVecPt:aCols)
            
            cOrdemC := oVecPt:aCols[nAux,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]
            cOrdemP := oVecPt:aCols[nAux,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDPES"})]
            lTicket := U_ADFAT32E(cOrdemP, "", cOrdemC) 

            If  ! oVecPt:aCols[nAux, Len(oVecPt:aCols[1])] .And. ! vldOdAb(cPlaca, cCarga)
                DisarmTransaction()
                lRet := .F.
                Break

            EndIf

            If lTicket .And. ! Empty(cOrdemC) .And. (nOpc <> 5 .And. ! oVecPt:aCols[nAux, Len(oVecPt:aCols[1])]) //Atribui ordem de carregamento ao roteiro.
                
                If ! U_ADFAT32C(cOrdemC, cCarga, cPlaca, dData)
                    DisarmTransaction()
                    lRet := .F.
                    Break

                EndIf

                If !Empty(cOrdemP) .And. ! U_ADFAT166(cOrdemP) //Exclusão de ordem de pesagem.
                    DisarmTransaction()
                    lRet := .F.
                    Break

                EndIf
                
                cOrdInC += cOrdemC + "/"
                nTotReg++

            ElseIf lTicket .And. ! Empty(cOrdemC) .And. (nOpc == 5 .Or. oVecPt:aCols[nAux, Len(oVecPt:aCols[1])]) //Exclusão de ordem de carregamento.

                If ! U_ADFAT32C(cOrdemC, "", "", SToD(" / / "))
                    DisarmTransaction()
                    lRet := .F.
                    Break

                EndIf
                
                If !Empty(cOrdemP) .And. ! U_ADFAT166(cOrdemP) //Exclusão de ordem de pesagem.
                    DisarmTransaction()
                    lRet := .F.
                    Break

                EndIf

                nTotReg++

            ElseIf ! lTicket //Ordem de carregamento que não pode ser alterada/excluída.
                nTotReg++

            EndIf

        Next nAux

        //Verifica se há ordens de carregamento que devem ser excluídas do roteiro.
        If nOpc == 4 .And. ! chkInt(cCarga, cOrdInC)
            DisarmTransaction()
            lRet := .F.
            Break

        EndIf

    End Transaction

    If nTotReg <= 0
        RestArea(aArea)
        Return .F.

    EndIf

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkInt
    Verifica se há ordens de carregamento não pesadas em roteiros anteriores.
    @type  Static Function
    @author Everson
    @since 07/03/2022
    @version 01
/*/
Static Function vldOdAb(cPlaca, cCarga)

    //Variáveis
    Local aArea   := GetArea()
    Local lRet    := .T.
    Local cQuery  := ""
    Local cCp     := ""
    Local cStatus := ""

    If Empty(cPlaca)
        RestArea(aArea)
        Return .T.

    EndIf

    cQuery := ""
    cQuery += " SELECT  " 
    cQuery += " ZIR_ORAGRP, ZIR_NUMERO, ZIR_ORDEM " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("ZIR") + " (NOLOCK) AS ZIR " 
    cQuery += " WHERE " 
    cQuery += " ZIR_FILIAL = '" + FWxFilial("ZIR") + "' " 
    cQuery += " AND ZIR_PLACA = '" + cPlaca + "' " 
    cQuery += " AND ZIR_ORAGRP <> '" + cCarga + "' " 
    cQuery += " AND ZIR_ORAGRP <> '' " 
    cQuery += " AND ZIR_STATUS <> '4' " 
    cQuery += " AND ZIR.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZIR_ORAGRP, ZIR_NUMERO " 

    If Select("V_RTPL") > 0
        V_RTPL->(DbCloseArea())

    EndIf

    TcQuery cQuery New Alias "V_RTPL"
    DbSelectArea("V_RTPL")
    If ! V_RTPL->(Eof())

        While ! V_RTPL->(Eof())

            If ! Empty(V_RTPL->ZIR_ORDEM)

                cCp := Posicione("ZIF", 2, FWxFilial("ZIF") + V_RTPL->ZIR_ORDEM, "ZIF_CTPATI")

                cStatus := Posicione("ZIB", 1, FWxFilial("ZIB") + cCp, "ZIB_STATUS")

                If ! Empty(cCp) .And. ! Empty(cStatus) .And. ! (cStatus $"5/6")
                    lRet := .F.
                    MsgInfo("Placa " + cPlaca + " possui roteiro " + V_RTPL->ZIR_ORAGRP + " com ordem de carregamento " + V_RTPL->ZIR_NUMERO + " não pesada.","Função vldOdAb(ADFAT034P)")
                    Exit

                EndIf

            EndIf
            
            V_RTPL->(DbSkip())

        End

    EndIf
    V_RTPL->(DbCloseArea())

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} chkInt
    Verifica se há ordens de carregamento que devem ser excluídas do roteiro.
    @type  Static Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
Static Function chkInt(cCarga, cOrdInC)

    //Variáveis.
    Local aArea := GetArea()
    Local lRet  := .T.

    DbSelectArea("ZIR")
    ZIR->(DbSetOrder(2))
    ZIR->(DbGoTop())

    Begin Transaction

        If ZIR->(DbSeek( FWxFilial("ZIR") + cCarga ))
            
            While ! ZIR->(Eof()) .And. ZIR->ZIR_FILIAL == FWxFilial("ZIR") .And. ZIR->ZIR_ORAGRP == cCarga

                If !( ZIR->ZIR_NUMERO $cOrdInC) .And. U_ADFAT32E(ZIR->ZIR_ORDEM, "", ZIR->ZIR_NUMERO)

                    If ! U_ADFAT32C(ZIR->ZIR_NUMERO, "", "", SToD(" / / "))
                        DisarmTransaction()
                        lRet := .F.
                        Break

                    EndIf

                    If ! Empty(ZIR->ZIR_ORDEM) .And. ! U_ADFAT166(ZIR->ZIR_ORDEM) //Exclusão de ordem de pesagem.
                        DisarmTransaction()
                        lRet := .F.
                        Break

                    EndIf

                EndIf

                ZIR->(DbSkip())

            End

        EndIf

    End Transaction

    RestArea(aArea)

Return lRet
/*/{Protheus.doc} ADFAT34C
    Retorna ordens de carregamento de ração já selecionadas.
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT34D()
Return cOrdSelec
/*/{Protheus.doc} ADFAT34C
    Retorna ordens de carregamento de ração já selecionadas.
    @type  User Function
    @author Everson
    @since 23/02/2022
    @version 01
/*/
User Function ADFAT34E()

    //Variáveis.
    Local lRet  := .T.
    Local cNumero := oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]

    If ! cNumero $cOrdSelec
        cOrdSelec += cNumero + "/"

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT34F
    Validação de campo.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT34F()

    //Variáveis.
    Local lRet     := .T.
    Local cOrdemC  := oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]
    Local cOrdemP  := oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDPES" })]
    Local cTicket  := oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TKTPES" })]

    DbSelectArea("ZIF")
    ZIF->(DbSetOrder(8))
    ZIF->(DbGoTop())
    If ZIF->( DbSeek( FWxFilial("ZIF") + cCarga))

        If U_ADFAT17L(ZIF->ZIF_CTPATI)
            lRet := .F.
            MsgInfo("O controle de pátio " + ZIF->ZIF_CTPATI + " está encerrado.", "Função ADFAT34F(ADFAT034P)")

        EndIf

    EndIf

    If lRet .And. ! U_ADFAT32E(cOrdemP, cTicket, cOrdemC)
        lRet := .F.
        MsgInfo("Há ticket de pesagem vinculado à ordem de pesagem.", "Função ADFAT34F(ADFAT034P)")

    EndIf

Return lRet
/*/{Protheus.doc} ADFAT34G
    Validação de exclusão.
    @type  User Function
    @author Everson
    @since 24/02/2022
    @version 01
/*/
User Function ADFAT34G()

    //Variáveis.
    Local lRet := .T.
    Local cOrdemC   := oVecPt:aCols[oVecPt:nAt,Ascan(aHVcPt,{|x| AllTrim(x[2]) == "NUMER" })]
    Local cOrdemP   := oVecPt:aCols[oVecPt:nAt, Ascan(aHVcPt,{|x| AllTrim(x[2]) == "ORDPES" })]
    Local cTicket   := oVecPt:aCols[oVecPt:nAt, Ascan(aHVcPt,{|x| AllTrim(x[2]) == "TKTPES" })]
    Local lDeletado := oVecPt:aCols[oVecPt:nAt, Len(oVecPt:aCols[1])]
    
    If ! lDeletado .And. ! U_ADFAT32E(cOrdemP, cTicket, cOrdemC)
        lRet := .F.
        MsgInfo("Há ticket de pesagem vinculado à ordem de pesagem.", "Função ADFAT34G(ADFAT034P)")

    EndIf
    
Return lRet
/*/{Protheus.doc} vldCaixa
    Validação de placa e caixa de transporte.
    @type  User Function
    @author Everson
    @since 18/03/2022
    @version 01
/*/
Static Function vldCaixa(cPlaca)

    //Variáveis.
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local nTotCp    := 0

    lRet := ExistCpo("ZV4", cPlaca)

    If lRet
        DbSelectArea("ZIX")
        ZIX->(DbSetOrder(1))
        If ZIX->( DbSeek( FWxFilial("ZIX") + cPlaca ) )

            While ! ZIX->(Eof()) .And. ZIX->ZIX_FILIAL == FWxFilial("ZIX") .And. ZIX->ZIX_PLACA == cPlaca

                nTotCp += ZIX->ZIX_CAPACI

                ZIX->(DbSkip())

            End

        EndIf

        If nTotCp <= 0
            lRet := .F.
            MsgInfo("Veículo " + cPlaca + " não possui caixa de transporte cadastrada.","Função vldCaixa(ADFAT034P)")

        EndIf

    EndIf

    RestArea(aArea)

Return lRet
