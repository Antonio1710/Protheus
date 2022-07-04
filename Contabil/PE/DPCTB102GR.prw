#Include "Protheus.Ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function DPCTB102GR
    PE logo após gravação da CT2
    @type  Function
    @author Fernando Macieira
    @since 28/06/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 73451 - 28/06/2022 - Fernando Macieira - Validação R33
    @history ticket 73451 - Fernando Macieira - 04/07/2022 - Padronização lote RM
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

                DEFINE MSDIALOG oDlgPrj TITLE "Lançamento manual - Número DOC" FROM 0,0 TO 100,350  OF oMainWnd PIXEL
                
                    @ 003, 003 TO 050,165 PIXEL OF oDlgPrj
                    
                    @ 010,020 Say "Documento:" of oDlgPrj PIXEL
                    @ 005,060 MsGet oCmpDOC Var cNewDOC SIZE 70,12 of oDlgPrj PIXEL Valid !Empty(cNewDOC)
                    
                    @ 030,015 BUTTON oBtnDOC[01] PROMPT "Confirma"     of oDlgPrj   SIZE 68,12 PIXEL ACTION (lOKDOC := .T., oDlgPrj:End()) 
                    @ 030,089 BUTTON oBtnDOC[02] PROMPT "Cancela"      of oDlgPrj   SIZE 68,12 PIXEL ACTION (lSair  := .T., lOKDOC := .F., oDlgPrj:End()) 
                    
                ACTIVATE MSDIALOG oDlgPrj CENTERED

                If lSair
                    If MsgYesNo("Você clicou no botão sair... A nova numeração não será gravada! Tem certeza de que deseja sair sem gravar o novo número de documento?", "Confirmação cancelamento novo número DOC")
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
                            Alert("Número do documento n. " + cNewDoc + " informado precisa ter a mesma quantidade de caracteres do tamanho do campo que é " + AllTrim(Str(TamSX3("CT2_DOC")[1])) + " ! Verifique...")
                        Else
                            If fExistCT2(cNewDOC)
                                lOKDOC := .f.
                                Alert("Número de documento n. " + cNewDoc + " informado já existe nesta data para este lote! Verifique...")
                            Else
                                u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE","CTBA102",;
                                "Usuario CONFIRMOU a gravacao do novo numero do documento manual, de " + cDocLct + " para " + cNewDOC, ComputerName(), LogUserName() )
                                Exit
                            EndIf
                        EndIf
                    Else
                        lOKDOC := .f.
                        Alert("Número de documento obrigatório para lançamentos manuais! Verifique...")
                    EndIf
                EndIf
            
            EndDo

            If lOKDOC
                MsgRun( "Número original " + cDocLct + " pelo novo informado " + cNewDOC,"Alterando...", { || GrvNewDoc(cNewDOC) } )
                //msAguarde(GrvNewDoc(cNewDOC),"Aguarde...","Alterando número original " + cDocLct + " pelo novo informado " + cNewDOC)
                //GrvNewDoc(cNewDOC)
            EndIf

        EndIf
    
    EndIf

    //@history ticket 73451 - Fernando Macieira - 04/07/2022 - Padronização lote RM
    FixLtRM()
    
Return

/*/{Protheus.doc} Grava novo numero DOC para lançamentos manuais
    DANIELLE PINHEIRO MEIRA
    15/06/2022 17:21
    Macieira,
    Conforme falamos, seguiremos da forma proposta.
    NO SIG, na inclusão/copia de lançamentos do lote 999999 o sistema abrirá uma “tela” para preenchimento do número do documento com 6 dígitos.
    Na produção, na inclusão/copia de lançamentos do lote 008860 o sistema abrirá uma “tela” para preenchimento do número do documento com 6 dígitos.
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
    Local cQuery   := ""
    Local lMsg     := .f.

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
            "GRAVOU NOVO NUMERO do documento manual, ORIGINAL " + cDocLct + " NOVO " + cNewDOC, ComputerName(), LogUserName() )

            RecLock("CT2", .F.)
                CT2->CT2_DOC := cNewDOC
            CT2->( msUnLock() )

            lMsg     := .t.

            Work->( dbSkip() )

        EndDo

    End Transaction

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    If lMsg
        MsgInfo("Número do documento manual alterado com sucesso!" + chr(13)+chr(10)+;
            "Data: " + DtoC(dDtLct) + chr(13)+chr(10)+;
            "Lote: " + cLtLct + chr(13)+chr(10)+;
            "SubLote: " + cSbLtLct + chr(13)+chr(10)+;
            "Documento Original: " + cDocLct, "Novo n. documento: " + cNewDOC)
    EndIf

    RestArea( aArea )
    RestArea( aAreaCT2 )

Return

/*/{Protheus.doc} nomeStaticFunction fExistCT2()
    Checa se o número informado já existe na base na mesma data e no mesmo lote manual
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
        "NUMERO do documento manual informado já existe na base nesta data com o mesmo lote " + cNewDOC, ComputerName(), LogUserName() )
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
    Local cQuery   := ""
    Local cLtFolha := GetMV("MV_#LOTERM",,"008890")

    If Subs(AllTrim(CT2->CT2_HIST),6,1) == "-" .or. CT2->CT2_LOTE='******' .or. AllTrim(CT2->CT2_ORIGEM) == "CTBI102" .or. AllTrim(CT2->CT2_SBLOTE) == "000"

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

                    u_GrLogZBE(msDate(),TIME(),cUserName,"SIG","CONTABILIDADE",FunName(),;
                    "GRAVOU NOVO LOTE RM, ORIGINAL " + cLtLct + " NOVO " + cLtFolha, ComputerName(), LogUserName() )

                    RecLock("CT2", .F.)
                        CT2->CT2_LOTE := cLtFolha
                    CT2->( msUnLock() )

                EndIf

                Work->( dbSkip() )

            EndDo

        End Transaction

    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    RestArea( aArea )
    RestArea( aAreaCT2 )

Return
