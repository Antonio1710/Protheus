#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} ADCOM033P 
    Função para liberação de produto. Chamado T.I.
    @type  Function
    @author Everson
    @since 29/11/2019
    @version 01
    @history 11/12/2019, Everson, Chamado 053902. Removido controle de transação.
    @history 12/12/2019, Everson, Chamado 053902. Adicionada tela para inclusão de motivo de reprovação.
    @history 07/05/2021, Everson, Chamado 13414. Tratamento para ocorrer liberação e desbloqueio de produto apenas pela controladoria.
    /*/
User Function ADCOM033P() // U_ADCOM033P()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	    := GetArea()
    Local cAcao	    := ""
    Local aDados    := {}
    Local cQuery    := ""
    Local cQryEdt   := ""
    Local nConEdt   := 0
    Local oArq1	    := Nil 
    Local aStruct   := {}
    Local nAux	    := 1
    Local aCampos   := {}
    Local cCodPrd   := ""
    Local cDscPrd   := ""
    Local cDescCPrd := ""
    Local nPosVetor := 0

    Local lUsuLibC   := Alltrim(__cUserId) $ GetMv("MV_#USUCON",,"") //Everson - 07/05/2021. Chamado 13414. 

    Private cTemp   := ""
    Private cMark   := GetMark()
    Private aRotina	:= {}

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    //
    Aadd(aRotina,{"Aprovar"     ,"U_ADCOM331()"      , 0,2})
    Aadd(aRotina,{"Reprovar"    ,"U_ADCOM332()"      , 0,2})
    
    //Everson - 07/05/2021. Chamado 13414.
    If lUsuLibC //Processo de liberação/bloqueio.
        cQuery := " SELECT B1_COD, B1_DESC, B1_DESCOMP, B1_MSBLQL "
        cQuery += " FROM " + RetSqlName("SB1") + " (NOLOCK) AS SB1 WHERE B1_FILIAL = '" + FWxFilial("SB1") + "' AND B1_XAPROV = 'C' AND SB1.D_E_L_E_T_ = '' "
    
    Else //Vistar.
        cQuery := " SELECT B1_COD, B1_DESC, B1_DESCOMP, B1_MSBLQL "
        cQuery += " FROM " + RetSqlName("SB1") + " (NOLOCK) AS SB1 WHERE B1_FILIAL = '" + FWxFilial("SB1") + "' AND B1_XAPROV = 'S' AND SB1.D_E_L_E_T_ = '' "

    EndIf 

    //
    If Select("D_CHK") > 0
        D_CHK->(DbCloseArea())

    EndIf 
    TcQuery cQuery New Alias "D_CHK"
    DbSelectArea("D_CHK")
    D_CHK->(DbGoTop())
    While ! D_CHK->(Eof())

        //
        Conout( DToC(Date()) + " " + Time() +  " ADCOM033P - MTA10_01 - D_CHK " + cValToChar(D_CHK->B1_COD))

        //
        Iif(Alltrim(cValToChar(D_CHK->B1_MSBLQL)) = "1", cAcao := "Liberar", cAcao := "Bloquear")
        cCodPrd  := D_CHK->B1_COD
        cDscPrd  := D_CHK->B1_DESC
        cDescCPrd:= D_CHK->B1_DESCOMP

        //
        nPosVetor++
        Aadd(aDados,{cAcao,;
                    cCodPrd,;
                    cDscPrd,;
                    cDescCPrd,;
                    "",;
                    "",;
                    "",;
                    "",;
                    nConEdt})
        //
        cQryEdt := U_A10_02(Alltrim(cCodPrd))
        If Select("D_CHKEDT") > 0
            D_CHKEDT->(DbCloseArea())

        EndIf
        TcQuery cQryEdt New Alias "D_CHKEDT"
        DbSelectArea("D_CHKEDT")
        D_CHKEDT->(DbGoTop())
        nConEdt:= 0
        While ! D_CHKEDT->(Eof())

            //
            Conout( DToC(Date()) + " " + Time() +  " ADCOM033P - MTA10_01 - D_CHKEDT " + cValToChar(D_CHKEDT->PRODUTO))

            //
            aDados[nPosVetor][5] := D_CHKEDT->PRODUTO
            aDados[nPosVetor][6] := D_CHKEDT->ACAD_MATERIAL
            aDados[nPosVetor][7] := D_CHKEDT->BCAD_MATERIAL_EMBALAGEM
            aDados[nPosVetor][8] := D_CHKEDT->CCAD_MATERIAIS_EMBALAGEM

            //
            D_CHKEDT->(DbSkip())

        End
        
        //
        D_CHK->(DbSkip())

    End

    //
    D_CHK->(DbCloseArea())

    //
    If Len(aDados) <= 0
        Help(Nil, Nil, "Função ADCOM033P(ADCOM033P)", Nil, "Não há registros de produtos a serem aprovados.", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
        RestArea(aArea)
        Return Nil 

    EndIf

    //Cria arquivo temporário.
    Aadd(aStruct,{"TM_OK"    ,"C",002,0})
    Aadd(aStruct,{"TM_ACAO"  ,"C",010,0})
    Aadd(aStruct,{"TM_COD"   ,"C",TamSX3("B1_COD")[1],0})
    Aadd(aStruct,{"TM_DESC"  ,"C",TamSX3("B1_DESC")[1],0})
    Aadd(aStruct,{"TM_DESCC" ,"C",TamSX3("B1_DESCOMP")[1],0})
    Aadd(aStruct,{"TM_DESEDT1","C",010,0})
    Aadd(aStruct,{"TM_DESEDT2","C",100,0})
    Aadd(aStruct,{"TM_DESEDT3","C",100,0})
    Aadd(aStruct,{"TM_DESEDT4","C",200,0})
    cTemp := GetNextAlias()
    oArq1 :=  FWTemporaryTable():New(cTemp)
    oArq1:SetFields(aStruct)
    oArq1:Create()

    //
    For nAux := 1 To Len(aDados)
        RecLock(cTemp,.T.)
            (cTemp)->TM_OK     := ""
            (cTemp)->TM_ACAO   := aDados[nAux][1]
            (cTemp)->TM_COD    := aDados[nAux][2]
            (cTemp)->TM_DESC   := aDados[nAux][3]
            (cTemp)->TM_DESCC  := aDados[nAux][4]
            (cTemp)->TM_DESEDT1:= aDados[nAux][5]
            (cTemp)->TM_DESEDT2:= aDados[nAux][6]
            (cTemp)->TM_DESEDT3:= aDados[nAux][7]
            (cTemp)->TM_DESEDT4:= aDados[nAux][8]
        (cTemp)->(MsUnlock())
    Next nAux

    //
    Aadd(aCampos,{"TM_OK"     ,"",""})
    Aadd(aCampos,{"TM_ACAO"   ,"","Ação"})
    Aadd(aCampos,{"TM_COD"    ,"","Código"})
    Aadd(aCampos,{"TM_DESC"   ,"","Descrição"})
    Aadd(aCampos,{"TM_DESCC"  ,"","Descrição Compl."})
    Aadd(aCampos,{"TM_DESEDT1","","PRODUTO Edata"})
    Aadd(aCampos,{"TM_DESEDT2","","CAD_MATERIAL Edata"})
    Aadd(aCampos,{"TM_DESEDT3","","CAD_MATERIAL_EMBALAGEM Edata"})
    Aadd(aCampos,{"TM_DESEDT4","","CAD_MATERIAIS_EMBALAGEM Edata"})

    //
    MarkBrow(cTemp, 'TM_OK',,aCampos,,cMark,'U_MTA10_02()',,,,'U_MTA10_03()',,,,)

    //
    (cTemp)->(DbCloseArea())

    //
    oArq1:Delete()

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} MTA10_02  
    Marca todos os registros da  markbrowse 1. Chamado T.I.
    @type  Function
    @author Everson
    @since 29/11/2019
    @version 01
    /*/
User Function MTA10_02()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local oMark	 := GetMarkBrow()

    U_ADINF009P('ADCOM033P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
    
    DbSelectArea(cTemp)
    (cTemp)->(DbGotop())
    While ! (cTemp)->(Eof())
        
        U_MTA10_03()
        
        (cTemp)->(DbSkip())
        
    End
    
    //Força o posicionamento do browse no primeiro registro.
    oMark:oBrowse:Gotop()
    MarkBRefresh()
    
Return Nil
/*/{Protheus.doc} MTA10_03  
    Marca registro do arquivo temporário. Chamado T.I.
    @type  Function
    @author Everson
    @since 29/11/2019
    @version 01
    /*/
User Function MTA10_03()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

    U_ADINF009P('ADCOM033P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    If IsMark( 'TM_OK', cMark )

        RecLock( cTemp, .F. )

            Replace TM_OK With Space(2)

        MsUnLock()

    Else

        RecLock( cTemp, .F. )

            Replace TM_OK With cMark

        MsUnLock()

    EndIf

Return Nil
/*/{Protheus.doc} ADCOM331  
    Processa aprovação.
    @type  Function
    @author Everson
    @since 29/11/2019
    @version 01
    /*/
User Function ADCOM331()

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	  := GetArea()
    Local cCodPrd := ""
    Local lRet    := .T.
    Local aEnvSF  := {}
    Local cNvStat := ""
    Local xPl     := Chr(13) + Chr(10)
    Local cEmlLib := GetMv("MV_#EMLBP",,"")

    Local lUsuLibC:= Alltrim(__cUserId) $ GetMv("MV_#USUCON",,"") //Everson - 07/05/2021. Chamado 13414.

    U_ADINF009P('ADCOM033P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    //
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    //
    (cTemp)->(DbGoTop())
    While !(cTemp)->(Eof())
        If ! Empty(Alltrim((cTemp)->TM_OK))

            //
            cCodPrd := Alltrim((cTemp)->TM_COD)

            //
            Conout( DToC(Date()) + " " + Time() + " ADCOM033P - ADCOM331 - cCodPrd - " + cCodPrd)

            //
            If ! SB1->(DbSeek( FWxFilial("SB1") + cCodPrd ))
                Help(Nil, Nil, "Função ADCOM331(ADCOM033P)", Nil, "Erro! Produto não localizado " + cValToChar(cCodPrd) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cTemp)->(DbSkip())
                Loop

            EndIf

            //
            If ! Empty(cCodPrd)

                //
                If ! MsgYesNo("Deseja prosseguir com a liberação do produto " + cCodPrd + "?" + xPl + xPl +;
                    "B1_DESC -->"                + Alltrim((cTemp)->TM_DESC)     + xPl + xPl +;
                    "B1_DESCOM -->"              + Alltrim((cTemp)->TM_DESCC)    + xPl + xPl +;
                    "CAD_MATERIAL -->"            + Alltrim((cTemp)->TM_DESEDT2) + xPl + xPl +;
                    "CAD_MATERIAL_EMBALAGEM -->"  + Alltrim((cTemp)->TM_DESEDT3) + xPl + xPl +;
                    "CAD_MATERIAIS_EMBALAGEM -->" + Alltrim((cTemp)->TM_DESEDT4),"Função ADCOM331(ADCOM033P)")
                    (cTemp)->(DbSkip())
                    Loop

                EndIf

                //
                cNvStat := Iif(Alltrim(cValToChar(SB1->B1_MSBLQL)) == "2", "1", "2")

                //
                //Begin Transaction //Everson - 11/12/2019 - Chamado 053902.

                    RecLock("SB1",.F.)
                        
                        //Everson - 07/05/2021. Chamado 13414.
                        If lUsuLibC
                            Replace B1_MSBLQL With cNvStat //Libera/bloqueia o cadastro do produto.
                            Replace B1_XAPROV With "N" //Marca como "N" para ser processado pelo Edata.

                        Else 
                            Replace B1_XAPROV With "C" //Visto.

                        EndIf

                    SB1->(MsUnlock())

                    //
                    DbSelectArea("ZBE")
                        RecLock("ZBE",.T.)
                        Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
                        Replace ZBE_DATA 	   	With Date()
                        Replace ZBE_HORA 	   	With Time()
                        Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
                        Replace ZBE_LOG	        With "Produto " + cCodPrd + Iif(cNvStat = "1", " bloqueado ", " Liberado")
                        Replace ZBE_MODULO	    With "CONTROLADORIA"
                        Replace ZBE_ROTINA	    With "ADCOM033P"
                        Replace ZBE_PARAME	    With cCodPrd + " Tp aprova " + cValToChar(SB1->B1_XAPROV) //Everson - 07/05/2021. Chamado 13414.
                    ZBE->(MsUnlock())

                    //
                    lRet := .T.
                    If ! Empty(Alltrim(cValToChar((cTemp)->TM_DESEDT1))) .And. lUsuLibC
                        lRet := U_A10_01(cCodPrd,Iif(cNvStat = "1","N","S"),"LIBERAÇÃO ") //Libera o cadastro de produto no Edata. //N= Bloqueado, S=Liberado
                    
                    EndIf

                    //
                    Conout( DToC(Date()) + " " + Time() + " ADCOM033P - ADCOM331 - lRet - " + cValToChar(lRet))

                    //
                    If lRet .And. lUsuLibC //Everson - 07/05/2021. Chamado 13414.

                        //
                        RecLock("SB1",.F.)
                            Replace B1_XAPROV With ""
                        SB1->(MsUnlock())

                        Aadd(aEnvSF,cCodPrd)

                        //
                        MsAguarde({||	U_enviaremail(allTrim(cEmlLib), "Aprovação de Processo - Produto", "Produto " + cCodPrd + Iif(cNvStat = "1", " bloqueado ", " Liberado"),,)},"Aguarde","Enviando Email...")

                    /*Else //Everson - 11/12/2019 - Chamado 053902.
                        DisarmTransaction()
                        Break*/

                    EndIf

                //End Transaction //Everson - 11/12/2019 - Chamado 053902.

            EndIf

        EndIf
        
        (cTemp)->(DbSkip())
        
    EndDo

    //
    If Len(aEnvSF) > 0
        envSFLib(aEnvSF)

    EndIf

    //Fecha MarkBrowse
    CloseBrowse()

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} User Function ADCOM332
    Cancela processo de aprovação.
    @type  Function
    @author Everson
    @since 11/12/2019
    @version 01
    /*/
User Function ADCOM332()
 
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea	  := GetArea()
    Local cCodPrd := ""
    Local cNvStat := ""
    Local cEmlLib := GetMv("MV_#EMLBP",,"")
    Local oDlg    := Nil
    Local cMotivo := Space(115)

    U_ADINF009P('ADCOM033P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
    
    //
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))

    //
    (cTemp)->(DbGoTop())
    While !(cTemp)->(Eof())
        If ! Empty(Alltrim((cTemp)->TM_OK))

            //
            cCodPrd := Alltrim((cTemp)->TM_COD)

            //
            Conout( DToC(Date()) + " " + Time() + " ADCOM033P - ADCOM332 - cCodPrd - " + cCodPrd)

            //
            If ! SB1->(DbSeek( FWxFilial("SB1") + cCodPrd ))
                Help(Nil, Nil, "Função ADCOM332(ADCOM033P)", Nil, "Erro! Produto não localizado " + cValToChar(cCodPrd) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
                (cTemp)->(DbSkip())
                Loop

            EndIf

            //
            If ! MsgYesNo("Deseja cancelar o processo para o produto " + cCodPrd + "?","Função ADCOM332(ADCOM033P)")
                (cTemp)->(DbSkip())
                Loop 

            EndIf

            //Everson - 12/12/2019 - Chamado 053902.
            Define MsDialog oDlg From	18,1 To 80,550 Title "Motivo da reprovação" Pixel STYLE DS_MODALFRAME
                @  1, 3 	To 28, 242 Of oDlg  Pixel
                If File("adoro.bmp")
                    @ 3,5 Bitmap oBmp FILE "adoro.bmp" Of oDlg nOBorder Size 25,25 Pixel
                    oBmp:lStretch:=.T.
                EndIf
                @ 05, 37	Say "Motivo:" SIZE 24, 7 Of oDlg Pixel
                @ 12, 37  	MsGet cMotivo  SIZE	200, 9 Of oDlg Pixel Valid !Empty(cMotivo)
                Define SBUTTON From 02,246 TYPE 1 Action (oDlg:End()) ENABLE Of oDlg
            Activate MsDialog oDlg Centered

            //Everson - 12/12/2019 - Chamado 053902.
            If Empty(Alltrim(cMotivo))
                MsgStop("É necessário informar o motivo da reprovação.","Função ADCOM332(ADCOM033P)")
                RestArea(aArea)
                Return Nil

            EndIf

            //
            Iif(Alltrim(cValToChar(SB1->B1_MSBLQL)) == "2",cNvStat := "1",cNvStat := "2")

            //
            RecLock("SB1",.F.)
                Replace B1_XAPROV With ""
            SB1->(MsUnlock())

            //
            DbSelectArea("ZBE")
                RecLock("ZBE",.T.)
                Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
                Replace ZBE_DATA 	   	With Date()
                Replace ZBE_HORA 	   	With Time()
                Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
                Replace ZBE_LOG	        With "Cancelado processo - Produto " + cCodPrd + Iif(cNvStat = "1", "bloqueado ", "Liberado")
                Replace ZBE_MODULO	    With "CONTROLADORIA"
                Replace ZBE_ROTINA	    With "ADCOM033P"
                Replace ZBE_PARAME	    With cCodPrd
            ZBE->(MsUnlock())

            //
            MsAguarde({||	U_enviaremail(allTrim(cEmlLib), "Cancelamento de Processo - Produto", "O processo de aprovação para o produto " + cValToChar(cCodPrd)+ " foi cancelado." + Chr(13) + Chr(10) +;
                                                             "Motivo: " + cValToChar(cMotivo),,)},"Aguarde","Enviando Email...")

        EndIf

        (cTemp)->(DbSkip())
        
    EndDo

    //Fecha MarkBrowse
    CloseBrowse()

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} envSFLib  
    Envia produtos liberados para o Salesforce.
    @type  Function
    @author Everson
    @since 29/11/2019
    @version 01
    /*/
Static Function envSFLib(aEnvSF)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Declaração de variáveis.                                            |
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea :=  GetArea()
    Local nAux  := 1

    //
    For nAux := 1 To Len(aEnvSF)
        MsAguarde({|| U_ADVEN069P("",.F.," AND B1_COD = '" + aEnvSF[nAux] + "' ") },"Aguarde...","Enviando registro para o SalesForce...")

    Next nAux

    //
    RestArea(aArea)

Return Nil
