#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function DPCTB102GR
    PE logo ap?s grava??o da CT2
    @type  Function
    @author Fernando Macieira
    @since 28/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 73451 - 28/06/2022 - Fernando Macieira - Valida??o R33
    @history ticket 73451 - Fernando Macieira - 04/07/2022 - Padroniza??o lote RM
    @history ticket 73451 - 05/07/2022 - Fernando Macieira - Travamento na exclus?o do lote manual
    @history ticket 73451 - 13/07/2022 - Fernando Macieira - Publica??o
/*/
User Function DPCTB102GR()

    Local lOKDOC  	 := .F.
	Local lSair		 := .F.
    Local oCmpDOC    := Array(01)
	Local oBtnDOC    := Array(02)

    Private nOpcLct  := ParamIxb[1]
    Private dDtLct   := ParamIxb[2]
    Private cLtLct   := ParamIxb[3]
    Private cSbLtLct := ParamIxb[4]
    Private cDocLct  := ParamIxb[5]

    Private cLotMan  := GetMV("MV_#DOCMAN",,"008860")
	Private cNewDOC  := CriaVar("CT2_DOC")

    If GetRpoRelease() >= "12.1.033"

        If (nOpcLct == 3 .or. nOpcLct == 7) .and. AllTrim(cLtLct) $ cLotMan .and. IsInCallStack("CTBA102") .and. AllTrim(FunName()) == "CTBA102"
        
            Do While .t.

                DEFINE MSDIALOG oDlgPrj TITLE "Lan?amento manual - N?mero DOC" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
                
                    @ 003, 003 TO 050,165 PIXEL OF oDlgPrj
                    
                    @ 010,020 Say "Documento:" of oDlgPrj PIXEL
                    @ 005,060 MsGet oCmpDOC Var cNewDOC SIZE 70,12 of oDlgPrj PIXEL Valid !Empty(cNewDOC)
                    
                    @ 030,015 BUTTON oBtnDOC[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION (lOKDOC := .T., oDlgPrj:End()) 
                    @ 030,089 BUTTON oBtnDOC[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION (lSair  := .T., lOKDOC := .F., oDlgPrj:End()) 
                    
                ACTIVATE MSDIALOG oDlgPrj CENTERED

                If lSair
                    If MsgYesNo("Voc? clicou no bot?o sair... A nova numera??o n?o ser? gravada! Tem certeza de que deseja sair sem gravar o novo n?mero de documento?", "Confirma??o cancelamento novo n?mero DOC")
                        u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE","CTBA102",;
                        "Usuario clicou no botao SAIR e confirmou NAO GRAVAR o novo numero do documento manual, mantido " + cDocLct + ", informado e ignorado " + cNewDOC, ComputerName(), LogUserName() )
                        Exit
                    Else
                        lSair := .f.
                    EndIf
                EndIf

                If lOKDOC
                    If !Empty(cNewDOC)
                        If Len(AllTrim(cNewDOC)) <> TamSX3("CT2_DOC")[1]
                            lOKDOC := .f.
                            Alert("N?mero do documento n. " + cNewDoc + " informado precisa ter a mesma quantidade de caracteres do tamanho do campo que ? " + AllTrim(Str(TamSX3("CT2_DOC")[1])) + " ! Verifique...")
                        Else
                            If fExistCT2(cNewDOC)
                                lOKDOC := .f.
                                Alert("N?mero de documento n. " + cNewDoc + " informado j? existe nesta data para este lote! Verifique...")
                            Else
                                u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE","CTBA102",;
                                "Usuario CONFIRMOU a gravacao do novo numero do documento manual, de " + cDocLct + " para " + cNewDOC, ComputerName(), LogUserName() )
                                Exit
                            EndIf
                        EndIf
                    Else
                        lOKDOC := .f.
                        Alert("N?mero de documento obrigat?rio para lan?amentos manuais! Verifique...")
                    EndIf
                EndIf
            
            EndDo

            If lOKDOC
                MsgRun( "N?mero original " + cDocLct + " pelo novo informado " + cNewDOC,"Alterando...", { || GrvNewDoc(cNewDOC) } )
            EndIf

        EndIf
    
    EndIf

    //@history ticket 73451 - Fernando Macieira - 04/07/2022 - Padroniza??o lote RM
    FixLtRM()
    
Return

/*/{Protheus.doc} Grava novo numero DOC para lan?amentos manuais
    DANIELLE PINHEIRO MEIRA
    15/06/2022 17:21
    Macieira,
    Conforme falamos, seguiremos da forma proposta.
    NO SIG, na inclus?o/copia de lan?amentos do lote 999999 o sistema abrir? uma ?tela? para preenchimento do n?mero do documento com 6 d?gitos.
    Na produ??o, na inclus?o/copia de lan?amentos do lote 008860 o sistema abrir? uma ?tela? para preenchimento do n?mero do documento com 6 d?gitos.
    @type  Static Function
    @author FWNM
    @since 27/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GrvNewDoc(cNewDOC)

    Local aArea    := GetArea()
    Local aAreaCT2 := CT2->( GetArea() )
    Local aAreaCTF := CTF->( GetArea() )
    Local cQuery   := ""
    Local lMsg     := .f.
    Local lLockCTF := .t.

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT R_E_C_N_O_ RECNO
    cQuery += " FROM " + RetSqlName("CT2") + " (NOLOCK)
    cQuery += " WHERE CT2_FILIAL='"+CT2->CT2_FILIAL+"'
    cQuery += " AND CT2_DATA='"+DtoS(dDtLct)+"'
    cQuery += " AND CT2_LOTE='"+cLtLct+"'
    cQuery += " AND CT2_SBLOTE='"+cSbLtLct+"'
    cQuery += " AND CT2_DOC='"+cDocLct+"'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Begin Transaction

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

            CT2->( dbGoTo(Work->RECNO) )

            u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE","CTBA102",;
            "NOVO NUMERO, ORIGINAL " + cDocLct + " NOVO " + cNewDOC + " - DT/LOTE " + DtoC(CT2->CT2_DATA)+"/"+CT2->CT2_LOTE, ComputerName(), LogUserName() )

            RecLock("CT2", .F.)
                CT2->CT2_DOC := cNewDOC
            CT2->( msUnLock() )

            lMsg     := .t.

            Work->( dbSkip() )

        EndDo

        // @history ticket 73451 - 05/07/2022 - Fernando Macieira - Travamento na exclus?o do lote manual
        If lMsg

            CTF->( DbSetOrder(1) ) // CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, R_E_C_N_O_, D_E_L_E_T_
            If CTF->( dbSeek(FWxFilial("CTF")+DtoS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+cDocLct) )
                
                RecLock("CTF", .F.)
                    CTF->CTF_DOC := cNewDOC
                CTF->( msUnLock() )
            
            Else

                lLockCTF := .t.
                CTF->( DbSetOrder(1) ) // CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, R_E_C_N_O_, D_E_L_E_T_
                If CTF->( dbSeek(FWxFilial("CTF")+DtoS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+cNewDOC) )
                    lLockCTF := .f.
                EndIf

                RecLock("CTF", lLockCTF)
                    CTF->CTF_FILIAL := FWxFilial("CTF")
                    CTF->CTF_DATA   := CT2->CT2_DATA
                    CTF->CTF_LOTE   := CT2->CT2_LOTE
                    CTF->CTF_SBLOTE := CT2->CT2_SBLOTE
                    CTF->CTF_DOC    := cNewDOC
                    CTF->CTF_USADO  := "S"
                CTF->( msUnLock() )

            EndIf
            //

        EndIf

    End Transaction

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    If lMsg
        MsgInfo("N?mero do documento manual alterado com sucesso!" + chr(13)+chr(10)+;
            "Data: " + DtoC(dDtLct) + chr(13)+chr(10)+;
            "Lote: " + cLtLct + chr(13)+chr(10)+;
            "SubLote: " + cSbLtLct + chr(13)+chr(10)+;
            "Documento Original: " + cDocLct, "Novo n. documento: " + cNewDOC)
    EndIf

    RestArea( aArea )
    RestArea( aAreaCT2 )
    RestArea( aAreaCTF )

Return

/*/{Protheus.doc} nomeStaticFunction fExistCT2()
    Checa se o n?mero informado j? existe na base na mesma data e no mesmo lote manual
    @type  Static Function
    @author FWNM
    @since 27/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fExistCT2(cNewDOC)

    Local aArea  := GetArea()
    Local lRet   := .f.
    Local cQuery := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT R_E_C_N_O_ RECNO
    cQuery += " FROM " + RetSqlName("CT2") + " (NOLOCK)
    cQuery += " WHERE CT2_FILIAL='"+CT2->CT2_FILIAL+"'
    cQuery += " AND CT2_DATA='"+DtoS(dDtLct)+"'
    cQuery += " AND CT2_LOTE='"+cLotMan+"'
    cQuery += " AND CT2_SBLOTE='"+cSbLtLct+"'
    cQuery += " AND CT2_DOC='"+cNewDOC+"'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->( !EOF() )
        lRet := .t.
        u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE","CTBA102",;
        "NUMERO do documento manual informado j? existe na base nesta data com o mesmo lote " + cNewDOC, ComputerName(), LogUserName() )
    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    RestArea( aArea )
    
Return lRet

/*/{Protheus.doc} nomeStaticFunction
    Padroniza lote vindo do RM
    @type  Static Function
    @author FWNM
    @since 30/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function FixLtRM()

    Local aArea    := GetArea()
    Local aAreaCT2 := CT2->( GetArea() )
    Local aAreaCTF := CTF->( GetArea() )
    Local cQuery   := ""
    Local cLtFolha := GetMV("MV_#LOTERM",,"008890")
    Local lCTF     := .f.
    Local lLockCTF := .t.

    If AllTrim(CT2->CT2_ORIGEM) == "CTBI102" .or. CT2->CT2_LOTE='******' .or. AllTrim(CT2->CT2_SBLOTE) == "000"

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        cQuery := " SELECT R_E_C_N_O_ RECNO
        cQuery += " FROM " + RetSqlName("CT2") + " (NOLOCK)
        cQuery += " WHERE CT2_FILIAL='"+FWxFilial("CT2")+"'
        cQuery += " AND CT2_DATA='"+DtoS(dDtLct)+"'
        cQuery += " AND CT2_LOTE='"+cLtLct+"'
        cQuery += " AND CT2_SBLOTE='"+cSbLtLct+"'
        cQuery += " AND CT2_DOC='"+cDocLct+"'
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        Begin Transaction

            Work->( dbGoTop() )
            Do While Work->( !EOF() )

                CT2->( dbGoTo(Work->RECNO) )

                If CT2->CT2_LOTE <> cLtFolha

                    u_GrLogZBE(msDate(),TIME(),cUserName,"FOLHA","CONTABILIDADE","DPCTB102GR",;
                    "LOTE RM, ORIGINAL " + cLtLct + " NOVO " + cLtFolha + " - DT/DOC " + DtoC(CT2->CT2_DATA)+"/"+CT2->CT2_DOC, ComputerName(), LogUserName() )

                    RecLock("CT2", .F.)
                        CT2->CT2_LOTE := cLtFolha
                    CT2->( msUnLock() )

                    lCTF     := .t.

                EndIf

                Work->( dbSkip() )

            EndDo

            // @history ticket 73451 - 05/07/2022 - Fernando Macieira - Travamento na exclus?o do lote manual
            If lCTF

                CTF->( DbSetOrder(1) ) // CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, R_E_C_N_O_, D_E_L_E_T_
                If CTF->( dbSeek(FWxFilial("CTF")+DtoS(CT2->CT2_DATA)+cLtLct+CT2->CT2_SBLOTE+CT2->CT2_DOC) )
                    
                    RecLock("CTF", .F.)
                        CTF->CTF_LOTE := cLtFolha
                    CTF->( msUnLock() )
                
                Else

                    lLockCTF := .t.
                    CTF->( DbSetOrder(1) ) // CTF_FILIAL, CTF_DATA, CTF_LOTE, CTF_SBLOTE, CTF_DOC, R_E_C_N_O_, D_E_L_E_T_
                    If CTF->( dbSeek(FWxFilial("CTF")+DtoS(CT2->CT2_DATA)+cLtFolha+CT2->CT2_SBLOTE+CT2->CT2_DOC) )
                        lLockCTF := .f.
                    EndIf

                    RecLock("CTF", lLockCTF)
                        CTF->CTF_FILIAL := FWxFilial("CTF")
                        CTF->CTF_DATA   := CT2->CT2_DATA
                        CTF->CTF_LOTE   := cLtFolha
                        CTF->CTF_SBLOTE := CT2->CT2_SBLOTE
                        CTF->CTF_DOC    := CT2->CT2_DOC
                        CTF->CTF_USADO  := "S"
                    CTF->( msUnLock() )

                EndIf
                //

            EndIf            

        End Transaction

    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    RestArea( aArea )
    RestArea( aAreaCT2 )
    RestArea( aAreaCTF )

Return
