#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.CH"
#Include "Topconn.ch"
#Include 'AP5mail.ch'
/*/{Protheus.doc} User Function ADCOM020P
    Execucao de Agendamento de Workflow.
    @type  Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    @history Everson - 17/01/2019. Chamado 044743. Adicionado histórico de inadimplência e PDD. 
    @history Fernando 24/04/2019 - Chamado: TI - Fernando Sigoli. ajustado rotina de envio de email
    para nao concatenar Email Destinatario + Com-copia
    @history 24/05/19 | Adriana           | Devido a substituicao email para shared relay, substituido MV_RELACNT p/ MV_RELFROM| TI
    @history Everson - 17/10/2019. Chamado 052531. Adicionado cálculo de PDD do ano vigente na aba Provisão Perdas e Perdas Efetivas.
    @history Everson - 29/07/2020. Chamado 058854. Adicionadas as empresas 02, 07 e 09. 
    @history Everson - 29/07/2020. Chamado 059641. Tratamento para desconsiderar títulos NDC.
    @history Everson - 17/08/2020. Chamado 060504|| OS 061975 || FINANCAS || WAGNER || 11940283101 || AGINGLIST.
    /*/
User Function ADCOM020P()

    //Variáveis.
    Local lAutoJob 		:= .F.

    //
    Private cDestWFgas := ""
    Private cCopDeswf  := ""
    Private sNAmbiente := ""
    Private nServerPRD := ""
    Private sWFCentral := ""

    //
    If Select("SX6") == 0
	    lAutoJob := .T.

    EndIf

    //
    If lAutoJob
        RpcSetType(3)
        RpcSetEnv( "01" , "01" )
        ConOut( "Inicio - Workflow Gerencial - " + time() )
        sNAmbiente := getServerIP()

    EndIf

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    //
    Dbselectarea("ZCJ")
    ZCJ->(Dbsetorder(1))

    //
    sWFCentral := SuperGetMv( "MV_#ADC020" , .F. , '' ,  )

    WHILE ZCJ->(!EOF())
    IF ZCJ->ZCJ_WFATIV = '1'
     If ZCJ->ZCJ_PERTIP = 'D'
        // PRIMEIRA EXECUCAO
        If !EMPTY(ZCJ->ZCJ_PRIEXE)
            IF ZCJ->ZCJ_PRIEXE > SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))-5))) .and. ZCJ->ZCJ_PRIEXE < SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))+5)))
                If ( EMPTY(ZCJ->ZCJ_PRIDAT) .OR. ZCJ->ZCJ_PRIDAT <> DATE() )
                    If ZCJ->ZCJ_CODWKF = '000001'
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ConOut( "Inicio 1ª - Executando Workflow de Combustiveis" )
                        ADCO020A()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 1ª - Executando Workflow de Combustiveis" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000002'
                        ConOut( "Inicio 1ª - Executando Workflow de Titulos a Pagar" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 1ª - Executando Workflow de Titulos a Pagar" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000003'
                        ConOut( "Inicio 1ª - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 1ª - Executando Workflow de Canhotos Pendentes" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000004'
                        ConOut( "Inicio 1ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 1ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio 1ª - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 1ª - Executando Workflow de Resumo dos Canhotos" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio 1ª - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_PRIDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 1ª - Executando Workflow Aging List" )
                    EndIf
                            If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio 1ª - Workflow Central aprovação Nivel 01")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_PRIDAT := DATE()
                                MSUnlock()
                            ConOut("Termino 1ª - Workflow Central aprovação Nivel 01")
                            EndIf
                EndIf
            EndIf
        EndIf
        // SEGUNDA EXECUCAO
        If !EMPTY(ZCJ->ZCJ_SEGEXE)
            IF ZCJ->ZCJ_SEGEXE > SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))-5))) .and. ZCJ->ZCJ_SEGEXE < SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))+5)))
                If ( EMPTY(ZCJ->ZCJ_SEGDAT) .OR. ZCJ->ZCJ_SEGDAT <> DATE() )
                    If ZCJ->ZCJ_CODWKF = '000001'
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ConOut( "Inicio 2ª - Executando Workflow de Combustiveis" )
                        ADCO020A()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 2ª - Executando Workflow de Combustiveis" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000002'
                        ConOut( "Inicio 2ª - Executando Workflow de Titulos a Pagar" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 2ª - Executando Workflow de Titulos a Pagar" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000003'
                        ConOut( "Inicio 2ª - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 2ª - Executando Workflow de Canhotos Pendentes" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000004'
                        ConOut( "Inicio 2ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 2ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio 2ª - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 2ª - Executando Workflow de Resumo dos Canhotos" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio 2ª - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_SEGDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 2ª - Executando Workflow Aging List" )
                    EndIf
                            If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio 2ª - Workflow Central aprovação Nivel")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_SEGDAT := DATE()
                                MSUnlock()
                            ConOut("Termino 2ª - Workflow Central aprovação Nivel")
                            EndIf
                EndIf
            EndIf
        EndIf
        // TERCEIRA EXECUCAO
        If !EMPTY(ZCJ->ZCJ_TEREXE)
            IF ZCJ->ZCJ_TEREXE > SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))-5))) .and. ZCJ->ZCJ_TEREXE < SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))+5)))
                If ( EMPTY(ZCJ->ZCJ_TERDAT) .OR. ZCJ->ZCJ_TERDAT <> DATE() )
                    If ZCJ->ZCJ_CODWKF = '000001'
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut( "Inicio 3ª - Executando Workflow de Combustiveis" )
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020A()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 3ª - Executando Workflow de Combustiveis" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000002'
                        ConOut( "Inicio 3ª - Executando Workflow de Titulos a Pagar" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 3ª - Executando Workflow de Titulos a Pagar" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000003'
                        ConOut( "Inicio 3ª - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 3ª - Executando Workflow de Canhotos Pendentes" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000004'
                        ConOut( "Inicio 3ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 3ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio 3ª - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 3ª - Executando Workflow de Resumo dos Canhotos" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio 3ª - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_TERDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 3ª - Executando Workflow Aging List" )
                    EndIf
                            If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio 3ª - Workflow Central aprovação Nivel")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_TERDAT := DATE()
                                MSUnlock()
                            ConOut("Termino 3ª - Workflow Central aprovação Nivel")
                            EndIf
                EndIf
            EndIf
        EndIf
        // QUARTA EXECUCAO
        If !EMPTY(ZCJ->ZCJ_QUAEXE)
            IF ZCJ->ZCJ_QUAEXE > SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))-5))) .and. ZCJ->ZCJ_QUAEXE < SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))+5)))
                If ( EMPTY(ZCJ->ZCJ_QUADAT) .OR. ZCJ->ZCJ_QUADAT <> DATE() )
                    If ZCJ->ZCJ_CODWKF = '000001'
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut( "Inicio 4ª - Executando Workflow de Combustiveis" )
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020A()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 4ª - Executando Workflow de Combustiveis" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000002'
                        ConOut( "Inicio 4ª - Executando Workflow de Titulos a Pagar" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 4ª - Executando Workflow de Titulos a Pagar" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000003'
                        ConOut( "Inicio 4ª - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 4ª - Executando Workflow de Canhotos Pendentes" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000004'
                        ConOut( "Inicio 4ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 4ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio 4ª - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 4ª - Executando Workflow de Resumo dos Canhotos" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio 4ª - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUADAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 4ª - Executando Workflow Aging List" )
                    EndIf
                            If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio 4ª - Workflow Central aprovação Nivel")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_QUADAT := DATE()
                                MSUnlock()
                            ConOut("Termino 4ª - Workflow Central aprovação Nivel")
                            EndIf
                EndIf
            EndIf
        EndIf
        // QUINTA EXECUCAO
        IF !EMPTY(ZCJ->ZCJ_QUIEXE)
            IF ZCJ->ZCJ_QUIEXE > SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))-5))) .and. ZCJ->ZCJ_QUIEXE < SUBSTR(TIME(), 1, 2) +':'+ Alltrim(str((val(SUBSTR(TIME(), 4, 2))+5)))
                If ( EMPTY(ZCJ->ZCJ_QUIDAT) .OR. ZCJ->ZCJ_QUIDAT <> DATE() )
                    If ZCJ->ZCJ_CODWKF = '000001'
                        cDestWFgas := ZCJ->ZCJ_DESTWF
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut( "Inicio 5ª - Executando Workflow de Combustiveis" )
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020A()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 5ª - Executando Workflow de Combustiveis" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000002'
                        ConOut( "Inicio 5ª - Executando Workflow de Titulos a Pagar" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 5ª - Executando Workflow de Titulos a Pagar" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000003'
                        ConOut( "Inicio 5ª - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 5ª - Executando Workflow de Canhotos Pendentes" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000004'
                        ConOut( "Inicio 5ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                        ConOut( "Termino 5ª - Executando Workflow de Canhotos Pendentes por Transportador" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio 5ª - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 5ª - Executando Workflow de Resumo dos Canhotos" )
                    EndIf
                    If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio 5ª - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_QUIDAT := DATE()
                        MSUnlock()
                    ConOut( "Termino 5ª - Executando Workflow Aging List" )
                    EndIf
                            If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio 5ª - Workflow Central aprovação Nivel")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_QUIDAT := DATE()
                                MSUnlock()
                            ConOut("Termino 5ª - Workflow Central aprovação Nivel")
                            EndIf
                EndIf
            EndIf
        EndIf
     Else
        IF ALLTRIM(STR(DOW( DATE() ))) $ ZCJ->ZCJ_EXESEM  .AND. SUBSTR(TIME(), 1, 5) >= ZCJ->ZCJ_HORSEM
            IF (EMPTY(ZCJ->ZCJ_DATSEM) .OR. DOW(DATE()) <> DOW(ZCJ->ZCJ_DATSEM))
                If ZCJ->ZCJ_CODWKF = '000001'
                    cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                    cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                    ConOut( "Inicio - Executando Workflow de Combustiveis" )
                    ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                    ADCO020A()
                    RecLock("ZCJ", .F. )
                        ZCJ->ZCJ_DATSEM := DATE()
                    MSUnlock()
                    ConOut( "Termino - Executando Workflow de Combustiveis" )
                EndIf
                If ZCJ->ZCJ_CODWKF = '000002'
                    ConOut( "Inicio - Executando Workflow de Titulos a Pagar" )
                    cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                    cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                    ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        ADCO020B( Alltrim(ZCJ->ZCJ_CNPJRZ) )
                    RecLock("ZCJ", .F. )
                        ZCJ->ZCJ_DATSEM := DATE()
                    MSUnlock()
                    ConOut( "Termino - Executando Workflow de Titulos a Pagar" )
                EndIf
                If ZCJ->ZCJ_CODWKF = '000003'
                    ConOut( "Inicio - Executando Workflow de Canhotos Pendentes" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                                ConOut('Destino Workflow Gerencial: ' + cDestWFgas +"-"+cCopDeswf)
                            ADCO020C()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_DATSEM := DATE()
                        MSUnlock()
                    ConOut( "Termino - Executando Workflow de Canhotos Pendentes" )
                EndIf
                If ZCJ->ZCJ_CODWKF = '000004'
                    ConOut( "Inicio - Executando Workflow de Canhotos Pendentes por Transportador" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020D()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_DATSEM := DATE()
                        MSUnlock()
                    ConOut( "Termino - Executando Workflow de Canhotos Pendentes por Transportador" )
                EndIf
                If ZCJ->ZCJ_CODWKF = '000005'
                    ConOut( "Inicio - Executando Workflow de Resumo dos Canhotos" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                            ADCO020E()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_DATSEM := DATE()
                        MSUnlock()
                    ConOut( "Termino - Executando Workflow de Resumo dos Canhotos" )
                EndIf
                If ZCJ->ZCJ_CODWKF = '000006'
                    ConOut( "Inicio - Executando Workflow Aging List" )
                        cDestWFgas := Alltrim(ZCJ->ZCJ_DESTWF)
                        cCopDeswf  := Alltrim(ZCJ->ZCJ_DESCWF)
                        ConOut('Destino Workflow Gerencial: ' + cDestWFgas )
                        	U_ADCOAGLI()
                        RecLock("ZCJ", .F. )
                            ZCJ->ZCJ_DATSEM := DATE()
                        MSUnlock()
                    ConOut( "Termino - Executando Workflow Aging List" )
                EndIf
                        If ZCJ->ZCJ_CODWKF $ sWFCentral
                            ConOut("Inicio - Workflow Central aprovação Nivel")
                                U_ADCOWFCA(Alltrim(ZCJ->ZCJ_DESWFK))
                                RecLock("ZCJ", .F. )
                                    ZCJ->ZCJ_DATSEM := DATE()
                                MSUnlock()
                            ConOut("Termino - Workflow Central aprovação Nivel")
                        EndIf
            EndIf
        EndIf
     EndIf
    ENDIF 
    ZCJ->(DbSkip())
    END

    IF lAutoJob
        RpcClearEnv()
        ConOut( "Termino - Workflow Gerencial - " + time() )
    EndIf

Return()
/*/{Protheus.doc} ADCO020A
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020A

    //Variáveis.
    Local cMsg   := ""
    Local cQuery := ""
    Local cAno  := ALLTRIM(STR(Year(DATE() - 5)))
    Local cMes  := ALLTRIM(STR(MONTH(DATE() - 5)))
    Local cAssunto := "Entradas de Óleo Diesel"

    cQuery := " SELECT D1_FILIAL, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_PEDIDO, D1_FORNECE, D1_LOJA, A2_NOME, D1_DOC, D1_EMISSAO , D1_DTDIGIT "
    cQuery += " FROM "+ RetSqlName("SD1") +" NOTA WITH (NOLOCK) "
    cQuery += " INNER JOIN "+ RetSqlName("SB1") +" PROD ON (PROD.B1_COD = NOTA.D1_COD) AND (PROD.D_E_L_E_T_='')"
    cQuery += " INNER JOIN "+ RetSqlName("SA2") +" CAD ON (CAD.A2_COD = NOTA.D1_FORNECE) AND (CAD.A2_LOJA = NOTA.D1_LOJA) AND (CAD.D_E_L_E_T_='')"
    cQuery += " WHERE (NOTA.D1_FILIAL = '02') AND YEAR(NOTA.D1_DTDIGIT) >= '"+ cAno +"' AND MONTH(NOTA.D1_DTDIGIT) >= '"+ cMes +"' AND (NOTA .D1_COD IN ('520529','581459')) AND (NOTA.D_E_L_E_T_='')"
    cQuery += " ORDER BY D1_FILIAL, D1_DTDIGIT, D1_PEDIDO "
    If Select("ADCOMQ020") > 0
    	ADCOMQ020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMQ020"

    if ADCOMQ020->( !EOF() )    

        cMsg := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
        cMsg += "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'>"
        cMsg += "<head>"
        cMsg += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
        cMsg += "<title>1 sem título</title>"
        cMsg += "<style type='text/css'>"
        cMsg += "td"
        cMsg += "{border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding-top:1px;"
        cMsg += "					padding-right:1px;"
        cMsg += "					padding-left:1px;"
        cMsg += "					color:black;"
        cMsg += "					font-size:11.0pt;"
        cMsg += "					font-weight:400;"
        cMsg += "					font-style:normal;"
        cMsg += "					text-decoration:none;"
        cMsg += "					font-family:Calibri, sans-serif;"
        cMsg += "					text-align:general;"
        cMsg += "					vertical-align:bottom;"
        cMsg += "					white-space:nowrap;"
        cMsg += "	}"
        cMsg += ".style1 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 14.0pt;"
        cMsg += "				font-weight: 700;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Bahnschrift;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding-left: 1px;"
        cMsg += "				padding-right: 1px;"
        cMsg += "				padding-top: 1px;"
        cMsg += "}"
        cMsg += ".style6 {"
        cMsg += "				font-family: Bahnschrift;"
        cMsg += "}"
        cMsg += ".style7 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Bahnschrift;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border: .5pt solid black;"
        cMsg += "				padding-left: 1px;"
        cMsg += "				padding-right: 1px;"
        cMsg += "				padding-top: 1px;"
        cMsg += "				background: silver;"
        cMsg += "}"
        cMsg += ".style8 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Bahnschrift;"
        cMsg += "				text-align: general;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding-left: 1px;"
        cMsg += "				padding-right: 1px;"
        cMsg += "				padding-top: 1px;"
        cMsg += "}"
        cMsg += ".style10 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Bahnschrift;"
        cMsg += "				text-align: right;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding-left: 1px;"
        cMsg += "				padding-right: 1px;"
        cMsg += "				padding-top: 1px;"
        cMsg += "}"
        cMsg += "</style>"
        cMsg += "</head>"
        cMsg += "<body>"
        cMsg += "<p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p>"
        cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='1392' style='border-collapse:"
        cMsg += "collapse;width:1046pt'>"
        cMsg += "				<colgroup>"
        cMsg += "								<col width='75' style='mso-width-source:userset;mso-width-alt:2742;width:56pt' />"
        cMsg += "								<col width='43' style='mso-width-source:userset;mso-width-alt:1572;width:32pt' />"
        cMsg += "								<col width='57' style='mso-width-source:userset;mso-width-alt:2084;width:43pt' />"
        cMsg += "								<col width='37' style='mso-width-source:userset;mso-width-alt:1353;width:28pt' />"
        cMsg += "								<col width='419' style='mso-width-source:userset;mso-width-alt:15323;width:314pt' />"
        cMsg += "								<col width='78' style='mso-width-source:userset;mso-width-alt:2852;width:59pt' />"
        cMsg += "								<col width='90' style='mso-width-source:userset;mso-width-alt:3291;width:68pt' />"
        cMsg += "								<col width='98' style='mso-width-source:userset;mso-width-alt:3584;width:74pt' />"
        cMsg += "								<col width='73' style='mso-width-source:userset;mso-width-alt:2669;width:55pt' />"
        cMsg += "								<col width='146' style='mso-width-source:userset;mso-width-alt:5339;width:110pt' />"
        cMsg += "								<col width='92' style='mso-width-source:userset;mso-width-alt:3364;width:69pt' />"
        cMsg += "								<col width='92' style='mso-width-source:userset;mso-width-alt:3364;width:69pt' />"
        cMsg += "								<col width='92' style='mso-width-source:userset;mso-width-alt:3364;width:69pt' />"
        cMsg += "				</colgroup>"
        cMsg += "				<tr height='25' style='height:18.75pt'>"
        cMsg += "								<td colspan='13' height='25' width='1392' style='height: 18.75pt; width: 1046pt' class='style1'>ENTRADAS DE COMBUSTIVEIS</td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='30' style='mso-height-source:userset;height:22.5pt'>"
        cMsg += "								<td height='30' style='height: 22.5pt' class='style7'>Data Entrada</td>"
        cMsg += "								<td class='style7'>Filial</td>"
        cMsg += "								<td class='style7'>Codigo</td>"
        cMsg += "								<td class='style7'>Loja</td>"
        cMsg += "								<td class='style7'>Razão Social</td>"
        cMsg += "								<td class='style7'>Numero Pedido</td>"
        cMsg += "								<td class='style7'>Nota Fiscal</td>"
        cMsg += "								<td class='style7'>Data Emissão</td>"
        cMsg += "								<td class='style7'>Codigo Produto</td>"
        cMsg += "								<td class='style7'>Descrição Produto</td>"
        cMsg += "								<td class='style7'>Quantidade</td>"
        cMsg += "								<td class='style7'>Valor Unitario</td>"
        cMsg += "								<td class='style7'>Valor Total</td>"
        cMsg += "				</tr>"
        WHILE ADCOMQ020->(!EOF())
            cMsg += "				<tr height='9' style='mso-height-source:userset;height:6.75pt'>"
            cMsg += "								<td height='9' style='height: 6.75pt' class='style10'>"+DTOC(STOD(ADCOMQ020->D1_DTDIGIT))+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_FILIAL+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_FORNECE+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_LOJA+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->A2_NOME+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_PEDIDO+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_DOC+"</td>"
            cMsg += "								<td class='style10'>"+DTOC(STOD(ADCOMQ020->D1_EMISSAO))+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->D1_COD+"</td>"
            cMsg += "								<td class='style10'>"+ADCOMQ020->B1_DESC+"</td>"
            cMsg += "								<td class='style10'>"+Transform( ADCOMQ020->D1_QUANT , "@E 9,999,999,999.99" )+"</td>"
            cMsg += "								<td class='style10'>"+Transform( ADCOMQ020->D1_VUNIT , "@E 9,999,999,999.99" )+"</td>"
            cMsg += "								<td class='style10'>"+Transform( ADCOMQ020->D1_TOTAL , "@E 9,999,999,999.99" )+"</td>"
            cMsg += "				</tr>"
            ADCOMQ020->( DbSkip()  )
        END 
        cMsg += "</table>"
        cMsg += "<p>&nbsp;</p>"
        cMsg += "<p class='style6'>Workflow Logística</p>"
        cMsg += "</body>"
        cMsg += "</html>"

            IF !EMPTY(cDestWFgas)
                //u_F050EnvWF( cAssunto , cMsg , cDestWFgas , cCopDeswf )
                U_F50En2WF(cDestWFgas , cCopDeswf , cAssunto , cMsg , '' )
            ENDIF

    EndIf

Return
/*/{Protheus.doc} ADCO020B
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020B(cCnpjRZ)

    //Variáveis.
    Local cMsg   := ""
    Local cQuery := ""
    Local cAssunto  := "Alerta de Títulos à Pagar"
    Local aRzCpnj   := CTBSplit( cCnpjRZ , ",")

    for a:=1 to len(aRzCpnj)

        cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_HIST, E2_SALDO, D_E_L_E_T_, E2_LOGDTHR "
        cQuery += " FROM "+ RetSqlName("SE2") +" "
        cQuery += " WHERE substring(E2_CGC,1,8) = '"+aRzCpnj[a]+"' "
        cQuery += " AND E2_SALDO > 0 "
        cQuery += " AND E2_TIPO NOT IN ('RJ','NDC') " //Everson - 29/07/2020. Chamado 059641.
        cQuery += " AND D_E_L_E_T_ = '' "
        cQuery += " ORDER BY E2_TIPO, E2_EMISSAO "
    
        If Select("ADCOMT020") > 0
    	    ADCOMT020->(DbCloseArea())
        EndIf	
        TcQuery cQuery New Alias "ADCOMT020"

        if ADCOMT020->( !EOF() ) 

            cMsg := " <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "
            cMsg += " <html xmlns='http://www.w3.org/1999/xhtml'>"
            cMsg += " <head>"
            cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
            cMsg += " <title>Bitmap</title>"
            cMsg += " <style type='text/css'>"
	        cMsg += " {border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " 				color:black;"
            cMsg += " 					font-size:11.0pt;"
            cMsg += " 					font-weight:400;"
            cMsg += " 					font-style:normal;"
            cMsg += " 					text-decoration:none;"
            cMsg += " 					font-family:Calibri, sans-serif;"
            cMsg += " 					text-align:general;"
            cMsg += " 					vertical-align:bottom;"
            cMsg += " 					white-space:nowrap;"
            cMsg += " 	}"
            cMsg += " .style1 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 14.0pt;"
            cMsg += " 				font-weight: 700;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: center-across;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style2 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: left;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style3 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 700;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: general;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style4 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 700;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: right;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style5 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 11.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: general;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-left-style: none;"
            cMsg += " 				border-left-color: inherit;"
            cMsg += " 				border-left-width: medium;"
            cMsg += " 				border-right-style: none;"
            cMsg += " 				border-right-color: inherit;"
            cMsg += " 				border-right-width: medium;"
            cMsg += " 				border-top: .5pt solid windowtext;"
            cMsg += " 				border-bottom-style: none;"
            cMsg += " 				border-bottom-color: inherit;"
            cMsg += " 				border-bottom-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style6 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: general;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style7 {"
            cMsg += " 				color: red;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 700;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: general;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style8 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: right;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style9 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: general;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-left-style: none;"
            cMsg += " 				border-left-color: inherit;"
            cMsg += " 				border-left-width: medium;"
            cMsg += " 				border-right-style: none;"
            cMsg += " 				border-right-color: inherit;"
            cMsg += " 				border-right-width: medium;"
            cMsg += " 				border-top-style: none;"
            cMsg += " 				border-top-color: inherit;"
            cMsg += " 				border-top-width: medium;"
            cMsg += " 				border-bottom: .5pt solid windowtext;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style10 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 9.0pt;"
            cMsg += " 				font-weight: 700;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: center;"
            cMsg += " 				vertical-align: middle;"
            cMsg += " 				white-space: normal;"
            cMsg += " 				border-left-style: none;"
            cMsg += " 				border-left-color: inherit;"
            cMsg += " 				border-left-width: medium;"
            cMsg += " 				border-right-style: none;"
            cMsg += " 				border-right-color: inherit;"
            cMsg += " 				border-right-width: medium;"
            cMsg += " 				border-top: .5pt solid windowtext;"
            cMsg += " 				border-bottom: .5pt solid windowtext;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style11 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 11.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: center;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style12 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 11.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: right;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " .style13 {"
            cMsg += " 				color: black;"
            cMsg += " 				font-size: 11.0pt;"
            cMsg += " 				font-weight: 400;"
            cMsg += " 				font-style: normal;"
            cMsg += " 				text-decoration: none;"
            cMsg += " 				font-family: Calibri, sans-serif;"
            cMsg += " 				text-align: left;"
            cMsg += " 				vertical-align: bottom;"
            cMsg += " 				white-space: nowrap;"
            cMsg += " 				border-style: none;"
            cMsg += " 				border-color: inherit;"
            cMsg += " 				border-width: medium;"
            cMsg += " 				padding: 0px;"
            cMsg += " }"
            cMsg += " </style>"
            cMsg += " </head>"
            cMsg += " <body>"
            cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1003' style='border-collapse: collapse; width: 755pt'>"
            cMsg += " 				<colgroup>"
            cMsg += " 								<col width='7' style='mso-width-source: userset; mso-width-alt: 256; width: 5pt' />"
            cMsg += " 								<col width='62' style='mso-width-source: userset; mso-width-alt: 2267; width: 47pt' />"
            cMsg += " 								<col width='62' style='mso-width-source: userset; mso-width-alt: 2267; width: 47pt' />"
            cMsg += " 								<col width='62' style='mso-width-source: userset; mso-width-alt: 2267; width: 47pt' />"
            cMsg += " 								<col width='82' style='mso-width-source: userset; mso-width-alt: 2998; width: 62pt' />"
            cMsg += " 								<col width='94' span='2' style='mso-width-source: userset; mso-width-alt: 3437; width: 71pt' />"
            cMsg += " 								<col width='84' span='2' style='mso-width-source: userset; mso-width-alt: 3072; width: 63pt' />"
            cMsg += " 								<col width='372' style='mso-width-source: userset; mso-width-alt: 13604; width: 279pt' />"
            cMsg += " 				</colgroup>"
            cMsg += " 				<tr height='20' style='height: 15.0pt'>"
            cMsg += " 								<td height='20' width='7' style='height: 15.0pt; width: 5pt' align='left' valign='top'>"
            cMsg += " 								<span style='mso-ignore: vglayout; position: absolute; z-index: 1; margin-left: 3px; margin-top: 3px; width: 78px; height: 61px'>"
            cMsg += " 								<img width='78' height='61' src='http://www.adoro.com.br/images/logo-adoro.png' v:shapes='Imagem_x0020_1' /></span><![endif]><span style='mso-ignore: vglayout2'>"
            cMsg += " 								</span></td>"
            cMsg += " 								<td width='62' style='width: 47pt'></td>"
            cMsg += " 								<td width='62' style='width: 47pt'></td>"
            cMsg += " 								<td width='62' style='width: 47pt'></td>"
            cMsg += " 								<td width='82' style='width: 62pt'></td>"
            cMsg += " 								<td width='94' style='width: 71pt'></td>"
            cMsg += " 								<td width='94' style='width: 71pt'></td>"
            cMsg += " 								<td width='84' style='width: 63pt'></td>"
            cMsg += " 								<td width='84' style='width: 63pt'></td>"
            cMsg += " 								<td width='372' style='width: 279pt'></td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='43' style='mso-height-source: userset; height: 32.25pt'>"
            cMsg += " 								<td height='43' colspan='10' align='center' style='height: 32.25pt; mso-ignore: colspan' class='style1'>"
            cMsg += " 								ALERTA DE TÍTULOS À PAGAR</td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='25' style='height: 18.75pt'>"
            cMsg += " 								<td height='25' style='height: 18.75pt' class='style1'>"
            cMsg += " 								</td>"
            cMsg += " 								<td class='style2'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style3'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style1'></td>"
            cMsg += " 								<td class='style4'>"+dtoc(date())+" - "+time()+"</td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
            cMsg += " 								<td height='8' style='height: 6.0pt' class='style5'>"
            cMsg += " 								&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 								<td class='style5'>&nbsp;</td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='16' style='height: 12.0pt'>"
            cMsg += " 								<td height='16' style='height: 12.0pt' class='style6'>"
            cMsg += " 								</td>"
            cMsg += " 								<td colspan='2' style='mso-ignore: colspan' class='style6'>"
            cMsg += " 								Fornecedor: </td>"
            cMsg += " 								<td colspan='2' style='mso-ignore: colspan' class='style7'>"
            cMsg += " 								"+ADCOMT020->E2_NOMFOR+"<span style='mso-spacerun: yes'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>"
            cMsg += " 								<td class='style6'></td>"
            cMsg += " 								<td class='style8'></td>"
            cMsg += " 								<td class='style3'></td>"
            cMsg += " 								<td class='style3'></td>"
            cMsg += " 								<td class='style3'></td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
            cMsg += " 								<td height='8' style='height: 6.0pt' class='style9'>"
            cMsg += " 								&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 								<td class='style9'>&nbsp;</td>"
            cMsg += " 				</tr>"
            cMsg += " 				<tr height='16' style='height: 12.0pt'>"
            cMsg += " 								<td height='16' width='7' style='height: 12.0pt; width: 5pt' class='style10'>&nbsp;</td>"
            cMsg += " 								<td width='62' style='width: 47pt' class='style10'>Filial</td>"
            cMsg += " 								<td width='62' style='width: 47pt' class='style10'>Prefixo</td>"
            cMsg += " 								<td width='62' style='width: 47pt' class='style10'>Tipo</td>"
            cMsg += " 								<td width='82' style='width: 62pt' class='style10'>Numero/Parcela</td>"
            cMsg += " 								<td width='94' style='width: 71pt' class='style10'>Emissão</td>"
            cMsg += " 								<td width='94' style='width: 71pt' class='style10'>Vencimento Real</td>"
            cMsg += " 								<td width='84' style='width: 63pt' class='style10'>Valor</td>"
            cMsg += " 								<td width='84' style='width: 63pt' class='style10'>Saldo</td>"
            cMsg += " 								<td width='372' style='width: 279pt' class='style10'>Histórico</td>"
            cMsg += " 				</tr>"
            While ADCOMT020->(!EOF())
                    cMsg += " 				<tr height='20' style='height: 15.0pt'>"
                    cMsg += " 								<td height='20' style='height: 15.0pt'></td>""
                    cMsg += " 								<td class='style11'>"+ADCOMT020->E2_FILIAL+"</td>"
                    cMsg += " 								<td class='style11'>"+ADCOMT020->E2_PREFIXO+"</td>"
                    cMsg += " 								<td class='style11'>"+ADCOMT020->E2_TIPO+"</td>"
                    cMsg += " 								<td class='style12'>"+ADCOMT020->E2_NUM+" / "+ADCOMT020->E2_PARCELA+"</td>"
                    cMsg += " 								<td class='style11'>"+dtoc(stod(ADCOMT020->E2_EMISSAO))+"</td>"
                    cMsg += " 								<td class='style11'>"+dtoc(stod(ADCOMT020->E2_VENCREA))+"</td>"
                    cMsg += " 								<td class='style11'>"+Transform( ADCOMT020->E2_VALOR,"@E 9,999,999,999.99" )+"</td>" 
                    cMsg += " 								<td class='style11'>"+Transform( ADCOMT020->E2_SALDO,"@E 9,999,999,999.99" )+"</td>"
                    cMsg += " 								<td class='style13'>"+ADCOMT020->E2_HIST+"</td>"
                    cMsg += " 				</tr>"
                ADCOMT020->(DbSkip())
            END
            cMsg += " </table>"
            cMsg += " </body>"
            cMsg += " </html>"
        
            IF !EMPTY(cDestWFgas) 
		        //u_F050EnvWF( cAssunto , cMsg , cDestWFgas , cCopDeswf )
                U_F50En2WF(cDestWFgas , cCopDeswf , cAssunto , cMsg , '' )
	        ENDIF
        EndIf

    next

Return
/*/{Protheus.doc} ADCO020C
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020C()

    //Variáveis.
    Local cMsg   := ""
    Local cQuery := ""
    Local cAssunto  := "Relatorio de Canhotos Pendentes"
    Local cNomCli   := "" 
    Local nQtdCA    := 0
    Local cTransp   := ""
    Local dDataIni  := DtoS(date()- SuperGetMv( "MV_#ADC20I" , .F. , 365 , ) )  //26/07/18 | Ricardo Lima
    Local dDataFim  := DtoS(date()- SuperGetMv( "MV_#ADC20F" , .F. , 1 , ) )    //26/07/18 | Ricardo Lima
    Local dDtParin  := SuperGetMv( "MV_#ADC20D" , .F. , "20170101" , )
     
    cQuery := " SELECT F2_TIPO, C5_TRANSP, A4_NOME A2_NREDUZ, C5_PLACA, C5_DTENTR, C5_NUM, F2_DOC, F2_CLIENTE, F2_LOJA, C5_CIDADE, C5_EST, A4_EST A2_EST, C5_ROTEIRO  "
    cQuery += " FROM "+ RetSqlName("SF2") +" F2 WITH (NOLOCK) "
    cQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 WITH (NOLOCK) ON F2_FILIAL=C5_FILIAL AND F2_DOC=C5_NOTA AND C5.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN "+ RetSqlName("SA4") +" A2 WITH (NOLOCK) ON A4_COD=C5_TRANSP "
    cQuery += " WHERE F2_FILIAL in ('02','07') AND C5_DTENTR BETWEEN '"+dDtParin+"' AND '"+dDataFim+"' AND F2.D_E_L_E_T_ = ' ' " //26/07/18 | Ricardo Lima
    cQuery += " AND C5_CANHOTO='' AND C5_TPFRETE = 'C' AND F2_SERIE <> 'ZZ' AND C5_EST <> 'EX' AND F2_TIPO = 'N' " //26/07/18 | Ricardo Lima
    cQuery += " AND C5_TRANSP NOT IN ('002922') "
    cQuery += " ORDER BY C5_TRANSP, C5_DTENTR "
    
    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"

    If ADCOMT020->( !EOF() ) 

        cMsg := " <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
        cMsg += " <html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'>"
        cMsg += " <head>"
        cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
        cMsg += " <title>Bitmap</title>"
        cMsg += " <style type='text/css'>"
        cMsg += " 	{border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " 				color:black;"
        cMsg += " 					font-size:11.0pt;"
        cMsg += " 					font-weight:400;"
        cMsg += " 					font-style:normal;"
        cMsg += " 					text-decoration:none;"
        cMsg += " 					font-family:Calibri, sans-serif;"
        cMsg += " 					text-align:general;"
        cMsg += " 					vertical-align:bottom;"
        cMsg += " 					white-space:nowrap;"
        cMsg += " 	}"
        cMsg += " .style1 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 14.0pt;"
        cMsg += " 				font-weight: 700;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: center-across;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style2 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 10.0pt;"
        cMsg += " 				font-weight: 700;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: center;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style3 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 9.0pt;"
        cMsg += " 				font-weight: 400;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: general;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style4 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 11.0pt;"
        cMsg += " 				font-weight: 400;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: general;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-left-style: none;"
        cMsg += " 				border-left-color: inherit;"
        cMsg += " 				border-left-width: medium;"
        cMsg += " 				border-right-style: none;"
        cMsg += " 				border-right-color: inherit;"
        cMsg += " 				border-right-width: medium;"
        cMsg += " 				border-top-style: none;"
        cMsg += " 				border-top-color: inherit;"
        cMsg += " 				border-top-width: medium;"
        cMsg += " 				border-bottom: .5pt solid windowtext;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style5 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 9.0pt;"
        cMsg += " 				font-weight: 700;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: center;"
        cMsg += " 				vertical-align: middle;"
        cMsg += " 				white-space: normal;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style6 {"
        cMsg += " 				color: black;"
        cMsg += " 				font-size: 9.0pt;"
        cMsg += " 				font-weight: 700;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: center;"
        cMsg += " 				vertical-align: middle;"
        cMsg += " 				white-space: normal;"
        cMsg += " 				border-left-style: none;"
        cMsg += " 				border-left-color: inherit;"
        cMsg += " 				border-left-width: medium;"
        cMsg += " 				border-right-style: none;"
        cMsg += " 				border-right-color: inherit;"
        cMsg += " 				border-right-width: medium;"
        cMsg += " 				border-top: .5pt solid windowtext;"
        cMsg += " 				border-bottom: .5pt solid windowtext;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style7 {"
        cMsg += " 				color: windowtext;"
        cMsg += " 				font-size: 11.0pt;"
        cMsg += " 				font-weight: 400;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: general;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style8 {"
        cMsg += " 				color: windowtext;"
        cMsg += " 				font-size: 11.0pt;"
        cMsg += " 				font-weight: 400;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: left;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " .style9 {"
        cMsg += " 				color: windowtext;"
        cMsg += " 				font-size: 11.0pt;"
        cMsg += " 				font-weight: 400;"
        cMsg += " 				font-style: normal;"
        cMsg += " 				text-decoration: none;"
        cMsg += " 				font-family: Calibri, sans-serif;"
        cMsg += " 				text-align: center;"
        cMsg += " 				vertical-align: bottom;"
        cMsg += " 				white-space: nowrap;"
        cMsg += " 				border-style: none;"
        cMsg += " 				border-color: inherit;"
        cMsg += " 				border-width: medium;"
        cMsg += " 				padding: 0px;"
        cMsg += " }"
        cMsg += " </style>"
        cMsg += " </head>"
        cMsg += " <body>"
        cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1174' style='border-collapse: collapse; width: 881pt'>"
        cMsg += " 				<colgroup>"
        cMsg += " 								<col width='7' style='mso-width-source: userset; mso-width-alt: 256; width: 5pt' />"
        cMsg += " 								<col width='303' style='mso-width-source: userset; mso-width-alt: 11081; width: 227pt' />"
        cMsg += " 								<col width='69' style='mso-width-source: userset; mso-width-alt: 2523; width: 52pt' />"
        cMsg += " 								<col width='69' style='mso-width-source: userset; mso-width-alt: 2523; width: 52pt' />"
        cMsg += " 								<col width='69' style='mso-width-source: userset; mso-width-alt: 2523; width: 52pt' />"
        cMsg += " 								<col width='98' style='mso-width-source: userset; mso-width-alt: 3584; width: 74pt' />"
        cMsg += " 								<col width='259' style='mso-width-source: userset; mso-width-alt: 9472; width: 194pt' />"
        cMsg += " 								<col width='155' style='mso-width-source: userset; mso-width-alt: 5668; width: 116pt' />"
        cMsg += " 								<col width='45' style='mso-width-source: userset; mso-width-alt: 1645; width: 34pt' />"
        cMsg += " 								<col width='52' style='mso-width-source: userset; mso-width-alt: 1901; width: 39pt' />"
        cMsg += " 								<col width='48' style='mso-width-source: userset; mso-width-alt: 1755; width: 36pt' />"
        cMsg += " 				</colgroup>"
        cMsg += " 				<tr height='20' style='height: 15.0pt'>"
        cMsg += " 								<td height='20' width='7' style='height: 15.0pt; width: 5pt' align='left' valign='top'>"
        cMsg += " 								<span style='mso-ignore: vglayout; position: absolute; z-index: 1; margin-left: 3px; margin-top: 3px; width: 78px; height: 61px'>"
        cMsg += " 								<img width='78' height='61' src='http://www.adoro.com.br/images/logo-adoro.png' v:shapes='Imagem_x0020_1' /></span><span style='mso-ignore: vglayout2'>"
        cMsg += " 								<table cellpadding='0' cellspacing='0'>"
        cMsg += " 									<tr>"
        cMsg += " 										<td height='20' width='7' style='height: 15.0pt; width: 5pt'>"
        cMsg += " 										</td>"
        cMsg += " 									</tr>"
        cMsg += " 								</table>"
        cMsg += " 								</span></td>"
        cMsg += " 								<td width='303' style='width: 227pt'></td>"
        cMsg += " 								<td width='69'  style='width: 52pt'> </td>"
        cMsg += " 								<td width='69'  style='width: 52pt'> </td>"
        cMsg += " 								<td width='69'  style='width: 52pt'> </td>"
        cMsg += " 								<td width='98'  style='width: 74pt'> </td>"
        cMsg += " 								<td width='259' style='width: 194pt'></td>"
        cMsg += " 								<td width='155' style='width: 116pt'></td>"
        cMsg += " 								<td width='45'  style='width: 34pt'> </td>"
        cMsg += " 								<td width='52'  style='width: 39pt'> </td>"
        cMsg += " 								<td width='48'  style='width: 36pt'> </td>"
        cMsg += " 				</tr>"
        cMsg += " 				<tr height='43' style='mso-height-source: userset; height: 32.25pt'>"
        cMsg += " 								<td height='43' colspan='11' align='center' style='height: 32.25pt; mso-ignore: colspan' class='style1'>"
        cMsg += " 								RELATÓRIO DE CANHOTOS PENDENTES POR TRANSPORTADOR</td>"
        cMsg += " 				</tr>"
        cMsg += " 				<tr height='25' style='height: 18.75pt'>"
        cMsg += " 								<td height='25' style='height: 18.75pt' class='style1'>"
        cMsg += " 								</td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td class='style1'></td>"
        cMsg += " 								<td colspan='3' class='style2'>"+DTOC(Date())+" - "+Time()+"</td>"
        cMsg += " 				</tr>"
        cMsg += " 				<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
        cMsg += " 								<td height='8' style='height: 6.0pt' class='style3'>"
        cMsg += " 								</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 								<td class='style4'>&nbsp;</td>"
        cMsg += " 				</tr>"
        cMsg += " 				<tr height='16' style='height: 12.0pt'>"
        cMsg += " 								<td height='16' width='7' style='height: 12.0pt; width: 5pt' class='style5'></td>"
        cMsg += " 								<td width='303' style='width: 227pt' class='style6'>Transportador</td>"
        cMsg += " 								<td width='69'  style='width: 52pt'  class='style6'>Placa</td>"
        cMsg += " 								<td width='69'  style='width: 52pt'  class='style6'>Data Entrega</td>"
        cMsg += " 								<td width='69'  style='width: 52pt'  class='style6'>Pedido</td>"
        cMsg += " 								<td width='98'  style='width: 74pt'  class='style6'>Nota Fiscal</td>"
        cMsg += " 								<td width='259' style='width: 194pt' class='style6'>Cliente</td>"
        cMsg += " 								<td width='155' style='width: 116pt' class='style6'>Cidade</td>"
        cMsg += " 								<td width='45'  style='width: 34pt'  class='style6'>Estado</td>"
        cMsg += " 								<td width='52'  style='width: 39pt'  class='style6'>Roteiro</td>"
        cMsg += " 								<td width='48'  style='width: 36pt'  class='style6'>Atraso</td>"
        cMsg += " 				</tr>"    
        
        cTransp := ADCOMT020->C5_TRANSP

        While ADCOMT020->( !EOF() )
            
            If cTransp <> ADCOMT020->C5_TRANSP
                cMsg += " 				<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
                cMsg += " 								<td height='8' style='height: 6.0pt' class='style3'>"
                cMsg += " 								</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>&nbsp;</td>"
                cMsg += " 								<td class='style4'>Total: </td>"
                cMsg += " 								<td class='style4'>"+Alltrim(Str(nQtdCA))+"</td>"
                cMsg += " 				</tr>"

                nQtdCA := 0
            EndIf
            
            if ADCOMT020->F2_TIPO = 'N'
                dbselectarea("SA1")
                dbsetorder(1)
                If dbSeek( FWxFilial("SA1") + ADCOMT020->F2_CLIENTE + ADCOMT020->F2_LOJA )
                    cNomCli := SA1->A1_NOME
                Else
                    cNomCli := ""
                EndIf
            Else
                dbselectarea("SA2")
                dbsetorder(1)
                If dbSeek( FWxFilial("SA2") + ADCOMT020->F2_CLIENTE + ADCOMT020->F2_LOJA )
                    cNomCli := SA2->A2_NOME
                Else
                    cNomCli := ""
                EndIf
            EndIf

            cMsg += " 				<tr height='9' style='mso-height-source: userset; height: 6.75pt'>"
            cMsg += " 								<td height='9' style='height: 6.75pt' class='style7'></td>"
            cMsg += " 								<td class='style8'>"+ADCOMT020->C5_TRANSP+"-"+ADCOMT020->A2_NREDUZ+"</td>"
            cMsg += " 								<td class='style9'>"+ADCOMT020->C5_PLACA+"</td>"
            cMsg += " 								<td class='style9'>"+DTOC(STOD(ADCOMT020->C5_DTENTR))+"</td>"
            cMsg += " 								<td class='style9'>"+ADCOMT020->C5_NUM+"</td>"
            cMsg += " 								<td class='style9'>"+ADCOMT020->F2_DOC+"</td>"
            cMsg += " 								<td class='style8'>"+cNomCli+"</td>"
            cMsg += " 								<td class='style8'>"+ADCOMT020->C5_CIDADE+"</td>"
            cMsg += " 								<td class='style9'>"+ADCOMT020->C5_EST+"</td>"
            cMsg += " 								<td class='style9'>"+ADCOMT020->C5_ROTEIRO+"</td>"
            cMsg += " 								<td class='style9'>"+ Alltrim( str(Date() - STOD(ADCOMT020->C5_DTENTR)) ) +"</td>"
            cMsg += " 				</tr>"

            nQtdCA++
            cTransp := ADCOMT020->C5_TRANSP
        ADCOMT020->( DbSkip() )
        END
        cMsg += "		<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
        cMsg += "						<td height='8' style='height: 6.0pt' class='style3'>"
        cMsg += "						</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>&nbsp;</td>"
        cMsg += "						<td class='style4'>Total: </td>"
        cMsg += "						<td class='style4'>"+Alltrim(Str(nQtdCA))+"</td>"
        cMsg += "		</tr>"
        cMsg += " </table>"
        cMsg += " </body>"
        cMsg += " </html>"

    EndIf

    IF !EMPTY(cDestWFgas) 
		//u_F050EnvWF( cAssunto , cMsg , cDestWFgas , cCopDeswf )
        U_F50En2WF(cDestWFgas , cCopDeswf , cAssunto , cMsg , '' )
	ENDIF

Return
/*/{Protheus.doc} ADCO020D
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020D()

    //Variáveis.
    Local cMsg   := ""
    Local cQuery := ""
    Local dQuery := ""
    Local cAssunto  := "Relatorio de Canhotos Pendentes por Transportador"
    Local cNomCli   := "" 
    Local nQtdCA    := 0
    Local sEmailTrp := ""
    Local sEmailCpl := ""
    Local dDataIni  := DtoS(date()- SuperGetMv( "MV_#ADC20I" , .F. , 365 , ) )  //26/07/18 | Ricardo Lima
    Local dDtParin  := SuperGetMv( "MV_#ADC20D" , .F. , "20170101" , )

    nServerPRD := SuperGetMv( "MV_#ADC20S" , .F. , '' , )

    cQuery := " SELECT DISTINCT C5_TRANSP "
    cQuery += " FROM "+ RetSqlName("SF2") +" F2 "
    cQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 ON F2_FILIAL=C5_FILIAL AND F2_DOC=C5_NOTA AND C5.D_E_L_E_T_ = ' ' "
    cQuery += " INNER JOIN "+ RetSqlName("SA4") +" A4 ON A4_COD=C5_TRANSP "
    cQuery += " WHERE F2_FILIAL in ('02','07') AND F2_EMISSAO>='"+dDtParin+"' AND F2.D_E_L_E_T_ = ' ' "
    cQuery += " AND C5_CANHOTO='' AND C5_TPFRETE = 'C' AND F2_SERIE <> 'ZZ' "
    cQuery += " ORDER BY C5_TRANSP "
    
    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"

    While ADCOMT020->( !EOF() )
            
        dQuery := " SELECT F2_TIPO, A4_NOME, A4_EMAIL, C5_TRANSP, C5_PLACA, C5_DTENTR, C5_NUM, F2_DOC, F2_CLIENTE, F2_LOJA, C5_CIDADE, C5_EST, C5_ROTEIRO "
        dQuery += " FROM "+ RetSqlName("SF2") +" F2 "
        dQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 ON F2_FILIAL=C5_FILIAL AND F2_DOC=C5_NOTA AND C5.D_E_L_E_T_ = ' ' "
        dQuery += " INNER JOIN "+ RetSqlName("SA4") +" A4 ON A4_COD=C5_TRANSP "
        dQuery += " WHERE F2_FILIAL in ('02','07') AND F2_EMISSAO>='"+dDataIni+"' AND F2.D_E_L_E_T_ = ' ' "
        dQuery += " AND C5_CANHOTO='' AND C5_TPFRETE = 'C' AND F2_SERIE <> 'ZZ' AND C5_EST <> 'EX' "
        dQuery += " AND C5_TRANSP = '"+ADCOMT020->C5_TRANSP+"' "
        dQuery += " ORDER BY C5_TRANSP, C5_DTENTR "
        If Select("ADCOMP020") > 0
 	        ADCOMP020->(DbCloseArea())
        EndIf	
        TcQuery dQuery New Alias "ADCOMP020"

        If ADCOMP020->(!EOF())
            sEmailTrp := Alltrim(ADCOMP020->A4_EMAIL)
            
            cMsg := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
            cMsg += "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'>"
            cMsg += "<head>"
            cMsg += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
            cMsg += "<title>RELATÓRIO DE CANHOTOS PENDENTES</title>"
            cMsg += "<style type='text/css'>"
            cMsg += "	{border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "				color:black;"
            cMsg += "					font-size:11.0pt;"
            cMsg += "					font-weight:400;"
            cMsg += "					font-style:normal;"
            cMsg += "					text-decoration:none;"
            cMsg += "					font-family:Calibri, sans-serif;"
            cMsg += "					text-align:general;"
            cMsg += "					vertical-align:bottom;"
            cMsg += "					white-space:nowrap;"
            cMsg += "	}"
            cMsg += ".style1 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 14.0pt;"
            cMsg += "				font-weight: 700;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: center-across;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style2 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 11.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: general;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-left-style: none;"
            cMsg += "				border-left-color: inherit;"
            cMsg += "				border-left-width: medium;"
            cMsg += "				border-right-style: none;"
            cMsg += "				border-right-color: inherit;"
            cMsg += "				border-right-width: medium;"
            cMsg += "				border-top: .5pt solid windowtext;"
            cMsg += "				border-bottom-style: none;"
            cMsg += "				border-bottom-color: inherit;"
            cMsg += "				border-bottom-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style3 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: general;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style4 {"
            cMsg += "				color: red;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 700;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: general;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style5 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: right;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style6 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 700;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: center;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style7 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: general;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-left-style: none;"
            cMsg += "				border-left-color: inherit;"
            cMsg += "				border-left-width: medium;"
            cMsg += "				border-right-style: none;"
            cMsg += "				border-right-color: inherit;"
            cMsg += "				border-right-width: medium;"
            cMsg += "				border-top-style: none;"
            cMsg += "				border-top-color: inherit;"
            cMsg += "				border-top-width: medium;"
            cMsg += "				border-bottom: .5pt solid windowtext;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style8 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 9.0pt;"
            cMsg += "				font-weight: 700;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: center;"
            cMsg += "				vertical-align: middle;"
            cMsg += "				white-space: normal;"
            cMsg += "				border-left-style: none;"
            cMsg += "				border-left-color: inherit;"
            cMsg += "				border-left-width: medium;"
            cMsg += "				border-right-style: none;"
            cMsg += "				border-right-color: inherit;"
            cMsg += "				border-right-width: medium;"
            cMsg += "				border-top: .5pt solid windowtext;"
            cMsg += "				border-bottom: .5pt solid windowtext;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style9 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 11.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: center;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += ".style10 {"
            cMsg += "				color: black;"
            cMsg += "				font-size: 11.0pt;"
            cMsg += "				font-weight: 400;"
            cMsg += "				font-style: normal;"
            cMsg += "				text-decoration: none;"
            cMsg += "				font-family: Calibri, sans-serif;"
            cMsg += "				text-align: left;"
            cMsg += "				vertical-align: bottom;"
            cMsg += "				white-space: nowrap;"
            cMsg += "				border-style: none;"
            cMsg += "				border-color: inherit;"
            cMsg += "				border-width: medium;"
            cMsg += "				padding: 0px;"
            cMsg += "}"
            cMsg += "</style>"
            cMsg += "</head>"
            cMsg += "<body>"
            cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='871' style='border-collapse:collapse;width:654pt'>"
            cMsg += "				<colgroup>"
            cMsg += "								<col width='7' style='mso-width-source:userset;mso-width-alt:256;width:5pt' />"
            cMsg += "								<col width='69' style='mso-width-source:userset;mso-width-alt:2523;width:52pt' />"
            cMsg += "								<col width='69' style='mso-width-source:userset;mso-width-alt:2523;width:52pt' />"
            cMsg += "								<col width='69' style='mso-width-source:userset;mso-width-alt:2523;width:52pt' />"
            cMsg += "								<col width='98' style='mso-width-source:userset;mso-width-alt:3584;width:74pt' />"
            cMsg += "								<col width='259' style='mso-width-source:userset;mso-width-alt:9472;width:194pt' />"
            cMsg += "								<col width='155' style='mso-width-source:userset;mso-width-alt:5668;width:116pt' />"
            cMsg += "								<col width='45' style='mso-width-source:userset;mso-width-alt:1645;width:34pt' />"
            cMsg += "								<col width='52' style='mso-width-source:userset;mso-width-alt:1901;width:39pt' />"
            cMsg += "								<col width='48' style='mso-width-source:userset;mso-width-alt:1755;width:36pt' />"
            cMsg += "				</colgroup>"
            cMsg += "				<tr height='20' style='height:15.0pt'>"
            cMsg += "								<td height='20' width='7' style='height:15.0pt;width:5pt' align='left' valign='top'>"
            cMsg += "								<span style='mso-ignore:vglayout; position:absolute;z-index:1;margin-left:3px;margin-top:3px;width:78px height:61px'><img width='78' height='61' src='http://www.adoro.com.br/images/logo-adoro.png' v:shapes='Imagem_x0020_1' /></span><![endif]><span style='mso-ignore:vglayout2'>"
            cMsg += "								<table cellpadding='0' cellspacing='0'>"
            cMsg += "									<tr>"
            cMsg += "										<td height='20' width='7' style='height:15.0pt;width:5pt'></td>"
            cMsg += "									</tr>"
            cMsg += "								</table>"
            cMsg += "								</span></td>"
            cMsg += "								<td width='69' style='width:52pt'></td>"
            cMsg += "								<td width='69' style='width:52pt'></td>"
            cMsg += "								<td width='69' style='width:52pt'></td>"
            cMsg += "								<td width='98' style='width:74pt'></td>"
            cMsg += "								<td width='259' style='width:194pt'></td>"
            cMsg += "								<td width='155' style='width:116pt'></td>"
            cMsg += "								<td width='45' style='width:34pt'></td>"
            cMsg += "								<td width='52' style='width:39pt'></td>"
            cMsg += "								<td width='48' style='width:36pt'></td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='43' style='mso-height-source:userset;height:32.25pt'>"
            cMsg += "					<td height='43' colspan='10' align='center' style='height: 32.25pt; mso-ignore: colspan' class='style1'>RELATÓRIO DE CANHOTOS PENDENTES POR TRANSPORTADOR</td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='25' style='height:18.75pt'>"
            cMsg += "					<td height='25' style='height: 18.75pt' class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "					<td class='style1'></td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='8' style='mso-height-source:userset;height:6.0pt'>"
            cMsg += "					<td height='8' style='height: 6.0pt' class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "					<td class='style2'>&nbsp;</td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='16' style='height:12.0pt'>"
            cMsg += "					<td height='16' style='height: 12.0pt' class='style3'></td>"
            cMsg += "					<td colspan='2' style='mso-ignore: colspan' class='style3'>TRANSPORTADOR :</td>"
            cMsg += "					<td colspan='3' style='mso-ignore: colspan' class='style4'>"+ADCOMP020->C5_TRANSP+"-"+ADCOMP020->A4_NOME+"</td>"
            cMsg += "					<td class='style5'>DATA/HORA :</td>"
            cMsg += "					<td colspan='3' class='style6'>"+DTOC(DATE())+" - "+TIME()+"</td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='8' style='mso-height-source:userset;height:6.0pt'>"
            cMsg += "					<td height='8' style='height: 6.0pt' class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "					<td class='style7'>&nbsp;</td>"
            cMsg += "				</tr>"
            cMsg += "				<tr height='16' style='height:12.0pt'>"
            cMsg += "					<td height='16' width='7' style='height: 12.0pt; width: 5pt' class='style8'>&nbsp;</td>"
            cMsg += "					<td width='69'  style='width: 52pt'  class='style8'>Placa</td>"
            cMsg += "					<td width='69'  style='width: 52pt'  class='style8'>Data Entrega</td>"
            cMsg += "					<td width='69'  style='width: 52pt'  class='style8'>Pedido</td>"
            cMsg += "					<td width='98'  style='width: 74pt'  class='style8'>Nota Fiscal</td>"
            cMsg += "					<td width='259' style='width: 194pt' class='style8'>Cliente</td>"
            cMsg += "					<td width='155' style='width: 116pt' class='style8'>Cidade</td>"
            cMsg += "					<td width='45'  style='width: 34pt'  class='style8'>Estado</td>"
            cMsg += "					<td width='52'  style='width: 39pt'  class='style8'>Roteiro</td>"
            cMsg += "					<td width='48'  style='width: 36pt'  class='style8'>Atraso</td>"
            cMsg += "				</tr>"
            While ADCOMP020->( !EOF())
                if ADCOMP020->F2_TIPO = 'N'
                    dbselectarea("SA1")
                    dbsetorder(1)
                    If dbSeek( FWxFilial("SA1") + ADCOMP020->F2_CLIENTE + ADCOMP020->F2_LOJA )
                        cNomCli := SA1->A1_NOME
                    Else
                        cNomCli := ""
                    EndIf
                Else
                dbselectarea("SA2")
                dbsetorder(1)
                    If dbSeek( FWxFilial("SA2") + ADCOMP020->F2_CLIENTE + ADCOMP020->F2_LOJA )
                        cNomCli := SA2->A2_NOME
                    Else
                        cNomCli := ""
                    EndIf
                EndIf
                cMsg += "				<tr height='20' style='height:15.0pt'>"
                cMsg += "					<td height='20' style='height:15.0pt'></td>"
                cMsg += "					<td class='style9' >"+ADCOMP020->C5_PLACA+"</td>"
                cMsg += "					<td class='style9' >"+DtoC(StoD(ADCOMP020->C5_DTENTR))+"</td>"
                cMsg += "					<td class='style9' >"+ADCOMP020->C5_NUM+"</td>"
                cMsg += "					<td class='style9' >"+ADCOMP020->F2_DOC+"</td>"
                cMsg += "					<td class='style10'>"+cNomCli+"</td>"
                cMsg += "					<td class='style10'>"+ADCOMP020->C5_CIDADE+"</td>"
                cMsg += "					<td class='style9' >"+ADCOMP020->C5_EST+"</td>"
                cMsg += "					<td class='style9' >"+ADCOMP020->C5_ROTEIRO+"</td>"
                cMsg += "					<td class='style9' >"+ Alltrim( Str( Date() - StoD(ADCOMP020->C5_DTENTR) ) ) +"</td>"
                cMsg += "				</tr>"
            nQtdCA++
            dbselectarea("ADCOMP020")
            ADCOMP020->(DbSkip())
            End
            cMsg += "		<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
            cMsg += "						<td height='8' style='height: 6.0pt' class='style3'>"
            cMsg += "						</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "						<td class='style7'>&nbsp;</td>"
            cMsg += "		</tr>"
            cMsg += "		<tr height='8' style='mso-height-source: userset; height: 6.0pt'>"
            cMsg += "						<td height='8' style='height: 6.0pt' class='style3'>"
            cMsg += "						</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>&nbsp;</td>"
            cMsg += "						<td class='style9'>Total:</td>"
            cMsg += "						<td class='style9'>"+Alltrim(Str(nQtdCA))+"</td>"
            cMsg += "		</tr>"
            cMsg += "</table>"
            cMsg += "</body>"
            cMsg += "</html>"
            nQtdCA := 0
        EndIf

        IF !EMPTY(cDestWFgas) 
            IF !Empty(sEmailTrp) .and. Alltrim(sNAmbiente) == Alltrim(nServerPRD)
                //sEmailCpl := Alltrim(cDestWFgas) + ';' + Alltrim(cCopDeswf) + ';' + Alltrim(sEmailTrp)
                sEmailCpl := Alltrim(cDestWFgas) + ';' + Alltrim(sEmailTrp)  //Chamado de TI: 24/04/2019 - Fernando Sigoli
            
			Else
                //sEmailCpl := Alltrim(cDestWFgas) + ';' + Alltrim(cCopDeswf)
                sEmailCpl := Alltrim(cDestWFgas) //Chamado de TI: 24/04/2019 - Fernando Sigoli
            
			EndIf
            ConOut('Destino: ' + sEmailCpl )
		    //u_F050EnvWF( cAssunto , cMsg , sEmailCpl , cCopDeswf )
            U_F50En2WF(sEmailCpl , cCopDeswf , cAssunto , cMsg , '' )
	    ENDIF

    dbselectarea("ADCOMT020")
    ADCOMT020->(DbSkip())
    End

Return
/*/{Protheus.doc} ADCO020E
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020E()

    //Variáveis.
    Local cMsg   := ""
    Local cQuery := ""
    Local cAssunto := "Resumo de Canhotos Pendentes"
    Local nQtdAtu  := 0
    Local nQtdAnt  := 0
    Local cTransp := ""
    Local dDataIni  := DtoS(date()- SuperGetMv( "MV_#ADC20I" , .F. , 365 , ) )  //26/07/18 | Ricardo Lima
    Local dDataAtui := ALLTRIM(STR(YEAR(Date()))) + StrZero( MONTH(DATE()) , 2 ) +'01'
    Local dDataAtuf := ALLTRIM(STR(YEAR(Date()))) + StrZero( MONTH(DATE()) , 2 ) +'31'
    Local dDataFim  := ALLTRIM(STR(YEAR(Date()))) + StrZero( MONTH(DATE())-1 , 2 ) +'31'

    cQuery := " SELECT *, ("
    cQuery += " SELECT COUNT(*)"
    cQuery += " FROM "+ RetSqlName("SF2") +" F2"
    cQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 ON F2_FILIAL=C5_FILIAL AND F2_DOC=C5_NOTA AND C5.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+ RetSqlName("SA2") +" A2 ON A2_COD=C5_TRANSP"
    cQuery += " WHERE F2_FILIAL in ('02','07') AND F2_EMISSAO BETWEEN '"+dDataAtui+"' AND '"+dDataAtuf+"' AND F2.D_E_L_E_T_ = ' '"
    cQuery += " AND C5_CANHOTO=''"
    cQuery += " AND C5_TRANSP = FONTE.C5_TRANSP AND C5_PLACA = FONTE.C5_PLACA"
    cQuery += " GROUP BY C5_TRANSP, C5_PLACA"
    cQuery += " ) MES_ATUAL"
    cQuery += " FROM ("
    cQuery += " SELECT C5_TRANSP, A2_NOME, C5_PLACA, COUNT(*) MES_ANTERIOR"
    cQuery += " FROM "+ RetSqlName("SF2") +" F2"
    cQuery += " INNER JOIN "+ RetSqlName("SC5") +" C5 ON F2_FILIAL=C5_FILIAL AND F2_DOC=C5_NOTA AND C5.D_E_L_E_T_ = ' '"
    cQuery += " INNER JOIN "+ RetSqlName("SA2") +" A2 ON A2_COD=C5_TRANSP"
    cQuery += " WHERE F2_FILIAL in ('02','07') AND F2_EMISSAO BETWEEN '"+dDataIni+"' AND '"+dDataFim+"' AND F2.D_E_L_E_T_ = ' '"
    cQuery += " AND C5_CANHOTO='' AND C5_TPFRETE = 'C' AND F2_SERIE <> 'ZZ' AND C5_EST <> 'EX' AND C5_TRANSP <> ' ' AND C5_PLACA <> ' '"
    cQuery += " GROUP BY C5_TRANSP, A2_NOME, C5_PLACA"
    cQuery += " ) AS FONTE"
    cQuery += " ORDER BY FONTE.C5_TRANSP "
    
    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"

    If ADCOMT020->( !EOF() ) 

        cMsg := "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
        cMsg += "<html xmlns='http://www.w3.org/1999/xhtml' xmlns:v='urn:schemas-microsoft-com:vml' xmlns:o='urn:schemas-microsoft-com:office:office'>"
        cMsg += "<head>"
        cMsg += "<meta http-equiv='Content-Type' content='text/html; charset=utf-8' />"
        cMsg += "<title>Bitmap</title>"
        cMsg += "<style type='text/css'>"
        cMsg += "	{border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "				color:black;"
        cMsg += "					font-size:11.0pt;"
        cMsg += "					font-weight:400;"
        cMsg += "					font-style:normal;"
        cMsg += "					text-decoration:none;"
        cMsg += "					font-family:Calibri, sans-serif;"
        cMsg += "					text-align:general;"
        cMsg += "					vertical-align:bottom;"
        cMsg += "					white-space:nowrap;"
        cMsg += "	}"
        cMsg += ".style1 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style3 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 14.0pt;"
        cMsg += "				font-weight: 700;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center-across;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style5 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: general;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style6 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border: .5pt solid windowtext;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style7 {"
        cMsg += "				color: white;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 700;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border: .5pt solid windowtext;"
        cMsg += "				padding: 0px;"
        cMsg += "				background: #404040;"
        cMsg += "}"
        cMsg += ".style9 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style10 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 8.0pt;"
        cMsg += "				font-weight: 700;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: middle;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border: .5pt solid windowtext;"
        cMsg += "				padding: 0px;"
        cMsg += "}"
        cMsg += ".style11 {"
        cMsg += "				text-align: right;"
        cMsg += "}"
        cMsg += ".style12 {"
        cMsg += "				background-color: #CCCCCC;"
        cMsg += "}"
        cMsg += ".style13 {"
        cMsg += "				color: black;"
        cMsg += "				font-size: 11.0pt;"
        cMsg += "				font-weight: 400;"
        cMsg += "				font-style: normal;"
        cMsg += "				text-decoration: none;"
        cMsg += "				font-family: Calibri, sans-serif;"
        cMsg += "				text-align: center;"
        cMsg += "				vertical-align: bottom;"
        cMsg += "				white-space: nowrap;"
        cMsg += "				border-style: none;"
        cMsg += "				border-color: inherit;"
        cMsg += "				border-width: medium;"
        cMsg += "				padding: 0px;"
        cMsg += "				background-color: #CCCCCC;"
        cMsg += "}"
        cMsg += "</style>"
        cMsg += "</head>"
        cMsg += "<body>"
        cMsg += "<table border='0' cellpadding='0' cellspacing='0' style='border-collapse: collapse; width: 644pt'>"
        cMsg += "				<colgroup>"
        cMsg += "								<col width='7' style='mso-width-source: userset; mso-width-alt: 256; width: 5pt' />"
        cMsg += "								<col width='305' style='mso-width-source: userset; mso-width-alt: 11154; width: 229pt' />"
        cMsg += "								<col width='81' style='mso-width-source: userset; mso-width-alt: 2962; width: 61pt' />"
        cMsg += "								<col width='87' span='2' style='mso-width-source: userset; mso-width-alt: 3181; width: 65pt' />"
        cMsg += "								<col width='87' style='mso-width-source: userset; mso-width-alt: 3181; width: 65pt' />"
        cMsg += "								<col width='64' style='width: 48pt' />"
        cMsg += "				</colgroup>"
        cMsg += "				<tr height='20' style='height: 15.0pt'>"
        cMsg += "								<td height='20' width='7' style='height: 15.0pt; width: 5pt' align='left' valign='top'>"
        cMsg += "								<span style='mso-ignore: vglayout; position: absolute; z-index: 1; margin-left: 3px; margin-top: 3px; width: 78px; height: 61px'>"
        cMsg += "								<img width='78' height='61' src='http://www.adoro.com.br/images/logo-adoro.png' v:shapes='Imagem_x0020_1' /></span><![endif]><span style='mso-ignore: vglayout2'>"
        cMsg += "								<table cellpadding='0' cellspacing='0'>"
        cMsg += "												<tr>"
        cMsg += "																<td height='20' width='7' style='height: 15.0pt; width: 5pt'>"
        cMsg += "																</td>"
        cMsg += "												</tr>"
        cMsg += "								</table>"
        cMsg += "								</span></td>"
        cMsg += "								<td width='305' style='width: 229pt'></td>"
        cMsg += "								<td width='81' style='width: 61pt' class='style1'></td>"
        cMsg += "								<td width='87' style='width: 65pt'></td>"
        cMsg += "								<td width='87' style='width: 65pt'></td>"
        cMsg += "								<td width='87' style='width: 65pt' class='style1'></td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='43' style='mso-height-source: userset; height: 32.25pt'>"
        cMsg += "								<td height='43' colspan='7' align='center' style='height: 32.25pt; mso-ignore: colspan' class='style3'>"
        cMsg += "								RESUMO CANHOTOS PENDENTES</td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='25' style='height: 18.75pt'>"
        cMsg += "								<td height='25' colspan='7' align='center' style='height: 18.75pt; mso-ignore: colspan' class='style3'>"
        cMsg += "								POR TRANSPORTADOR</td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='5' style='mso-height-source: userset; height: 3.75pt'>"
        cMsg += "								<td height='5' style='height: 3.75pt'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style1'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style1'></td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='20' style='height: 15.0pt'>"
        cMsg += "								<td height='20' style='height: 15.0pt'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style1'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style11'>"+DtoC(Date())+"</td>"
        cMsg += "								<td class='style11'>"+Time()+"</td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='5' style='mso-height-source: userset; height: 3.75pt'>"
        cMsg += "								<td height='5' style='height: 3.75pt'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style1'></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td></td>"
        cMsg += "								<td class='style1'></td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='20' style='height: 15.0pt'>"
        cMsg += "								<td height='20' style='height: 15.0pt' class='style5'></td>"
        cMsg += "								<td rowspan='2' class='style6'>TRANSPORTADOR</td>"
        cMsg += "								<td rowspan='2' class='style6'>PLACA</td>"
        cMsg += "								<td colspan='3' class='style7'>QUANTIDADE</td>"
        cMsg += "				</tr>"
        cMsg += "				<tr height='20' style='height: 15.0pt'>"
        cMsg += "								<td height='20' style='height: 15.0pt' class='style9'></td>"
        cMsg += "								<td class='style10'>MESES ANT</td>"
        cMsg += "								<td class='style10'>MÊS ATUAL</td>"
        cMsg += "								<td class='style10'>TT PENDENTE</td>"
        cMsg += "				</tr>"
        cTransp := ADCOMT020->C5_TRANSP
        While ADCOMT020->( !EOF() )
            
            If cTransp <> ADCOMT020->C5_TRANSP

                cMsg += "<tr height='5' style='mso-height-source: userset; height: 3.75pt'>"
				cMsg += "				<td height='5' style='height: 3.75pt'></td>"
				cMsg += "				<td></td>"
				cMsg += "				<td class='style13'>TOTAL</td>"
				cMsg += "				<td class='style12'>"+Alltrim(Str(nQtdAtu))+"</td>"
				cMsg += "				<td class='style12'>"+Alltrim(Str(nQtdAnt))+"</td>"
				cMsg += "				<td class='style12'>"+Alltrim(Str( (nQtdAtu+nQtdAnt) ))+"</td>"
				cMsg += "</tr>"
             
             nQtdAtu := 0
             nQtdAnt := 0
            EndIf
            
            cMsg += "       <tr height='5' style='mso-height-source: userset; height: 3.75pt'>
            cMsg += "			<td height='5' style='height: 3.75pt'></td>
            cMsg += "			<td>"+ADCOMT020->C5_TRANSP+"-"+ADCOMT020->A2_NOME+"</td>
            cMsg += "			<td>"+ADCOMT020->C5_PLACA+"</td>
            cMsg += "			<td>"+Alltrim(Str(ADCOMT020->MES_ANTERIOR))+"</td>
            cMsg += "			<td>"+Alltrim(Str(ADCOMT020->MES_ATUAL))+"</td>
            cMsg += "			<td>"+Alltrim(Str( (ADCOMT020->MES_ANTERIOR+ADCOMT020->MES_ATUAL) ))+"</td>
            cMsg += "       </tr>
            nQtdAtu += ADCOMT020->MES_ANTERIOR
            nQtdAnt += ADCOMT020->MES_ATUAL
            cTransp := ADCOMT020->C5_TRANSP
        ADCOMT020->(DbSkip())
        End
        cMsg += "</table>"
        cMsg += "</body>"
        cMsg += "</html>"

    EndIf

    IF !EMPTY(cDestWFgas) 
		//u_F050EnvWF( cAssunto , cMsg , cDestWFgas , cCopDeswf )
        U_F50En2WF(cDestWFgas , cCopDeswf , cAssunto , cMsg , '' )
	ENDIF

Return 
/*/{Protheus.doc} User Function ADCOAGLI
    Gera relatório Aging List. 
    @type  Function
    @author Everson 
    @since 28/06/2018
    @version 01
    /*/ 
User Function ADCOAGLI() // U_ADCOAGLI()

    //Variáveis.
	Local cAssunto 	:= "Relatório - Aging List"
	Local cMsg	   	:= "Segue relatório Aging List anexo."
	Local cHtml    	:= ""
	Local cArq	   	:= "\rel_fin\aginlist.html"
	Local cJquery  	:= "\rel_fin\jquery\jquery.txt.txt"
    Local cHoraini	:= Time()
    Local aEmp      := {{"01","Adoro"},{"02","Ceres"},{"07","RNX2"},{"09","Safeegg"}} //Everson - 29/07/2020. Chamado 058854.
	
	Private nVlr0330PD := nVlr0330IC := nVlr3160PD := nVlr3160IC := nVlr6190PD := nVlr6190IC := nVlrM90PD := nVlrM90IC := nTotGICPD := 0
	Private nVlr0330ES := nVlr0330CA := nVlr0330EX := nVlr0330AS := nVlr3160ES := nVlr3160CA := nVlr3160EX := nVlr3160AS := nVlr6190ES := nVlr6190CA := nVlr6190EX := nVlr6190AS := nTotGIC := 0

    U_ADINF009P('ADCOM020P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	//
	Conout( "ADCOM020P - Início ADCOAGLI " + DToc(Date()) + " " + cHoraini )
	
	//
	cHtml := ""
	cHtml += " <!DOCTYPE html> " 
	cHtml += " <html> " 
	cHtml += " <head> " 
	cHtml += ' <meta http-equiv="Content-Type" content="text/html; charset=utf-8"> '
	cHtml += " <style> " 
	cHtml += " body{font-family:Calibri, Tahoma, Arial} " 
	cHtml += " .TabControl{ width:100%; height:100%} " 
	cHtml += " .TabControl #header{ width:100%; border: 0; overflow:hidden; cursor:hand} " 
	cHtml += " .TabControl #content{ width:100%; border: solid 1px 1px 0 1px;overflow:hidden; height:100%; } " 
	cHtml += " .TabControl .abas{display:inline;} " 
	cHtml += " .TabControl .abas li{float:left} " 
	cHtml += " .aba{width:300px; height:30px; border:solid 1px; border-radius:0 10px 0 0; text-align:center;padding-top:5px;background:#ffffff; color:#000000; font-weight: bold;} " 
	cHtml += " .ativa{width:100px; height:30px; border:solid 1 px; border-radius:0 10px 0 0; text-align:center;padding-top:5px; background:#636161;} " 
	cHtml += " .ativa span, .selected span{color:#ffffff} " 
	cHtml += " .TabControl #content{background:#636161} " 
	cHtml += " .TabControl .conteudo{width:100%;  background:#ffffff; display:none; height:100%;color:black;overflow:scroll;} " 
	cHtml += " .selected{width:300px; height:30px; border:solid 1 px; border-radius:0 10px 0 0;text-align:center; padding-top:5px; background:#636161} "
	cHtml += " .tabelaTab1{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 80%; " 
	cHtml += " height: 95% " 
	cHtml += " } " 
	cHtml += " .tabelaTab2{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 80%; " 
	cHtml += " height: 95% " 
	cHtml += " } " 
	cHtml += " .tabelaTab3{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 85%; " 
	cHtml += " height: 95% " 
	cHtml += " } "
	cHtml += " .tabelaTab4{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 80%; " 
	cHtml += " height: 95% " 
	cHtml += " } " 
	cHtml += " .tabelaTab5{ " 
	cHtml += " margin: 0 auto; " 
	cHtml += " margin-top: 10px; " 
	cHtml += " width: 85%; " 
	cHtml += " height: 95% " 
	cHtml += " } "
	cHtml += "{border-style: none;
    cHtml += "				border-color: inherit;
    cHtml += "				border-width: medium;
    cHtml += "				padding-top:1px;
    cHtml += "					padding-right:1px;
    cHtml += "					padding-left:1px;
    cHtml += "					color:black;
    cHtml += "					font-size:11.0pt;
    cHtml += "					font-weight:400;
    cHtml += "					font-style:normal;
    cHtml += "					text-decoration:none;
    cHtml += "					font-family:Calibri, sans-serif;
    cHtml += "					text-align:general;
    cHtml += "					vertical-align:bottom;
    cHtml += "					white-space:nowrap;
    cHtml += "	}
    cHtml += ".style1 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: middle;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #D9D9D9;
    cHtml += "}
    cHtml += ".style2 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-left: .5pt solid windowtext;
    cHtml += "				border-right: .5pt solid windowtext;
    cHtml += "				border-top-style: none;
    cHtml += "				border-top-color: inherit;
    cHtml += "				border-top-width: medium;
    cHtml += "				border-bottom-style: none;
    cHtml += "				border-bottom-color: inherit;
    cHtml += "				border-bottom-width: medium;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style3 {
    cHtml += "				color: black;
    cHtml += "				font-size: 12.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: middle;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #FABF8F;
    cHtml += "}
    cHtml += ".style4 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: middle;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style5 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-left-style: none;
    cHtml += "				border-left-color: inherit;
    cHtml += "				border-left-width: medium;
    cHtml += "				border-right-style: none;
    cHtml += "				border-right-color: inherit;
    cHtml += "				border-right-width: medium;
    cHtml += "				border-top: .5pt solid windowtext;
    cHtml += "				border-bottom: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style6 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-left-style: none;
    cHtml += "				border-left-color: inherit;
    cHtml += "				border-left-width: medium;
    cHtml += "				border-right-style: none;
    cHtml += "				border-right-color: inherit;
    cHtml += "				border-right-width: medium;
    cHtml += "				border-top: .5pt solid windowtext;
    cHtml += "				border-bottom: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style7 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: left;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 36px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style8 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style9 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style10 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: left;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 36px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #D9D9D9;
    cHtml += "}
    cHtml += ".style11 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-left: .5pt solid windowtext;
    cHtml += "				border-right: .5pt solid windowtext;
    cHtml += "				border-top-style: none;
    cHtml += "				border-top-color: inherit;
    cHtml += "				border-top-width: medium;
    cHtml += "				border-bottom-style: none;
    cHtml += "				border-bottom-color: inherit;
    cHtml += "				border-bottom-width: medium;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style12 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #D9D9D9;
    cHtml += "}
    cHtml += ".style13 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: left;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-style: none;
    cHtml += "				border-color: inherit;
    cHtml += "				border-width: medium;
    cHtml += "				padding-left: 36px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style14 {
    cHtml += "				color: white;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: left;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 36px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: gray;
    cHtml += "}
    cHtml += ".style15 {
    cHtml += "				color: white;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: general;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: gray;
    cHtml += "}
    cHtml += ".style16 {
    cHtml += "				color: black;
    cHtml += "				font-size: 12.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border-left: .5pt solid windowtext;
    cHtml += "				border-right-style: none;
    cHtml += "				border-right-color: inherit;
    cHtml += "				border-right-width: medium;
    cHtml += "				border-top: .5pt solid windowtext;
    cHtml += "				border-bottom: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #FABF8F;
    cHtml += "}
    cHtml += ".style17 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 700;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: middle;
    cHtml += "				white-space: normal;
    cHtml += "				border-left: .5pt solid windowtext;
    cHtml += "				border-right: .5pt solid windowtext;
    cHtml += "				border-top: .5pt solid windowtext;
    cHtml += "				border-bottom-style: none;
    cHtml += "				border-bottom-color: inherit;
    cHtml += "				border-bottom-width: medium;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "				background: #D9D9D9;
    cHtml += "}
    cHtml += ".style18 {
    cHtml += "				color: black;
    cHtml += "				font-size: 8.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: center;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
    cHtml += ".style19 {
    cHtml += "				color: black;
    cHtml += "				font-size: 11.0pt;
    cHtml += "				font-weight: 400;
    cHtml += "				font-style: normal;
    cHtml += "				text-decoration: none;
    cHtml += "				font-family: Calibri, sans-serif;
    cHtml += "				text-align: left;
    cHtml += "				vertical-align: bottom;
    cHtml += "				white-space: nowrap;
    cHtml += "				border: .5pt solid windowtext;
    cHtml += "				padding-left: 1px;
    cHtml += "				padding-right: 1px;
    cHtml += "				padding-top: 1px;
    cHtml += "}
	cHtml += " </style> " 
	
	//Adiciona JQuery ao arquivo.
	If ! File(cJquery)
		cHtml += ' <script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script> ' 
	
	Else
		
		//
		nHdl := FT_FUse(cJquery)
		
		//Valida abertura do arquivo.
		If nHdl == -1
			cHtml += ' <script type="text/javascript" src="http://code.jquery.com/jquery-1.7.2.min.js"></script> ' 
		
		Else
		
			//
			FT_FGoTop()
			
			cHtml += "<script type='text/javascript'>" 
	
			//Percorre arquivo.
			While !FT_FEof()
				
				cHtml += FT_FReadln()
				
				FT_FSkip()
				
			EndDo
			
			cHtml += " </script> "
			
		Endif
			
	Endif
	
	cHtml += " </head> " 
	cHtml += " <body> " 
	cHtml += " <h2 style='color:#28377c;margin:0px;'>Aging List</h2> "
    cHtml += " <p>ADCOM020P</p> "
	cHtml += " <hr> "  
	cHtml += " <p>Emitido em: " + DToC(Date()) + " - " + cValToChar(Time()) + "</p> "  
	cHtml += ' <div class="TabControl"> ' 
	cHtml += ' <div id="header"> ' 
	cHtml += ' <ul class="abas"> ' 
	
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Aging List - Geral</span> "  
	cHtml += " </div> " 
	cHtml += " </li> " 

	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Inadimplência Corrente</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 

	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Provisão Perdas e Perdas Efetivas</span> " 
	cHtml += " </div> " 
	cHtml += " </li> " 
			
	cHtml += " <li> " 
	cHtml += ' <div class="aba"> ' 
	cHtml += " <span>Aging List - Inadimplência Interna</span> "
	cHtml += " </div> " 
	cHtml += " </li> " 
	
	cHtml += " </ul> " 
	cHtml += " </div> " 
	
	cHtml += ' <div id="content"> ' 
	
	cHtml += ' <div class="conteudo"> ' 
	cHtml += ADCO020F(aEmp) // Aging List Geral. //Everson - 29/07/2020. Chamado 058854.
	cHtml += " </div> " 
	
	cHtml += ' <div class="conteudo"> ' 
	cHtml += ADCO020H(aEmp) // Aging List - Inadimplencia Corrente. //Everson - 29/07/2020. Chamado 058854.
	cHtml += " </div> "
	
	cHtml += ' <div class="conteudo"> ' 
	cHtml += ADCO020I(aEmp) // Aging List - Provisão Perdas e Perdas Efetivas. //Everson - 29/07/2020. Chamado 058854.
	cHtml += " </div> "
	
	cHtml += ' <div class="conteudo"> ' 
	cHtml += ADCO020G(aEmp) // Aging List - Inadimplencia Interna. //Everson - 29/07/2020. Chamado 058854.
	cHtml += " </div> "
	
	cHtml += " </div> " 
	cHtml += ' <script type="text/javascript"> '
	cHtml += ' $(document).ready(function(){ '
	cHtml += ' $("#content div:nth-child(1)").show(); '
	cHtml += ' $(".abas li:first div").addClass("selected"); '		
	cHtml += ' $(".aba").click(function(){ '
	cHtml += ' $(".aba").removeClass("selected"); '
	cHtml += ' $(this).addClass("selected"); '
	cHtml += ' var indice = $(this).parent().index(); '
	cHtml += ' indice++; '
	cHtml += ' $("#content div").hide(); '
	cHtml += ' $("#content div:nth-child("+indice+")").show(); '
	cHtml += ' }); '				
	cHtml += ' }); '
	cHtml += " </script> " 
	cHtml += " </body> " 
	cHtml += " </html> " 
	cHtml := EncodeUTF8(cHtml)
	
	//
	memowrite(cArq,cHtml)
	
	//cDestWFgas := "alberto@adoro.com.br"
	//cDestWFgas  := "everson.silva@adoro.com.br"
	//cCopDeswf   := "everson.silva@adoro.com.br"
	
	//
	If !Empty(cDestWFgas) 
		envEmail(cAssunto,cMsg,cDestWFgas,cCopDeswf,cArq)
		
	EndIf
	
	//
	Conout( "ADCOM020P - Início ADCOAGLI " + DToc(Date()) + " " + Time() + " tempo decorrido: " + ElapTime ( cHoraini , Time() ) )
	
	//
	FErase(cArq)

Return Nil
/*/{Protheus.doc} ADCO020F
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020F(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cMsg     := ""
	Local cQuery   := ""
	Local cAssunto := "Aging List - Geral"
	Local nQtdAtu  := 0
	Local nQtdAnt  := 0
	Local cTransp  := ""
	
	// Maior 90
	Local nVlrM90ES := 0
	Local nVlrM90CA := 0
	Local nVlrM90EX := 0
	Local nVlrM90AS := 0
	
	// A VENCER
	Local nVlrVENES := 0
	Local nVlrVENCA := 0
	Local nVlrVENEX := 0
	Local nVlrVENAS := 0
	Local nVlrVENPD := 0
	Local nVlrVENIC := 0
	
	// RECEBIDO EXPORT
	Local nVlrRECEX := 0
	Local nTTvec    := 0
	Local nVlrTG    := 0
	Local nTTcrTop  := 0
	Local nPersTT   := 0
	Local nPerAcm   := 0
	Local nItemCRT  := 1
	
	//
 	cQuery := scriptAgGrl(aEmp) //Everson - 29/07/2020. Chamado 058854.
 	cQuery += " ORDER BY FONTE.TPCOBR,FONTE.FAIXA "
 	If Select("D_AGGER") > 0
 		D_AGGER->(DbCloseArea())
 		
 	EndIf

 	//
 	TcQuery cQuery New Alias "D_AGGER"
 	DbSelectArea("D_AGGER")
 	D_AGGER->(DbGoTop())
 	While ! D_AGGER->(Eof())
 	
 		Do Case
 			
 			//Escritural.
 			Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30A_ESCRITURAL"
		    nVlr0330ES := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60A_ESCRITURAL"
		    nVlr3160ES := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90A_ESCRITURAL"
		    nVlr6190ES := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90A_ESCRITURAL"
		    nVlrM90ES  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERA_ESCRITURAL"
		    nVlrVENES  := D_AGGER->SLDTIT
		    
		    //Carteira.
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30B_CARTEIRA"
		    nVlr0330CA := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60B_CARTEIRA"
		    nVlr3160CA := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90B_CARTEIRA"
		    nVlr6190CA := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90B_CARTEIRA"
		    nVlrM90CA  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERB_CARTEIRA"
		    nVlrVENCA  := D_AGGER->SLDTIT
		    
		    //Exportação.
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30C_EXPORTAÇÃO"
		    nVlr0330EX := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60C_EXPORTAÇÃO"
		    nVlr3160EX := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90C_EXPORTAÇÃO"
		    nVlr6190EX := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90C_EXPORTAÇÃO"
		    nVlrM90EX  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERC_EXPORTAÇÃO"
		    nVlrVENEX  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "G_RECEXPG_RECEXP"
		    nVlrRECEX := D_AGGER->SLDTIT
		    
		    //Assessoria.
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30D_ASSESSORIA"
		    nVlr0330AS := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60D_ASSESSORIA"
		    nVlr3160AS := D_AGGER->SLDTIT 
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90D_ASSESSORIA"
		    nVlr6190AS := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90D_ASSESSORIA"
		    nVlrM90AS  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERD_ASSESSORIA"
		    nVlrVENAS  := D_AGGER->SLDTIT
		    
		    //Pendência.
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30E_PENDENCIA"
		    nVlr0330PD := D_AGGER->SLDTIT 
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60E_PENDENCIA" 
		    nVlr3160PD := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90E_PENDENCIA"
		    nVlr6190PD := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90E_PENDENCIA"
		    nVlrM90PD  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERE_PENDENCIA"
		    nVlrVENPD  := D_AGGER->SLDTIT
		    
		    //Inter-cia.
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "A_3_30F_INTER-CIA"
		    nVlr0330IC := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "B_31_60F_INTER-CIA"
		    nVlr3160IC := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "C_61_90F_INTER-CIA"
		    nVlr6190IC := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "D_M_90F_INTER-CIA"
		    nVlrM90IC  := D_AGGER->SLDTIT
		    
		    Case Alltrim(cValToChar(D_AGGER->TIPO)) == "E_A_VENCERF_INTER-CIA"
		    nVlrVENIC  := D_AGGER->SLDTIT
    	
    	EndCase
    	
    	//
    	D_AGGER->(DbSkip())
    	
    End   
    
    //
    cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='806' style='border-collapse: collapse;width:603pt' class='tabelaTab1'>
    cMsg += "				<colgroup>
    cMsg += "								<col width='38' style='mso-width-source:userset;mso-width-alt:1389;width:29pt' />
    cMsg += "								<col width='155' style='mso-width-source:userset;mso-width-alt:5668;width:116pt' />
    cMsg += "								<col width='4' style='mso-width-source:userset;mso-width-alt:146;width:3pt' />
    cMsg += "								<col width='87' span='7' style='mso-width-source:userset;mso-width-alt:3181 width:65pt' />
    cMsg += "				</colgroup>
    cMsg += "				<tr height='21' style='height:15.75pt'>
    cMsg += "								<td colspan='2' rowspan='2' height='41' width='193' style='height: 30.75pt; width: 145pt' class='style1'>
    cMsg += "								FAIXAS</td>
    cMsg += "								<td width='4' style='width: 3pt' class='style2'>
    cMsg += "								&nbsp;</td>
    cMsg += "								<td colspan='6' width='522' style='width: 390pt' class='style3'>
    cMsg += "								AGING LIST - GERAL</td>
    cMsg += "								<td rowspan='2' width='87' style='width: 65pt' class='style1'>
    cMsg += "								TOTAL</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td height='20' style='height: 15.0pt;' class='style2'>
    cMsg += "								&nbsp;</td>
    cMsg += "								<td class='style4'>ESCRITURAL</td>
    cMsg += "								<td class='style4'>CARTEIRA</td>
    cMsg += "								<td class='style4'>EXPORTAÇÃO</td>
    cMsg += "								<td class='style4'>ASSESSORIA</td>
    cMsg += "								<td class='style4'>PENDÊNCIA</td>
    cMsg += "								<td class='style4'>INTER-CIA</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='6' style='mso-height-source:userset;height:4.5pt'>
    cMsg += "								<td class='style5' height='6' style='height:4.5pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style6'>&nbsp;</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>DE 03 À 30</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr0330IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9'>"+Transform( (nVlr0330ES + nVlr0330CA + nVlr0330EX + nVlr0330AS + nVlr0330PD + nVlr0330IC) , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    nTTvec += (nVlr0330ES + nVlr0330CA + nVlr0330EX + nVlr0330AS + nVlr0330PD + nVlr0330IC)
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>
    cMsg += "								DE 31 À 60</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlr3160IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9'>"+Transform( (nVlr3160ES + nVlr3160CA + nVlr3160EX + nVlr3160AS + nVlr3160PD + nVlr3160IC) , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    nTTvec += (nVlr3160ES + nVlr3160CA + nVlr3160EX + nVlr3160AS + nVlr3160PD + nVlr3160IC)
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>DE 61 À 90</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlr6190IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9'>"+Transform( (nVlr6190ES + nVlr6190CA + nVlr6190EX + nVlr6190AS + nVlr6190PD + nVlr6190IC) , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    nTTvec += (nVlr6190ES + nVlr6190CA + nVlr6190EX + nVlr6190AS + nVlr6190PD + nVlr6190IC)
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>MAIOR 90</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9'>"+Transform( (nVlrM90ES + nVlrM90CA + nVlrM90EX + nVlrM90AS + nVlrM90PD + nVlrM90IC) , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    nTTvec += (nVlrM90ES + nVlrM90CA + nVlrM90EX + nVlrM90AS + nVlrM90PD + nVlrM90IC)
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style10'>VENCIDOS</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlrM90ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlrM90CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlrM90EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330AS+nVlr3160AS+nVlr6190AS+nVlrM90AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nTTvec , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='14' style='mso-height-source:userset;height:10.5pt'>
    cMsg += "								<td height='14' style='height: 10.5pt' class='style13'>
    cMsg += "								</td>
    cMsg += "								<td class='style13'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>À VENCER</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENCA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENEX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENAS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENPD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style8'>"+Transform( nVlrVENIC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9'>"+Transform( nVlrVENES + nVlrVENCA + nVlrVENEX + nVlrVENAS + nVlrVENPD + nVlrVENIC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>VLR RECEB</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td class='style8'>&nbsp;</td>
    cMsg += "								<td class='style8'>&nbsp;</td>
    cMsg += "								<td align='right' class='style8'>"+Transform(nVlrRECEX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td class='style8'>&nbsp;</td>
    cMsg += "								<td class='style8'>&nbsp;</td>
    cMsg += "								<td class='style8'>&nbsp;</td>
    cMsg += "								<td align='right' class='style9'>"+Transform(nVlrRECEX , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style10'>VENCER+RECEBIDOS</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENCA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENEX+nVlrRECEX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENAS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENPD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENIC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlrVENES + nVlrVENCA + nVlrRECEX + nVlrVENEX + nVlrVENAS + nVlrVENPD + nVlrVENIC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='5' style='mso-height-source:userset;height:3.75pt'>
    cMsg += "								<td height='5' style='height: 3.75pt' class='style13'>
    cMsg += "								</td>
    cMsg += "								<td class='style13'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    
    // Acumulador Geral
    nVlrTG += nVlrVENES+nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlrM90ES
    nVlrTG += nVlrVENCA+nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlrM90CA
    nVlrTG += nVlrVENEX+nVlrRECEX+nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlrM90EX
    nVlrTG += nVlrVENAS+nVlr0330AS+nVlr3160AS+nVlr6190AS+nVlrM90AS
    nVlrTG += nVlrVENPD+nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD
    nVlrTG += nVlrVENIC+nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC 
    
    //
    nTotGICPD := (nVlrVENPD+nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD) + (nVlrVENIC+nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC)    
    nTotGIC   := (nVlrVENES+nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlrM90ES) + (nVlrVENCA+nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlrM90CA) + (nVlrVENEX+nVlrRECEX+nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlrM90EX) + (nVlrVENAS+nVlr0330AS+nVlr3160AS+nVlr6190AS+nVlrM90AS)
    
    //
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style10'>TOTAL GERAL</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENES+nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlrM90ES , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENCA+nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlrM90CA , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENEX+nVlrRECEX+nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlrM90EX , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENAS+nVlr0330AS+nVlr3160AS+nVlr6190AS+nVlrM90AS , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENPD+nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrVENIC+nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform(nVlrTG,"@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='5' style='mso-height-source:userset;height:3.75pt'>
    cMsg += "								<td height='5' style='height: 3.75pt' class='style13'>
    cMsg += "								</td>
    cMsg += "								<td class='style13'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style14'>% TOTAL</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENES+nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlrM90ES)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENCA+nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlrM90CA)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENEX+nVlrRECEX+nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlrM90EX)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENAS+nVlr0330AS+nVlr3160AS+nVlr6190AS+nVlrM90AS)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENPD+nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform(Round( (((nVlrVENIC+nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC)/nVlrTG)*100) ,2) , "@E 999.99" )+"%</td>
    cMsg += "								<td align='right' class='style15'>"+Transform( (((nVlrTG)/nVlrTG)*100) , "@E 999.99" )+"%</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td height='20' style='height:15.0pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td height='20' style='height:15.0pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='21' style='height:15.75pt'>
    cMsg += "								<td colspan='9' height='21' style='height: 15.75pt' class='style3'>CONCENTRAÇÃO DE RISCO - TOP 20</td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td rowspan='2' height='40' style='height: 30.0pt;' class='style1'>ITEM</td>
    cMsg += "								<td rowspan='2' height='40' style='height: 30.0pt;' class='style1'>EMPRESA</td>" //Everson - 28/07/2020. Chamado 
    cMsg += "								<td colspan='3' rowspan='2' class='style1'>CLIENTE</td>
    cMsg += "								<td rowspan='2' class='style1'>REDE</td>
    cMsg += "								<td rowspan='2' width='87' style='width: 65pt' class='style17'>SALDO À RECEBER</td>
    cMsg += "								<td class='style1'>%</td>
    cMsg += "								<td class='style1'>%</td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td height='20' style='height: 15.0pt;' class='style1'>S/ TT</td>
    cMsg += "								<td class='style1'>ACUM</td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    
    //
    cQuery := ""
    cQuery += " SELECT "
	cQuery += " ROUND(SUM(FONTE.SLDTIT),2) AS SLDTIT "
	cQuery += " FROM " 
	cQuery += " ( "
    
    cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
  
	cQuery += " ) AS FONTE "
	cQuery += " WHERE "
	cQuery += " FONTE.SITTIT > 0 "
	cQuery += " AND FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641. 
	cQuery += " AND FONTE.FAIXA IS NOT NULL  " 
	cQuery += " AND FONTE.FAIXA <> '' " 
	cQuery += " AND FONTE.TPCOBR IS NOT NULL " 
	cQuery += " AND FONTE.TPCOBR <> '' "
    cQuery += " AND FONTE.CNPJRA NOT IN (" + getIntCp() + ") " //Everson - 17/08/2020. Chamado 060504.
    If Select("ADCOMT020") > 0
        ADCOMT020->(DbCloseArea())
        
    EndIf	
    
    TcQuery cQuery New Alias "ADCOMT020"
    nTTcrTop := ADCOMT020->SLDTIT

    cQuery := ""
    cQuery += " SELECT FONTE.EMP, "
	cQuery += " CASE WHEN CODREDCHK IS NULL OR CODREDCHK = '' THEN "
	cQuery += " FONTE.CODRED "
	cQuery += " ELSE "
	cQuery += " ISNULL((SELECT TOP 1 ZF_NOMERED FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF WHERE SZF.D_E_L_E_T_ = '' AND SZF.ZF_REDE = CODREDCHK ORDER BY SZF.ZF_LCREDE DESC),'') END AS NOME, " 
	cQuery += " FONTE.CODRED, ISNULL(FONTE.CODREDCHK,'') AS REDE, ROUND(SUM(FONTE.SLDTIT),2) AS SLDTIT "
	cQuery += " FROM " 
	cQuery += " ( "
    
    cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
    
	cQuery += " ) AS FONTE "
	cQuery += " WHERE "
	cQuery += " FONTE.SITTIT > 0 "
	cQuery += " AND FONTE.TPCOBR NOT IN ('F_INTER-CIA') "
	cQuery += " AND FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND FONTE.FAIXA IS NOT NULL  " 
	cQuery += " AND FONTE.FAIXA <> '' " 
	cQuery += " AND FONTE.TPCOBR IS NOT NULL " 
	cQuery += " AND FONTE.TPCOBR <> '' "
    cQuery += " AND FONTE.CNPJRA NOT IN (" + getIntCp() + ") " //Everson - 17/08/2020. Chamado 060504.
	cQuery += " GROUP BY "
	cQuery += " FONTE.EMP, FONTE.CODRED, FONTE.CODREDCHK "
	cQuery += " ORDER BY SLDTIT DESC "
	
    If Select("ADCOMT020") > 0
        ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"
 
    nPersTT := 0
    nPerAcm := 0
    While ADCOMT020->( !EOF() )
        nPersTT := Round( ((ADCOMT020->SLDTIT / nTTcrTop) * 100) ,4)
        nPerAcm += nPersTT

        cMsg += "	<tr height='20' style='height:15.0pt'> "
        cMsg += "		<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItemCRT <= 20," bgcolor='#fabf8f' ","") + " >"+Alltrim(Str(nItemCRT))+"</td> "
        cMsg += "		<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItemCRT <= 20," bgcolor='#fabf8f' ","") + " >"+ cValToChar(ADCOMT020->EMP) + "</td>" //Everson - 28/07/2020. Chamado 058854.
        cMsg += "		<td colspan='3' class='style8'>"+ADCOMT020->NOME+"</td> "
        cMsg += "		<td class='style19'>"+ADCOMT020->REDE+"</td> "
        cMsg += "		<td class='style8' align='right'>"+Transform( ADCOMT020->SLDTIT , "@E 9,999,999,999" )+"</td> "
        cMsg += "		<td class='style8' align='right'>"+Transform( nPersTT , "@E 999.99" )+"%</td> "
        cMsg += "		<td class='style8' align='right'>"+Transform( nPerAcm , "@E 999.99" )+"%</td> "
        cMsg += "		<td></td> "
        cMsg += "		<td></td> "
        cMsg += "	</tr> "
            ADCOMT020->(DbSkip())
            nItemCRT++  
    End
    
    ADCOMT020->(DbCloseArea())
    
    cMsg += "</table>

Return cMsg
/*/{Protheus.doc} ADCO020G
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020G(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cMsg     := ""
	Local cQuery   := ""
	Local cAssunto := "Aging List - Inadimplencia Interna"
	
	Local nTTped     := 0
	Local nTTinc     := 0
	Local nTTGer     := 0
	Local nIttop20   := 1

	//
    cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='909' style='border-collapse: collapse;width:680pt' class='tabelaTab2'>
    cMsg += "				<colgroup>
    cMsg += "								<col width='37' style='mso-width-source:userset;mso-width-alt:1353;width:28pt' />
    cMsg += "								<col width='259' style='mso-width-source:userset;mso-width-alt:9472;width:194pt' />
    cMsg += "								<col width='4' style='mso-width-source:userset;mso-width-alt:146;width:3pt' />
    cMsg += "								<col width='87' span='7' style='mso-width-source:userset;mso-width-alt:3181;width:65pt' />
    cMsg += "				</colgroup>
    cMsg += "				<tr height='21' style='height:15.75pt'>
    cMsg += "								<td colspan='2' rowspan='2' height='41' width='296' style='height: 30.75pt; width: 222pt' class='style1'>FAIXAS</td>
    cMsg += "								<td width='4' style='width: 3pt' class='style2'>&nbsp;</td>
    cMsg += "								<td colspan='6' width='522' style='width: 390pt' class='style3'>INADIMPLÊNCIA INTERNA</td>
    cMsg += "								<td rowspan='2' width='87' style='width: 65pt' class='style1'>TOTAL</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td height='20' style='height: 15.0pt;' class='style2'>&nbsp;</td>
    cMsg += "								<td class='style4'>ESCRITURAL</td>
    cMsg += "								<td class='style4'>CARTEIRA</td>
    cMsg += "								<td class='style4'>EXPORTAÇÃO</td>
    cMsg += "								<td class='style4'>ASSESSORIA</td>
    cMsg += "								<td class='style4'>PENDÊNCIA</td>
    cMsg += "								<td class='style4'>INTER-CIA</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='6' style='mso-height-source:userset;height:4.5pt'>
    cMsg += "								<td height='6' style='height:4.5pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style5'>&nbsp;</td>
    cMsg += "								<td class='style6'>&nbsp;</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>DE 03 À 30</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr0330PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr0330IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9' align='right'>"+Transform( nVlr0330PD+nVlr0330IC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>DE 31 À 60</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr3160PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr3160IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9' align='right'>"+Transform( nVlr3160PD+nVlr3160IC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>DE 61 À 90</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr6190PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlr6190IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9' align='right'>"+Transform( nVlr6190PD+nVlr6190IC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style7'>ACIMA 90 DIAS</td>
    cMsg += "								<td class='style2'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlrM90PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td class='style8' align='right'>"+Transform( nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style9' align='right'>"+Transform( nVlrM90PD+nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style10'>TOTAL</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "								<td align='right' class='style12'>"+Transform( nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD+nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC , "@E 9,999,999,999" )+"</td>
    cMsg += "				</tr>
    nTTped := nVlr0330PD+nVlr3160PD+nVlr6190PD+nVlrM90PD
    nTTinc := nVlr0330IC+nVlr3160IC+nVlr6190IC+nVlrM90IC
    nTTGer := nTTped + nTTinc
    cMsg += "				<tr height='20' style='height:15.0pt'>
    cMsg += "								<td colspan='2' height='20' style='height: 15.0pt' class='style10'>% INADIMPLÊNCIA</td>
    cMsg += "								<td class='style11'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style1'>&nbsp;</td>
    cMsg += "								<td class='style12' align='right'>"+Transform( Round( (nTTped/nTotGICPD)*100 ,4) , "@E 999.99" )+" % </td>
    cMsg += "								<td class='style12' align='right'>"+Transform( Round( (nTTinc/nTotGICPD)*100 ,4) , "@E 999.99" )+" % </td>
    cMsg += "								<td class='style12' align='right'>"+Transform( Round( (nTTGer/nTotGICPD)*100 ,4) , "@E 999.99" )+" % </td>
    cMsg += "				</tr>
    cMsg += "</table>
    cMsg += "<p>&nbsp;</p>
        
    //
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " CASE WHEN CODREDCHK IS NULL OR CODREDCHK = '' THEN " 
	cQuery += " FONTE.CODRED " 
	cQuery += " ELSE  "
	cQuery += " ISNULL((SELECT TOP 1 ZF_NOMERED FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF WHERE SZF.D_E_L_E_T_ = '' AND SZF.ZF_REDE = CODREDCHK ORDER BY SZF.ZF_LCREDE DESC),'') END AS NOME,
	cQuery += " FONTE.CODRED AS CODREDCHK ,  ISNULL(FONTE.CODREDCHK,'') AS CODRED,  
	cQuery += " ROUND(SUM(CASE WHEN FONTE.PORTAD IN ('P01','P02','P10') THEN FONTE.SLDTIT ELSE 0 END),0) AS PEDFIN, "
	cQuery += " ROUND(SUM(CASE WHEN FONTE.PORTAD IN ('P00') THEN FONTE.SLDTIT ELSE 0 END),0) AS PEDCOM, "
	cQuery += " ROUND(SUM(CASE WHEN FONTE.PORTAD IN ('P03') THEN FONTE.SLDTIT ELSE 0 END),0) AS PEDLOG, "
	cQuery += " ROUND(SUM(CASE WHEN FONTE.PORTAD IN ('P14') THEN FONTE.SLDTIT ELSE 0 END),0) AS PEDSIN, "
	cQuery += " ROUND(SUM(CASE WHEN FONTE.PORTAD IN ('P18','') THEN FONTE.SLDTIT ELSE 0 END),0) AS PEDOUTR, "
	cQuery += " ROUND(SUM(FONTE.SLDTIT),0) AS SLDTIT "
	cQuery += " FROM  (  "
	
	cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
	cQuery += " ) AS FONTE "
	cQuery += " WHERE " 
	cQuery += " FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND FONTE.FAIXA IS NOT NULL "   
	cQuery += " AND FONTE.FAIXA <> '' "  
	cQuery += " AND FONTE.TPCOBR IN ('F_INTER-CIA','E_PENDENCIA') " 
	cQuery += " AND FONTE.CODFAI BETWEEN 1 AND 4 "
	cQuery += " GROUP BY FONTE.CODRED, FONTE.A6_XCLSFIN, FONTE.TPINAD, FONTE.CODREDCHK "
	cQuery += " ORDER BY SLDTIT DESC "

    //
    If Select("D_AGII") > 0
    	D_AGII->(DbCloseArea())
    	
    EndIf
    
    TcQuery cQuery New Alias "D_AGII"
	DbSelectArea("D_AGII")
	D_AGII->(DbGoTop())
	
	//
	cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='909' style='border-collapse: collapse;width:680pt' class='tabelaTab2'>
    cMsg += "				<colgroup>
    cMsg += "								<col width='37' /><col width='259' />
    cMsg += "								<col width='4' /><col width='87' span='7' />
    cMsg += "				</colgroup>
    cMsg += "				<tr height='36'>
    cMsg += "								<td colspan='10' height='36' width='900' class='style3'>CLIENTES - TOP 20</td>
    cMsg += "				</tr>
    cMsg += "				<tr height='5'>
    cMsg += "								<td height='5'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "				</tr>
    cMsg += "				<tr height='20' align='center'>
    cMsg += "								<td height='20' class='style4' align='center'>ITEM</td>
    cMsg += "								<td class='style4' align='center'>CLIENTE</td>
    cMsg += "								<td class='style4' align='center'>REDE</td>
    cMsg += "								<td class='style4' align='center'>PEND.FIN</td>
    cMsg += "								<td class='style4' align='center'>PEND.COML</td>
    cMsg += "								<td class='style4' align='center'>PEND.LOG</td>
    cMsg += "								<td class='style4' align='center'>SINISTRO</td>
    cMsg += "								<td class='style4' align='center'>OUTROS</td>
    cMsg += "								<td class='style4' align='center'>TOTAL</td>
    cMsg += "				</tr>
	
	//
    While D_AGII->(!Eof())
    
        cMsg += "	<tr height='20' class='style7'>
        cMsg += "		<td height='20' class='style7' " + Iif(nIttop20 <= 20," bgcolor='#fabf8f' ","") + ">"+Alltrim(Str(nIttop20))+"</td>
        cMsg += "		<td class='style7' align = 'left'>"+D_AGII->NOME+"</td>
        cMsg += "		<td class='style7' align = 'left'>"+D_AGII->CODRED+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->PEDFIN  , "@E 999,999,999,999" )+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->PEDCOM  , "@E 999,999,999,999" )+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->PEDLOG  , "@E 999,999,999,999" )+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->PEDSIN  , "@E 999,999,999,999" )+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->PEDOUTR , "@E 999,999,999,999" )+"</td>
        cMsg += "		<td class='style7' align = 'right'>"+Transform( D_AGII->(PEDFIN+PEDCOM+PEDLOG+PEDSIN+PEDOUTR) , "@E 999,999,999,999" )+"</td>
        cMsg += "	</tr>

        D_AGII->(DbSkip())
        nIttop20++
        
    End
    
    //
    D_AGII->(DbCloseArea())
    
    cMsg += "</table>

Return cMsg
/*/{Protheus.doc} ADCO020H
    Execucao de Agendamento de Workflow.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020H(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cMsg   := ""
	Local cQuery := ""
	Local cAssunto := "Aging List - Inadimplencia Corrente"
	Local nTTVlrGer := 0
	Local nItinco   := 0
	Local nTTgTop20 := 0
	Local nTTgAcm20 := 0
	Local nTTpert20 := 0
	Local cQueryI	 := ""
     
    //
    cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='909' style='border-collapse: collapse; width: 680pt' class='tabelaTab4'>
    cMsg += "<colgroup>
    cMsg += "<col width='37' style='mso-width-source: userset; mso-width-alt: 1353; width: 28pt' />
    cMsg += "<col width='259' style='mso-width-source: userset; mso-width-alt: 9472; width: 194pt' />
    cMsg += "<col width='4' style='mso-width-source: userset; mso-width-alt: 146; width: 3pt' />
    cMsg += "<col width='87' span='7' style='mso-width-source: userset; mso-width-alt: 3181; width: 65pt' />
    cMsg += "</colgroup>
    cMsg += "<tr height='21' style='height: 15.75pt'>
    cMsg += "<td colspan='4' rowspan='2' height='41' width='296' style='height: 30.75pt; width: 222pt' class='style1'>FAIXAS</td>
    cMsg += "<td width='5' style='width: 3pt' class='style2'>&nbsp;</td>
    cMsg += "<td colspan='6' width='522' style='width: 390pt' class='style3'>INADIMPLÊNCIA CORRENTE</td>
    cMsg += "<td rowspan='2' width='87' style='width: 65pt' class='style1'>TOTAL</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td height='20' style='height: 15.0pt;' class='style2'>&nbsp;</td>
    cMsg += "<td class='style4'>ESCRITURAL</td>
    cMsg += "<td class='style4'>CARTEIRA</td>
    cMsg += "<td class='style4'>EXPORTAÇÃO</td>
    cMsg += "<td class='style4'>ASSESSORIA</td>
    cMsg += "<td class='style4'>PENDÊNCIA</td>
    cMsg += "<td class='style4'>INTER-CIA</td>
    cMsg += "</tr>
    cMsg += "<tr height='6' style='mso-height-source: userset; height: 4.5pt'>
    cMsg += "<td colspane='10' height='6' style='height: 4.5pt'></td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td colspan='4' height='20' style='height: 15.0pt' class='style7'>DE 03 À 30</td>
    cMsg += "<td class='style2'>&nbsp;</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr0330ES , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr0330CA , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr0330EX , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr0330AS , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td align='right' class='style9'>"+Transform( nVlr0330ES + nVlr0330CA + nVlr0330EX + nVlr0330AS , "@E 999,999,999,999" )+"</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td colspan='4' height='20' style='height: 15.0pt' class='style7'>DE 31 À 60</td>
    cMsg += "<td class='style2'>&nbsp;</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr3160ES , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr3160CA , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr3160EX , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr3160AS , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td align='right' class='style9'>"+Transform( nVlr3160ES + nVlr3160CA + nVlr3160EX + nVlr3160AS , "@E 999,999,999" )+"</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td colspan='4' height='20' style='height: 15.0pt' class='style7'>DE 61 À 90</td>
    cMsg += "<td class='style2'>&nbsp;</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr6190ES , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr6190CA , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr6190EX , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style8' align='right'>"+Transform( nVlr6190AS , "@E 999,999,999" )+"</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td align='right' class='style9'>"+Transform( nVlr6190ES + nVlr6190CA + nVlr6190EX + nVlr6190AS , "@E 999,999,999" )+"</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td colspan='4' height='20' style='height: 15.0pt' class='style10'>Total</td>
    cMsg += "<td class='style11'>&nbsp;</td>
    cMsg += "<td align='right' class='style12'>"+Transform( nVlr0330ES+nVlr3160ES+nVlr6190ES , "@E 999,999,999" )+"</td>
    cMsg += "<td align='right' class='style12'>"+Transform( nVlr0330CA+nVlr3160CA+nVlr6190CA , "@E 999,999,999" )+"</td>
    cMsg += "<td align='right' class='style12'>"+Transform( nVlr0330EX+nVlr3160EX+nVlr6190EX , "@E 999,999,999" )+"</td>
    cMsg += "<td align='right' class='style12'>"+Transform( nVlr0330AS+nVlr3160AS+nVlr6190AS , "@E 999,999,999" )+"</td>
    nTTVlrGer := nVlr0330ES+nVlr3160ES+nVlr6190ES+nVlr0330CA+nVlr3160CA+nVlr6190CA+nVlr0330EX+nVlr3160EX+nVlr6190EX+nVlr0330AS+nVlr3160AS+nVlr6190AS
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td align='right' class='style12'>"+Transform( nTTVlrGer , "@E 999,999,999" )+"</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td colspan='4' height='20' style='height: 15.0pt' class='style10'>% INADIMPLÊNCIA</td>
    cMsg += "<td class='style11'>&nbsp;</td>
    cMsg += "<td align='right' class='style12'>"+Transform( Round( ((nVlr0330ES+nVlr3160ES+nVlr6190ES)/nTotGIC)*100 ,2) , "@E 999.99" )+" %</td>
    cMsg += "<td align='right' class='style12'>"+Transform( Round( ((nVlr0330CA+nVlr3160CA+nVlr6190CA)/nTotGIC)*100 ,2) , "@E 999.99" )+" %</td>
    cMsg += "<td align='right' class='style12'>"+Transform( Round( ((nVlr0330EX+nVlr3160EX+nVlr6190EX)/nTotGIC)*100 ,2) , "@E 999.99" )+" %</td>
    cMsg += "<td align='right' class='style12'>"+Transform( Round( ((nVlr0330AS+nVlr3160AS+nVlr6190AS)/nTotGIC)*100 ,2) , "@E 999.99" )+" %</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td class='style1'>&nbsp;</td>
    cMsg += "<td align='right' class='style12'>"+Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )+" %</td>
    
    //Everson - 17/01/2019. Chamado 044743.
    DbSelectArea("SX5")
    SX5->(DbSetOrder(1))
    SX5->(DbGoTop())
    If SX5->( DbSeek( "02Z&" + Right(DToS(Date()),6) ) )
    	
    	Conout("ADCOM020P - ADCO020H - DbSeek true " + Right(DToS(Date()),6) )
    	RecLock("SX5",.F.)
    		SX5->X5_DESCRI  := Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    		SX5->X5_DESCENG := Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    		SX5->X5_DESCSPA	:= Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    	MsUnlock()
    	
    Else
    	
    	Conout("ADCOM020P - ADCO020H - DbSeek false " + Right(DToS(Date()),6) )
    	RecLock("SX5",.T.)
    		SX5->X5_FILIAL	:= "02"
    		SX5->X5_TABELA	:= "Z&"
    		SX5->X5_CHAVE	:= Right(DToS(Date()),6)
    		SX5->X5_DESCRI  := Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    		SX5->X5_DESCENG := Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    		SX5->X5_DESCSPA	:= Transform( Round( (nTTVlrGer/nTotGIC)*100 ,2) , "@E 999.99" )
    	MsUnlock()    	
    
    EndIf

    //
    cMsg += "</tr>
    cMsg += "<tr height='6' style='mso-height-source: userset; height: 4.5pt'>
    cMsg += "<td height='6' style='height: 4.5pt'></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td height='20' style='height: 15.0pt'></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "</tr>
    cMsg += "<tr height='36' style='mso-height-source: userset; height: 27.0pt'>
    cMsg += "<td colspan='8' style='height: 15.75pt' height='21'  class='style3'>INADIMPLÊNCIA DE CLIENTES - TOP 20</td>" //Everson - 28/07/2020. Chamado 058854.
    cMsg += "<td></td>
    cMsg += "<td colspan='2' style='height: 15.75pt' height='21'  class='style3'>HISTÓRICO</td>
    cMsg += "</tr>
    cMsg += "<tr height='5' style='mso-height-source: userset; height: 3.75pt'>
    cMsg += "<td height='5' style='height: 3.75pt'></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "<td></td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height: 15.0pt'>
    cMsg += "<td height='20' style='height: 15.0pt' class='style15'>ITEM</td>
    cMsg += "<td height='20' style='height: 15.0pt' class='style15'>EMPRESA</td>" //Everson - 28/07/2020. Chamado 058854.
    cMsg += "<td class='style15' align='center'>CLIENTE</td>
    cMsg += "<td colspan='2' class='style16' align='center'>REDE</td>
    cMsg += "<td class='style15' align='center'>VLR ATRASO</td>
    cMsg += "<td class='style15' align='center'>%TT</td>
    cMsg += "<td class='style15' align='center'>% ACUM</td>
    cMsg += "<td></td>
    cMsg += "<td class='style15' align='center'>DATA</td>
    cMsg += "<td class='style15' align='center'>% INADIMPL</td>
    cMsg += "</tr>
    
    //
    cQuery := ""
    cQuery += " SELECT "
	cQuery += " ROUND(SUM(FONTE.SLDTIT),2) AS SLDTIT "
	cQuery += " FROM " 
	cQuery += " ( "
    
    cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
    
	cQuery += " ) AS FONTE "
	cQuery += " WHERE "
	cQuery += " FONTE.SITTIT > 0 "
	cQuery += " AND FONTE.TPCOBR NOT IN ('F_INTER-CIA','E_PENDENCIA') "
	cQuery += " AND FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND FONTE.FAIXA IS NOT NULL  " 
	cQuery += " AND FONTE.FAIXA <> '' " 
	cQuery += " AND FONTE.TPCOBR IS NOT NULL " 
	cQuery += " AND FONTE.TPCOBR <> '' "
	cQuery += " AND FONTE.CODFAI IN ('1','2','3') "
    If Select("ADCOMT020") > 0
        ADCOMT020->(DbCloseArea())
    EndIf	
    
    TcQuery cQuery New Alias "ADCOMT020"
    nTTgTop20 := ADCOMT020->SLDTIT

    cQuery := ""
    cQuery += " SELECT FONTE.EMP, " //Everson - 28/07/2020. Chamado 058854.
	cQuery += " CASE WHEN CODREDCHK IS NULL OR CODREDCHK = '' THEN "
	cQuery += " FONTE.CODRED "
	cQuery += " ELSE "
	cQuery += " ISNULL((SELECT TOP 1 ZF_NOMERED FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF WHERE SZF.D_E_L_E_T_ = '' AND SZF.ZF_REDE = CODREDCHK ORDER BY SZF.ZF_LCREDE DESC),'') END AS NOME, " 
	cQuery += " FONTE.CODRED, ISNULL(FONTE.CODREDCHK,'') AS REDE, ROUND(SUM(FONTE.SLDTIT),2) AS SLDTIT "
	cQuery += " FROM " 
	cQuery += " ( "
    
    cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
    
	cQuery += " ) AS FONTE "
	cQuery += " WHERE "
	cQuery += " FONTE.SITTIT > 0 "
	cQuery += " AND FONTE.TPCOBR NOT IN ('F_INTER-CIA','E_PENDENCIA') "
	cQuery += " AND FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND FONTE.FAIXA IS NOT NULL  " 
	cQuery += " AND FONTE.FAIXA <> '' " 
	cQuery += " AND FONTE.TPCOBR IS NOT NULL " 
	cQuery += " AND FONTE.TPCOBR <> '' "
	cQuery += " AND FONTE.CODFAI IN ('1','2','3') "
	cQuery += " GROUP BY "
	cQuery += " FONTE.EMP, FONTE.CODRED, FONTE.CODREDCHK " //Everson - 28/07/2020. Chamado 058854.
	cQuery += " ORDER BY SLDTIT DESC "
	
    If Select("ADCOMT020") > 0
        ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"

    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOMT020"
    
    //
    cQueryI	:= " SELECT TOP 20 '20' + X5_CHAVE AS DATA, X5_DESCRI AS VALOR FROM " + RetSqlName("SX5") + " AS SX5 WHERE X5_FILIAL = '02' AND X5_TABELA = 'Z&' ORDER BY X5_CHAVE DESC "
    
    If Select("INADIM") > 0
        INADIM->(DbCloseArea())
    EndIf	
    TcQuery cQueryI New Alias "INADIM"
    INADIM->(DbGoTop())

    //   
    While ! ADCOMT020->(EOF()) .Or. ! INADIM->(Eof())
    
    	cMsg += "<tr height='20' style='height: 15.0pt'>
        
        If ! ADCOMT020->(EOF()) //Everson - 17/01/2019. Chamado 044743.
        
            nItinco++
	        nTTpert20 := Round( (ADCOMT020->SLDTIT/nTotGIC)*100,2)
	        nTTgAcm20 += nTTpert20
        
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItinco <= 20," bgcolor='#fabf8f' ","") + " >"+Alltrim(Str(nItinco))+"</td> "
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItinco <= 20," bgcolor='#fabf8f' ","") + " >"+cValToChar(ADCOMT020->EMP)+"</td> " //Everson - 28/07/2020. Chamado 058854.

	        cMsg += "<td class='style8' align='left'>"+ ADCOMT020->NOME +"</td> "
	        cMsg += "<td colspan='2' class='style18' align='left'>"+ ADCOMT020->REDE +"</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( ADCOMT020->SLDTIT , "@E 999,999,999" ) +"</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( nTTpert20 , "@E 999.99" ) +" %</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( nTTgAcm20 , "@E 999.99" ) +" %</td> "
	        cMsg += "<td></td> "
	        
	        ADCOMT020->(DbSkip())
	        
	    Else //Everson - 17/01/2019. Chamado 044743.
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18'></td> "
	        cMsg += "<td class='style8' align='left'></td> "
	        cMsg += "<td colspan='2' class='style18' align='left'></td> "
	        cMsg += "<td class='style8' align='right'></td> "
	        cMsg += "<td class='style8' align='right'></td> "
	        cMsg += "<td class='style8' align='right'></td> "
	        cMsg += "<td></td>	    	
        
        EndIf
        
        //
        If ! INADIM->(Eof())
	        cMsg += "<td class='style8'>" + DToC(SToD(INADIM->DATA)) + "</td> "
	        cMsg += "<td class='style8'>" + Alltrim(cValToChar(INADIM->VALOR)) + "</td> "
            
            INADIM->(DbSkip())
                
        Else
	        cMsg += "<td class='style8'>&nbsp;</td> "
	        cMsg += "<td class='style8'>&nbsp;</td> "
        
        EndIf
        
        cMsg += "</tr> "

    End
    
    //
    INADIM->(DbCloseArea())
    ADCOMT020->(DbCloseArea())
    
    cMsg += "</table> "

Return cMsg
/*/{Protheus.doc} scriptAgGrl
    Script para o aging list geral.
    @type  Static Function
    @author Ricardo Lima
    @since 10/08/2018
    @version 01
    /*/
Static Function scriptAgGrl(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cQuery := ""
	
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " FONTE.FAIXA+FONTE.TPCOBR AS TIPO, ROUND(SUM(FONTE.SLDTIT),0) AS SLDTIT " 
	cQuery += " FROM " 
	cQuery += " ( " 
	
	cQuery += scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
	cQuery += " ) AS FONTE " 
	cQuery += " WHERE " 
	cQuery += " FONTE.TIPDOC NOT IN ('RA','NCC','AB-','NDC')  " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND FONTE.FAIXA IS NOT NULL  " 
	cQuery += " AND FONTE.FAIXA <> '' " 
	cQuery += " AND FONTE.TPCOBR IS NOT NULL " 
	cQuery += " AND FONTE.TPCOBR <> '' " 
	cQuery += " GROUP BY FONTE.FAIXA,FONTE.TPCOBR " 
	
Return cQuery
/*/{Protheus.doc} scriptBase
    Script base de inadimplência.
    @type  Static Function
    @author Everson
    @since 10/08/2018
    @version 01
    /*/
Static Function scriptBase(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cQuery         := ""
	Local cCodItCia      := getIntCp()//"'02090384','03552786','07451656','12097672','13803055','60037058'"//"'030267','031433','016652','011991','031017','027601','014999','024288','024287','024707','025663','025652','027603'" //Everson - 29/07/2020. Chamado 058854. //Everson - 17/08/2020. Chamado 060504.
	Local cCodVendExpt	 := "000800"
    Local nAux           := 1 //Everson - 29/07/2020. Chamado 058854.

    //
    For nAux := 1 To Len(aEmp) //Everson - 29/07/2020. Chamado 058854.

        //
        cQuery += " SELECT '" + aEmp[nAux][1] + " " + aEmp[nAux][2] + "' AS EMP, CADREDE.CODRED AS CODREDCHK , CASE WHEN CADREDE.CODRED IS NULL THEN CADCLIENTE.RZSOCI ELSE CADREDE.CODRED END AS CODRED, " 
        cQuery += " TITULOSREC.*, " 
        cQuery += " CADCLIENTE.CNPJRA, CADCLIENTE.RZSOCI, " 
        cQuery += " CADCLIENTE.VENDED, " 
        cQuery += " CADPORTADOR.A6_XCLSFIN, " 
        cQuery += " ISNULL( " 
        cQuery += " CASE  " 
        cQuery += " WHEN TITULOSREC.E1_TIPO NOT IN ('RA','NCC','AB-','NDC') AND TITULOSREC.SLDTIT > 0 AND CADCLIENTE.VENDED = '" + cCodVendExpt + "' AND (TITULOSREC.E1_HIST LIKE 'REC%' " + Iif(aEmp[nAux][1] == "02","","OR TITULOSREC.E1_RECEEC ='S'") + " ) THEN 'G_RECEXP' " //Everson - 29/07/2020. Chamado 058854. //Everson - 29/07/2020. Chamado 059641.
        cQuery += " WHEN TITULOSREC.PORTAD = '18'     THEN 'F_INTER-CIA' " 
        cQuery += " WHEN CADCLIENTE.CNPJRA IN (" + cCodItCia + ") THEN 'F_INTER-CIA' " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHEN CADCLIENTE.VENDED = '" + cCodVendExpt + "' THEN 'C_EXPORTAÇÃO' " 
        cQuery += " WHEN (TITULOSREC.PORTAD = '' OR CADPORTADOR.A6_XCLSFIN = '2')      THEN 'B_CARTEIRA' " 
        cQuery += " WHEN CADPORTADOR.A6_XCLSFIN = '1' THEN 'D_ASSESSORIA' " 
        cQuery += " WHEN CADPORTADOR.A6_XCLSFIN = '3' THEN 'A_ESCRITURAL' " 
        cQuery += " WHEN CADPORTADOR.A6_XCLSFIN = '4' THEN 'E_PENDENCIA' " 
        cQuery += " END ,'')AS TPCOBR, " 
        cQuery += " ISNULL(CASE " 
        cQuery += " WHEN TITULOSREC.PORTAD = '18' OR CADCLIENTE.CNPJRA IN (" + cCodItCia + ") THEN '10' " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " END,'') AS TPINAD, " 
        cQuery += " CASE "
        cQuery += " WHEN TITULOSREC.E1_TIPO NOT IN ('RA','NCC','AB-','NDC') AND TITULOSREC.SLDTIT > 0 AND CADCLIENTE.VENDED = '" + cCodVendExpt + "' AND (TITULOSREC.E1_HIST LIKE 'REC%' " + Iif(aEmp[nAux][1] == "02","","OR TITULOSREC.E1_RECEEC ='S'") + ") THEN 'G_RECEXP' " //Everson - 29/07/2020. Chamado 058854. //Everson - 29/07/2020. Chamado 059641.
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 4  AND 30 THEN 'A_3_30'  " 
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 31 AND 60 THEN 'B_31_60' " 
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 61 AND 90 THEN 'C_61_90' " 
        cQuery += " WHEN TITULOSREC.DIASAT > 90              THEN 'D_M_90' " 
        cQuery += " WHEN TITULOSREC.DIASAT <= 3              THEN 'E_A_VENCER'     " 
        cQuery += " END AS FAIXA, " 
        
        cQuery += " CASE " 
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 4  AND 30 THEN 1 " 
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 31 AND 60 THEN 2 " 
        cQuery += " WHEN TITULOSREC.DIASAT BETWEEN 61 AND 90 THEN 3 " 
        cQuery += " WHEN TITULOSREC.DIASAT > 90              THEN 4 " 
        cQuery += " WHEN TITULOSREC.DIASAT <= 3              THEN 5 " 
        cQuery += " END AS CODFAI " 
        
        cQuery += "  " 
        cQuery += " FROM  " 
        cQuery += " ( " 
        cQuery += " SELECT " 
        cQuery += " E1_AGEDEP, E1_CONTA, E1_TIPO, E1_HIST, " + Iif(aEmp[nAux][1] == "02","''","E1_RECEEC") + " AS E1_RECEEC, " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " E1_CLIENTE AS CODCLI,  " 
        cQuery += " E1_LOJA    AS LOJACL,  " 
        cQuery += " E1_TIPO    AS TIPDOC,  " 
        cQuery += " CASE WHEN E1_VEND1 = '" + cCodVendExpt + "' AND E1_MOEDA = 2 THEN E1_BASCOM1 ELSE E1_VALOR END AS VLRTIT,  " 
        cQuery += " CASE WHEN E1_VEND1 = '" + cCodVendExpt + "' AND E1_MOEDA = 2 THEN E1_BASCOM1 ELSE E1_SALDO END AS SLDTIT,  " 
        cQuery += " CONVERT(VARCHAR(8),CAST(GETDATE() AS DATE),112) AS DTATUA, " 
        cQuery += " E1_PORTADO AS PORTAD,  " 
        cQuery += " E1_MOEDA   AS TMOEDA,  " 
        cQuery += " DATEDIFF(DAY,E1_VENCREA,GETDATE()) AS DIASAT, " 
        cQuery += " CASE  " 
        cQuery += " WHEN E1_VEND1 =  '" + cCodVendExpt + "' AND E1_HIST LIKE '%REC%' THEN '0' " 
        cQuery += " WHEN E1_VEND1 =  '" + cCodVendExpt + "' " + Iif(aEmp[nAux][1] == "02","","AND E1_RECEEC = 'S'") + " THEN '0'  " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHEN DATEDIFF(DAY,CAST(GETDATE() AS DATE),CAST(E1_VENCREA AS DATE)) < 0 OR DATEDIFF(DAY,CAST(GETDATE() AS DATE),CAST(E1_VENCREA AS DATE))  = 0 THEN '1' " 
        cQuery += " WHEN DATEDIFF(DAY,CAST(GETDATE() AS DATE),CAST(E1_VENCREA AS DATE)) > 0 THEN '2'  " 
        cQuery += " END AS SITTIT " 
        cQuery += " FROM  " 
        cQuery += " SE1" + aEmp[nAux][1] + "0 (NOLOCK) AS SE1   " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHERE  " 
        cQuery += " SE1.D_E_L_E_T_ =''  " 
        cQuery += " AND E1_SALDO > 0 " 
        cQuery += " ) AS TITULOSREC " 
        cQuery += " INNER JOIN " 
        cQuery += " ( " 
        cQuery += " SELECT  " 
        cQuery += " A1_COD    AS CODCLI,  " 
        cQuery += " A1_LOJA   AS LOJACLI,  " 
        cQuery += " LEFT(RTRIM(LTRIM(A1_CGC)),8) AS CNPJRA, " 
        cQuery += " A1_NOME   AS RZSOCI,  " 
        cQuery += " A1_VEND   AS VENDED,  "  
        cQuery += " '.'       AS CODREDE, " 
        cQuery += " A1_BCO1   AS PORTAD " 
        cQuery += " FROM  " 
        cQuery += " SA1" + aEmp[nAux][1] + "0 (NOLOCK) AS SA1 " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHERE  " 
        cQuery += " SA1.D_E_L_E_T_ = '' " 
        cQuery += " ) AS CADCLIENTE ON " 
        cQuery += " TITULOSREC.CODCLI = CADCLIENTE.CODCLI " 
        cQuery += " AND TITULOSREC.LOJACL = CADCLIENTE.LOJACLI " 
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " ( " 
        cQuery += " SELECT " 
        cQuery += " ZF_CGCMAT AS CNPJRD,  " 
        cQuery += " ZF_REDE   AS CODRED   " 
        cQuery += " FROM  " 

        //Everson - 29/07/2020. Chamado 058854.
        If aEmp[nAux][1] == "02"
            cQuery += " SZF010 (NOLOCK) AS SZF  "

        Else 
            cQuery += " SZF" + aEmp[nAux][1] + "0 (NOLOCK) AS SZF  "

        EndIf 

        //
        cQuery += " WHERE  " 
        cQuery += " SZF.D_E_L_E_T_ ='' " 
        cQuery += " ) AS CADREDE ON " 
        cQuery += " CADCLIENTE.CNPJRA = CADREDE.CNPJRD "  
        cQuery += " LEFT OUTER JOIN " 
        cQuery += " ( " 
        cQuery += " SELECT * FROM SA6" + aEmp[nAux][1] + "0 (NOLOCK) AS SA6 WHERE SA6.D_E_L_E_T_ = '' " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " ) AS CADPORTADOR ON " 
        cQuery += " TITULOSREC.PORTAD =  CADPORTADOR.A6_COD " 
        cQuery += " AND TITULOSREC.E1_AGEDEP = CADPORTADOR.A6_AGENCIA " 
        cQuery += " AND TITULOSREC.E1_CONTA = CADPORTADOR.A6_NUMCON " 

        //Everson - 29/07/2020. Chamado 058854.
        If nAux < Len(aEmp)
            cQuery += " UNION ALL "

        EndIf

    Next nAux
	
Return cQuery
/*/{Protheus.doc} ADCO020I
    Script base de inadimplência.
    @type  Static Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
Static Function ADCO020I(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cMsg      := ""
	Local cQuery    := ""
	Local cAssunto  := "Aging List - Provisão Perdas e Perdas Efetivas"
	
	Local nItinco   := 0
	Local nTTgTop20 := 0
	Local nTTgAcm20 := 0
	Local nTTpert20 := 0
	
	Local nTT2013FT := 0
	Local nTT2013AB := 0
	Local nTT2013BX := 0
	Local nTT2014FT := 0
	Local nTT2014AB := 0
	Local nTT2014BX := 0
	Local nTT2015FT := 0
	Local nTT2015AB := 0
	Local nTT2015BX := 0
	Local nTT2016FT := 0
	Local nTT2016AB := 0
	Local nTT2016BX := 0
	Local nTT2017FT := 0
	Local nTT2017AB := 0
	Local nTT2017BX := 0
	//Local nTT2018FT := 0
	//Local nTT2018AB := 0
	//Local nTT2018BX := 0
	
	Local nOR2013FT := 0
	Local nOR2013AB := 0
	Local nOR2013BX := 0
	Local nOR2014FT := 0
	Local nOR2014AB := 0
	Local nOR2014BX := 0
	Local nOR2015FT := 0
	Local nOR2015AB := 0
	Local nOR2015BX := 0
	Local nOR2016FT := 0
	Local nOR2016AB := 0
	Local nOR2016BX := 0
	Local nOR2017FT := 0
	Local nOR2017AB := 0
	Local nOR2017BX := 0
	//Local nOR2018FT := 0
	//Local nOR2018AB := 0
	//Local nOR2018BX := 0
	
	Local  nBxABGr	 := nFatGr := 0 
    Local cQueryPDD	 := ""
    
    //Everson - 17/10/2019- Chamado 052531.
    Local nTTAtualFT := 0
    Local nORAtualFT := 0
    Local nTTAtualBX := 0
    Local nORAtualBX := 0
    Local nTTAtualAB := 0
    Local nORAtualAB := 0
    //
	
	//
	cQuery := ""
	cQuery += " SELECT "
	cQuery += " BASE.ANO, ROUND(SUM(BASE.VLRORI),0) AS VLRORI, '1' AS FLAG "
	cQuery += " FROM "
	cQuery += " ( "
		
	cQuery += scriptFatu(aEmp) //Everson - 29/07/2020. Chamado 058854.
		
	cQuery += " ) AS BASE "
	cQuery += " WHERE "
	cQuery += " BASE.E1_TIPO IN ('NF','NCC','NDC') " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " GROUP BY "
	cQuery += " BASE.ANO "
	
	cQuery += " UNION ALL "
	
	cQuery += " SELECT "
	cQuery += " BASE.ANO, ROUND(SUM(BASE.VLRORI),0) AS VLRORI, '2' AS FLAG "
	cQuery += " FROM "
	cQuery += " ( "
		
	cQuery += scriptFatu(aEmp) //Everson - 29/07/2020. Chamado 058854.
		
	cQuery += " ) AS BASE "
	cQuery += " WHERE "
	cQuery += " BASE.E1_TIPO NOT IN ('NF','NCC','RA','AB-','BON','DSF','JR','NDC') " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " GROUP BY "
	cQuery += " BASE.ANO "
		
	cQuery += " ORDER BY "
    cQuery += " BASE.ANO "
    
    //
    Conout( DToC(Date()) + " " + Time() + " ADCOM020P -ADCO020I - ADCO020I - cQuery FAT " + cQuery )

	//
	If Select("D_FANO") > 0
		D_FANO->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_FANO"
	DbSelectArea("D_FANO")
	D_FANO->(DbGoTop())
	While ! D_FANO->(Eof())
	
	Do Case
 		
 		//
		Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
			nTT2013FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
	    	nTT2014FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
	    	nTT2015FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
	    	nTT2016FT := D_FANO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
	    	nTT2017FT := D_FANO->VLRORI

        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar(Year(Date()))) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "1"
            nTTAtualFT := D_FANO->VLRORI            
        //
        
		Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
			nOR2013FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
	    	nOR2014FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
	    	nOR2015FT := D_FANO->VLRORI
	    
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
	    	nOR2016FT := D_FANO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
            nOR2017FT := D_FANO->VLRORI
        
        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_FANO->ANO)) = Alltrim(cValToChar( Year(Date()))) .And. Alltrim(cValToChar(D_FANO->FLAG)) = "2"
	    	nORAtualFT := D_FANO->VLRORI
	    	
    	EndCase
    		
		D_FANO->(DbSkip())
		
	End
	
	D_FANO->(DbCloseArea())
	
    //
    cMsg += "<table border='0' cellpadding='0' cellspacing='0' width='1020' style='border-collapse:
    cMsg += " collapse;width:764pt' class='tabelaTab5'>
    cMsg += "<colgroup>
    cMsg += "<col width='37' style='mso-width-source:userset;mso-width-alt:1353;width:28pt' />
    cMsg += "<col width='370' style='mso-width-source:userset;mso-width-alt:13531;width:278pt' />
    cMsg += "<col width='4' style='mso-width-source:userset;mso-width-alt:146;width:3pt' />
    cMsg += "<col width='87' span='7' style='mso-width-source:userset;mso-width-alt:3181;width:65pt' />
    cMsg += "</colgroup>
    cMsg += "<tr height='21' style='height:15.75pt'>
    cMsg += "<td colspan='3' rowspan='2' height='41' width='407' style='height: 30.75pt; width: 306pt' class='style1'>FAIXAS</td>
    cMsg += "<td width='4' style='width: 3pt' class='style2'>&nbsp;</td>
    cMsg += "<td colspan='6' width='522' style='width: 390pt' class='style3'>PROVISÃO PERDAS E PERDAS EFETIVAS</td>
    cMsg += "<td rowspan='2' width='87' style='width: 65pt' class='style1'>TOTAL</td>
    cMsg += "</tr>
    cMsg += "<tr height='20' style='height:15.0pt'>
    cMsg += "<td height='20' style='height: 15.0pt;' class='style2'>&nbsp;</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())-5) + "</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())-4) + "</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())-3) + "</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())-2) + "</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())-1) + "</td>
    cMsg += "<td class='style4'>" + cValToChar(Year(Date())) + "</td>
    cMsg += "</tr>
    cMsg += "<tr height='6' style='mso-height-source:userset;height:4.5pt'>
    cMsg += "								<td height='6' style='height:4.5pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "</tr>
    
    //
    cQuery := ""
    cQuery += " SELECT "
	cQuery += " TITULOSRECPDD.FLAGSI, YEAR(TITULOSRECPDD.DTVENR) AS ANO, ROUND(SUM(TITULOSRECPDD.VLRPDD),0) AS VLRORI, CASE WHEN TITULOSRECPDD.FLAGSI = '1' THEN '1' ELSE '3' END AS FLAG "
	cQuery += " FROM "
	cQuery += " ( "
	
    cQuery += titRecPDD(aEmp) //Everson - 29/07/2020. Chamado 058854.

	cQuery += " ) AS TITULOSRECPDD "
	cQuery += " WHERE TITULOSRECPDD.TIPDOC = 'NF' "
	cQuery += " AND YEAR(TITULOSRECPDD.DTVENR) >= " + cValToChar(Year(Date())-5) + " AND YEAR(TITULOSRECPDD.DTVENR) <= " + cValToChar(Year(Date())) + " " //Everson - 17/10/2019- Chamado 052531.
	cQuery += " GROUP BY TITULOSRECPDD.FLAGSI,YEAR(TITULOSRECPDD.DTVENR) "
	
	cQuery += " UNION ALL "
	
    cQuery += " SELECT "
	cQuery += " TITULOSRECPDD.FLAGSI, YEAR(TITULOSRECPDD.DTVENR) AS ANO, ROUND(SUM(TITULOSRECPDD.VLRPDD),0) AS VLRORI,CASE WHEN TITULOSRECPDD.FLAGSI = '1' THEN '2' ELSE '4' END AS FLAG "
	cQuery += " FROM "
	cQuery += " ( "
	
    cQuery += titRecPDD(aEmp) //Everson - 29/07/2020. Chamado 058854.

	cQuery += " ) AS TITULOSRECPDD "
	cQuery += " WHERE TITULOSRECPDD.TIPDOC NOT IN ('NF','NDC') " //Everson - 29/07/2020. Chamado 059641.
	cQuery += " AND YEAR(TITULOSRECPDD.DTVENR) >= " + cValToChar(Year(Date())-5) + " AND YEAR(TITULOSRECPDD.DTVENR) <= " + cValToChar(Year(Date())) + " " //Everson - 17/10/2019- Chamado 052531.
	cQuery += " GROUP BY TITULOSRECPDD.FLAGSI,YEAR(TITULOSRECPDD.DTVENR) "	
	
    cQuery += " ORDER BY YEAR(TITULOSRECPDD.DTVENR) ASC "
    
    //
    Conout( DToC(Date()) + " " + Time() + " ADCOM020P -ADCO020I - ADCO020I - cQuery VENC " + cQuery )

	//
	If Select("D_BAIXADO") > 0
		D_BAIXADO->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "D_BAIXADO"
	DbSelectArea("D_BAIXADO")
	D_BAIXADO->(DbGoTop())
	While ! D_BAIXADO->(Eof())
	
	Do Case
 		
 		//Baixado - faturamento.
		Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
			nTT2013BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
	    	nTT2014BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
	    	nTT2015BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
	    	nTT2016BX := D_BAIXADO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
	    	nTT2017BX := D_BAIXADO->VLRORI

        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()))) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "1"
            nTTAtualBX := D_BAIXADO->VLRORI
            
	    //Baixado - outros.
		Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
			nOR2013BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
	    	nOR2014BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
	    	nOR2015BX := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
	    	nOR2016BX := D_BAIXADO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
	    	nOR2017BX := D_BAIXADO->VLRORI

        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()))) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "2"
            nORAtualBX := D_BAIXADO->VLRORI
            
	    //Abertos - faturamento.
		Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
			nTT2013AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
	    	nTT2014AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
	    	nTT2015AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
	    	nTT2016AB := D_BAIXADO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
	    	nTT2017AB := D_BAIXADO->VLRORI

        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()))) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "3"
	    	nTTAtualAB := D_BAIXADO->VLRORI

	    //Abertos - outros.
		Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 5 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
			nOR2013AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 4 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
	    	nOR2014AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 3 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
	    	nOR2015AB := D_BAIXADO->VLRORI
	    
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 2 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
	    	nOR2016AB := D_BAIXADO->VLRORI
	    	
	    Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()) - 1 )) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
	    	nOR2017AB := D_BAIXADO->VLRORI

        //Everson - 17/10/2019- Chamado 052531.
        Case Alltrim(cValToChar(D_BAIXADO->ANO)) = Alltrim(cValToChar( Year(Date()))) .And. Alltrim(cValToChar(D_BAIXADO->FLAG)) = "4"
            nORAtualAB := D_BAIXADO->VLRORI
            
    	EndCase
    	    		
		D_BAIXADO->(DbSkip())
		
	End
	
	D_BAIXADO->(DbCloseArea())
	
	cMsg += "<tr height='20' style='height:15.0pt'>
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>FATURAMENTO</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2014FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2015FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2016FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2017FT , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nTT2018FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTTAtualFT , "@E 9,999,999,999" )+"</td>"  //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013FT+nTT2014FT+nTT2015FT+nTT2016FT+nTT2017FT+nTTAtualFT , "@E 999,999,999,999" )+"</td>"  //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>
	
	//
	cMsg += "<tr height='20' style='height:15.0pt'>
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>VENCIDOS +90 DIAS - EM ABERTO</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2014AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2015AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2016AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2017AB , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nTT2018AB , "@E 9,999,999,999" )+"</td>"

    cMsg += "<td class='style9' align='right'>"+Transform(nTTAtualAB , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013AB+nTT2014AB+nTT2015AB+nTT2016AB+nTT2017AB+nTTAtualAB , "@E 999,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>
    
    //
    cMsg += "<tr height='20' style='height:15.0pt'>
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>VENCIDOS +90 DIAS - BAIXADOS</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2014BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2015BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2016BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nTT2017BX , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nTT2018BX , "@E 9,999,999,999" )+"</td>"

    cMsg += "<td class='style9' align='right'>"+Transform(nTTAtualBX , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td class='style9' align='right'>"+Transform(nTT2013BX+nTT2014BX+nTT2015BX+nTT2016BX+nTT2017BX+nTTAtualBX , "@E 999,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>
    
    
    cMsg += "<tr height='20' style='height:15.0pt'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style3' align='right'>% INDICE PDD</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nTT2013BX+nTT2013AB)/nTT2013FT)*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nTT2014BX+nTT2014AB)/nTT2014FT)*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nTT2015BX+nTT2015AB)/nTT2015FT)*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nTT2016BX+nTT2016AB)/nTT2016FT)*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nTT2017BX+nTT2017AB)/nTT2017FT)*100 , "@E 999.9999" ) + "%</td>"

    cMsg += "<td align='right' class='style3'>" + Transform( ((nTTAtualBX+nTTAtualAB)/nTTAtualFT)*100 , "@E 999.9999" ) + "%</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td align='right' class='style3'>" + Transform( (((nTT2013BX+nTT2014BX+nTT2015BX+nTT2016BX+nTT2017BX+nTTAtualBX)+(nTT2013AB+nTT2014AB+nTT2015AB+nTT2016AB+nTT2017AB+nTTAtualAB))/(nTT2013FT+nTT2014FT+nTT2015FT+nTT2016FT+nTT2017FT+nTTAtualFT))*100 , "@E 999.9999" ) + "%</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>"
    cMsg += "<tr height='6' style='mso-height-source:userset;height:4.5pt'>"
    cMsg += "								<td height='6' style='height:4.5pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "</tr>"
    
    
    cMsg += "<tr height='20' style='height:15.0pt' class='style2'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>OUTROS RECEBIMENTOS</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2013FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2014FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2015FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2016FT , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2017FT , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nOR2018FT , "@E 9,999,999,999" )+"</td>"

    cMsg += "<td class='style9' align='right'>"+Transform(nORAtualFT , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td align='right' class='style9'>"+Transform(nOR2013FT+nOR2014FT+nOR2015FT+nOR2016FT+nOR2017FT+nORAtualFT, "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>"
    
    
    cMsg += "<tr height='20' style='height:15.0pt'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>VENCIDOS +90 DIAS - EM ABERTO</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2013AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2014AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2015AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2016AB , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2017AB , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nOR2018AB , "@E 9,999,999,999" )+"</td>"

    cMsg += "<td class='style9' align='right'>"+Transform(nORAtualAB , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td align='right' class='style9'>"+Transform(nOR2013AB+nOR2014AB+nOR2015AB+nOR2016AB+nOR2017AB+nORAtualAB , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>"
    
    
    cMsg += "<tr height='20' style='height:15.0pt'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style7'>VENCIDOS +90 DIAS - BAIXADOS</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2013BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2014BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2015BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2016BX , "@E 9,999,999,999" )+"</td>"
    cMsg += "<td class='style9' align='right'>"+Transform(nOR2017BX , "@E 9,999,999,999" )+"</td>"
    //cMsg += "<td class='style9' align='right'>"+Transform(nOR2018BX , "@E 9,999,999,999" )+"</td>"

    cMsg += "<td class='style9' align='right'>"+Transform(nORAtualBX , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td align='right' class='style9'>"+Transform(nOR2013BX+nOR2014BX+nOR2015BX+nOR2016BX+nOR2017BX+nORAtualBX , "@E 9,999,999,999" )+"</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>"
    
    //
    cMsg += "<tr height='20' style='height:15.0pt'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style3' align='right'>% INDICE PDD</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nOR2013AB+nOR2013BX)/nOR2013FT)*100 , "@E 999.9999" ) + "</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nOR2014AB+nOR2014BX)/nOR2014FT)*100 , "@E 999.9999" ) + "</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nOR2015AB+nOR2015BX)/nOR2015FT)*100 , "@E 999.9999" ) + "</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nOR2016AB+nOR2016BX)/nOR2016FT)*100 , "@E 999.9999" ) + "</td>"
    cMsg += "<td align='right' class='style3'>" + Transform( ((nOR2017AB+nOR2017BX)/nOR2017FT)*100 , "@E 999.9999" ) + "</td>"

    cMsg += "<td align='right' class='style3'>" + Transform( ((nORAtualAB+nORAtualBX)/nORAtualFT)*100 , "@E 999.9999" ) + "</td>" //Everson - 17/10/2019- Chamado 052531.

    cMsg += "<td align='right' class='style3'>" + Transform( (((nOR2013AB+nOR2014AB+nOR2015AB+nOR2016AB+nOR2017AB+nORAtualAB)+(nOR2013BX+nOR2014BX+nOR2015BX+nOR2016BX+nOR2017BX+nORAtualBX))/(nOR2013FT+nOR2014FT+nOR2015FT+nOR2016FT+nOR2017FT+nORAtualFT))*100 , "@E 999.9999" ) + "</td>" //Everson - 17/10/2019- Chamado 052531.
    cMsg += "</tr>"
    cMsg += "<tr height='6' style='mso-height-source:userset;height:4.5pt'>"
    cMsg += "								<td height='6' style='height:4.5pt'></td>
    cMsg += "								<td></td>
    cMsg += "								<td></td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "								<td>&nbsp;</td>
    cMsg += "</tr>"
    cMsg += "<tr height='20' style='height:15.0pt' class='style2'>"
    cMsg += "<td colspan='3' height='20' style='height: 15.0pt' class='style1' align='right'>% INDICE PDD - EMPRESA</td>"
    cMsg += "<td class='style2'>&nbsp;</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTT2013BX+nTT2013AB+nOR2013AB+nOR2013BX)/(nOR2013FT+nTT2013FT))*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTT2014BX+nTT2014AB+nOR2014AB+nOR2014BX)/(nOR2014FT+nTT2014FT))*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTT2015BX+nTT2015AB+nOR2015AB+nOR2015BX)/(nOR2015FT+nTT2015FT))*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTT2016BX+nTT2016AB+nOR2016AB+nOR2016BX)/(nOR2016FT+nTT2016FT))*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTT2017BX+nTT2017AB+nOR2017AB+nOR2017BX)/(nOR2017FT+nTT2017FT))*100 , "@E 999.9999" ) + "%</td>"
    cMsg += "<td align='right' class='style1'>" + Transform( ((nTTAtualBX+nTTAtualAB+nORAtualAB+nORAtualBX)/(nORAtualFT+nTTAtualFT))*100 , "@E 999.9999" ) + "%</td>" //Everson - 17/10/2019- Chamado 052531.

    nBxABGr := ((nOR2013AB+nOR2014AB+nOR2015AB+nOR2016AB+nOR2017AB+nORAtualAB)+(nOR2013BX+nOR2014BX+nOR2015BX+nOR2016BX+nOR2017BX+nORAtualBX)) + ((nTT2013BX+nTT2014BX+nTT2015BX+nTT2016BX+nTT2017BX+nTTAtualBX)+(nTT2013AB+nTT2014AB+nTT2015AB+nTT2016AB+nTT2017AB+nTTAtualAB)) //Everson - 17/10/2019- Chamado 052531.
    nFatGr  := (nOR2013FT+nOR2014FT+nOR2015FT+nOR2016FT+nOR2017FT+nORAtualFT)+(nTT2013FT+nTT2014FT+nTT2015FT+nTT2016FT+nTT2017FT+nTTAtualFT) //Everson - 17/10/2019- Chamado 052531.
    
    cMsg += "<td align='right' class='style1'>" + Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" ) + "%</td>
    
    //Everson - 17/01/2019. Chamado 044743.
    DbSelectArea("SX5")
    SX5->(DbSetOrder(1))
    SX5->(DbGoTop())
    If SX5->( DbSeek( "02Z*" + Right(DToS(Date()),6) ) )
    	
    	Conout("ADCOM020P - ADCO020I - DbSeek true " + Right(DToS(Date()),6) )
    	RecLock("SX5",.F.)
    		SX5->X5_DESCRI  := Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    		SX5->X5_DESCENG := Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    		SX5->X5_DESCSPA	:= Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    	MsUnlock()
    	
    Else
    	
    	Conout("ADCOM020P - ADCO020I - DbSeek false " + Right(DToS(Date()),6) )
    	RecLock("SX5",.T.)
    		SX5->X5_FILIAL	:= "02"
    		SX5->X5_TABELA	:= "Z*"
    		SX5->X5_CHAVE	:= Right(DToS(Date()),6)
    		SX5->X5_DESCRI  := Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    		SX5->X5_DESCENG := Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    		SX5->X5_DESCSPA	:= Transform( (nBxABGr/nFatGr)*100 , "@E 999.9999" )
    	MsUnlock()    	
    
    EndIf
    
    cMsg += "</tr> "
    cMsg += "<tr height='6' style='mso-height-source:userset;height:4.5pt'> "
    cMsg += "<td height='6' style='height:4.5pt'></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "</tr> "
    cMsg += "<tr height='20' style='height:15.0pt'> "
    cMsg += "<td height='20' style='height:15.0pt'></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "</tr> "
    cMsg += "<tr height='36' style='mso-height-source:userset;height:27.0pt'> "
    cMsg += "<td colspan='8' style='height: 15.75pt' height='21'  class='style3'>INADIMPLÊNCIA DE CLIENTES - TOP 20 (ÚLTIMOS 12 MESES)</td> " //Everson - 28/07/2020. Chamado 058854.
    cMsg += "<td></td> "
    cMsg += "<td colspan='2' style='height: 15.75pt' height='21'  class='style3'>HISTÓRICO</td> "
    cMsg += "</tr> "
    cMsg += "<tr height='5' style='mso-height-source: userset; height: 3.75pt'> "
    cMsg += "<td height='5' style='height: 3.75pt'></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "<td></td> "
    cMsg += "</tr> "
    cMsg += "<tr height='20' style='height: 15.0pt'> "
    cMsg += "<td height='20' style='height: 15.0pt' class='style15'>ITEM</td> "
    cMsg += "<td height='20' style='height: 15.0pt' class='style15'>EMPRESA</td> " //Everson - 28/07/2020. Chamado 058854.
    cMsg += "<td class='style15' align='center'>CLIENTE</td> "
    cMsg += "<td colspan='2' class='style16' align='center'>REDE</td> "
    cMsg += "<td class='style15' align='center'>VALOR</td> "
    cMsg += "<td class='style15' align='center'>%TT</td> "
    cMsg += "<td class='style15' align='center'>% ACUM</td> "
    cMsg += "<td></td> "
    cMsg += "<td class='style15' align='center'>DATA</td> "
    cMsg += "<td class='style15' align='center'>% INADIMPL</td> "
    cMsg += "</tr> "

    //
    cQuery := ""
    cQuery += " SELECT " 
	cQuery += " SUM(BASE.VLRPDD) AS VLRPDD "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += titRecPDD(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
	cQuery += " ) AS BASE "
	cQuery += " WHERE " 
	cQuery += " BASE.TIPDOC " 
	cQuery += " NOT IN ('RA','NCC','AB-','NDC') " //Everson - 29/07/2020. Chamado 059641. 
	cQuery += " AND CAST(BASE.DTVENR AS DATE) > CAST(DATEADD(day, -365, GETDATE()) AS DATE) "

    //
    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
 	    
    EndIf	
    
    TcQuery cQuery New Alias "ADCOMT020"
    DbSelectArea("ADCOMT020")
    ADCOMT020->(DbGoTop())
    nTTgTop20 := ADCOMT020->VLRPDD
    ADCOMT020->(DbCloseArea())
        
    //
    cQuery := ""
    cQuery += " SELECT BASE.EMP, " //Everson - 28/07/2020. Chamado 058854.
	cQuery += " CASE WHEN BASE.CODREDCHK IS NULL OR BASE.CODREDCHK = '' THEN " 
	cQuery += " BASE.CODRED "
	cQuery += " ELSE "
	cQuery += " ISNULL((SELECT TOP 1 ZF_NOMERED FROM " + RetSqlName("SZF") + " (NOLOCK) AS SZF WHERE SZF.D_E_L_E_T_ = '' AND SZF.ZF_REDE = CODREDCHK ORDER BY SZF.ZF_LCREDE DESC),'') END AS NOME, "
	cQuery += " ISNULL(BASE.CODREDCHK,'') AS CODRED, "
	cQuery += " BASE.CODRED AS CODRED2, ROUND(SUM(BASE.VLRPDD),0) AS VLRPDD "
	cQuery += " FROM "
	cQuery += " ( "
	
	cQuery += titRecPDD(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
	cQuery += " ) AS BASE "
	cQuery += " WHERE " 
	cQuery += " BASE.TIPDOC " 
	cQuery += " NOT IN ('RA','NCC','AB-','NDC') " //Everson - 29/07/2020. Chamado 059641. 
	cQuery += " AND CAST(BASE.DTVENR AS DATE) > CAST(DATEADD(day, -365, GETDATE()) AS DATE) "
	cQuery += " GROUP BY BASE.EMP, BASE.CODRED, BASE.CODREDCHK " //Everson - 28/07/2020. Chamado 058854.
	cQuery += " ORDER BY VLRPDD DESC "

    //
    If Select("ADCOMT020") > 0
 	    ADCOMT020->(DbCloseArea())
 	    
    EndIf	
    	
    //
    TcQuery cQuery New Alias "ADCOMT020"
    DbSelectArea("ADCOMT020")
    ADCOMT020->(DbGoTop())
    
    cQueryPDD := " SELECT TOP 20 '20' + X5_CHAVE AS DATA, X5_DESCRI AS VALOR FROM " + RetSqlName("SX5") + " AS SX5 WHERE X5_FILIAL = '02' AND X5_TABELA = 'Z*' ORDER BY X5_CHAVE DESC "

    //
    If Select("PDD") > 0
 	    PDD->(DbCloseArea())
 	    
    EndIf	
    	
    //
    TcQuery cQueryPDD New Alias "PDD"
    DbSelectArea("PDD")
    PDD->(DbGoTop())
            
    //
    While ! ADCOMT020->(Eof()) .Or. ! PDD->(Eof())
    	
    	cMsg += "<tr height='20' style='height: 15.0pt'> "
    	
    	If ! ADCOMT020->(Eof()) //Everson - 17/01/2019. Chamado 044743.

	        nItinco++
	        nTTpert20 := Round( (ADCOMT020->VLRPDD/nTTgTop20)*100,2)
	        nTTgAcm20 += nTTpert20
	        
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItinco <= 20," bgcolor='#fabf8f' ","") + " >"+Alltrim(Str(nItinco))+"</td> "
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18' " + Iif(nItinco <= 20," bgcolor='#fabf8f' ","") + " >"+Alltrim(ADCOMT020->EMP)+"</td> "
	        
            cMsg += "<td class='style8' align='left'>"+ ADCOMT020->NOME +"</td> "
	        cMsg += "<td colspan='2' class='style18' align='left'>"+ ADCOMT020->CODRED +"</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( ADCOMT020->VLRPDD , "@E 999,999,999" ) +"</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( nTTpert20 , "@E 999.99" ) +" %</td> "
	        cMsg += "<td class='style8' align='right'>"+ Transform( nTTgAcm20 , "@E 999.99" ) +" %</td> "
	        
	        ADCOMT020->(DbSkip())
        
        Else 
        
	        cMsg += "<td height='20' style='height: 15.0pt;' class='style18'></td> "
	        cMsg += "<td class='style8' align='left'></td> "
	        cMsg += "<td colspan='2' class='style18' align='left'></td> "
	        cMsg += "<td class='style8' align='right'></td> "
	        cMsg += "<td class='style8' align='right'></td> "
	        cMsg += "<td class='style8' align='right'></td> "       
        
        EndIf
        
        //
        If ! PDD->(Eof()) //Everson - 17/01/2019. Chamado 044743.
	        cMsg += "<td></td>
	        cMsg += "<td class='style8'>" + DToC(SToD(PDD->DATA)) + "</td> "
	        cMsg += "<td class='style8'>" + cValToChar(Alltrim(PDD->VALOR)) + "</td> "
	        
	        PDD->(DbSkip())
	                
        Else
	        cMsg += "<td></td>
	        cMsg += "<td class='style8'>&nbsp;</td> "
	        cMsg += "<td class='style8'>&nbsp;</td> "
        
        EndIf
        
        cMsg += "</tr>

    End
    
    ADCOMT020->(DbCloseArea())
    cMsg += "</table>

Return cMsg
/*/{Protheus.doc} scriptFatu
    Script base de faturamento.
    @type  Static Function
    @author Everson
    @since 10/08/2018
    @version 01
    /*/
Static Function scriptFatu(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cQuery := ""
	Local cVndExp:= "000800"
    Local nAux   := 1 //Everson - 29/07/2020. Chamado 058854.
	
    //Everson - 29/07/2020. Chamado 058854.
    For nAux := 1 To Len(aEmp)

        //
        cQuery += " SELECT  " 
        cQuery += " E1_FILIAL,  " 
        cQuery += " E1_CLIENTE,  " 
        cQuery += " E1_LOJA,  " 
        cQuery += " E1_PREFIXO,  " 
        cQuery += " E1_TIPO,  " 
        cQuery += " E1_NUM,  " 
        cQuery += " E1_PARCELA,  " 
        cQuery += " E1_EMISSAO,  " 
        cQuery += " E1_VENCTO,  " 
        cQuery += " E1_VENCREA,  " 
        cQuery += " CASE WHEN E1_TIPO = 'NCC' THEN E1_VALOR*-1 ELSE E1_VALOR END AS E1_VALOR,  " 
        cQuery += " A1_COD, A1_NOME, A1_NREDUZ, A1_CGC, LEFT(A1_CGC,8) AS CNPJ_RAIZ, A1_VEND, A1_COND,  " 
        cQuery += " E1_BASCOM1, E1_MOEDA, E1_TXMOEDA, " 
        cQuery += " CASE WHEN E1_TIPO = 'NCC' THEN (CASE WHEN E1_MOEDA = '2' OR E1_VEND1 = '" + cVndExp + "' THEN E1_BASCOM1 ELSE E1_VALOR END)*-1  " 
        cQuery += " ELSE (CASE WHEN E1_MOEDA = '2' OR E1_VEND1 = '" + cVndExp + "' THEN E1_BASCOM1 ELSE E1_VALOR END) END AS VLRORI, " 
        cQuery += " YEAR(E1_EMISSAO) AS ANO " 
        cQuery += " FROM  " 
        cQuery += " SE1" + aEmp[nAux][1] + "0 (NOLOCK) AS SE1 " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " INNER JOIN " 
        cQuery += " SA1" + aEmp[nAux][1] + "0 (NOLOCK) CAD "  //Everson - 29/07/2020. Chamado 058854.
        cQuery += " ON " 
        cQuery += " CAD.A1_COD = SE1.E1_CLIENTE  " 
        cQuery += " AND CAD.A1_LOJA = SE1.E1_LOJA  " 
        cQuery += " WHERE  " 
        cQuery += " E1_PREFIXO NOT IN ('EEC','NDC')  " //Everson - 29/07/2020. Chamado 059641.
        cQuery += " AND SE1.D_E_L_E_T_ = ''  " 
        cQuery += " AND SE1.E1_EMISSAO >=  CAST(YEAR(GETDATE())-5 AS VARCHAR) + '0101' " 
        cQuery += " AND SE1.E1_EMISSAO <=  CAST(YEAR(GETDATE()) AS VARCHAR) + '1231' " 
        cQuery += " AND CAD.D_E_L_E_T_ = '' "

        //Everson - 29/07/2020. Chamado 058854.
        If nAux < Len(aEmp)
           cQuery += " UNION ALL "

        EndIf 

    Next nAux
	
Return cQuery
/*/{Protheus.doc} titRecPDD
    Script com títulos pdd. TITULOSRECPDD.  
    @type  Static Function
    @author Everson
    @since 10/08/2018
    @version 01
    /*/
Static Function titRecPDD(aEmp) //Everson - 29/07/2020. Chamado 058854.
	
    //Variáveis.
	Local cQuery := ""
    Local nAux   := 1 //Everson - 29/07/2020. Chamado 058854.
	
	//
    For nAux := 1 To Len(aEmp) //Everson - 29/07/2020. Chamado 058854.

        //
        cQuery += " SELECT '" + aEmp[nAux][1] + " " + aEmp[nAux][2] + "' AS EMP, " //Everson - 28/07/2020. Chamado 058854.
        cQuery += " CADREDE.CODRED AS CODREDCHK , CASE WHEN CADREDE.CODRED IS NULL THEN CADCLIENTE.RZSOCI ELSE CADREDE.CODRED END AS CODRED, " 
        cQuery += " CADCLIENTE.CNPJRA, CADCLIENTE.RZSOCI AS NMCLIE, CADCLIENTE.VENDED, " 
        cQuery += " TITULOSRECPDD.* " 
        cQuery += " FROM " 
        cQuery += " ( " 
        cQuery += "  " 
        cQuery += " SELECT  " 
        cQuery += " REC.E1_CLIENTE AS CODCLI,  " 
        cQuery += " REC.E1_LOJA    AS LOJACL,  " 
        cQuery += " REC.E1_EMISSAO AS DTEMIS,  " 
        cQuery += " REC.E1_VENCTO  AS DTVENC,  " 
        cQuery += " REC.E1_VENCREA AS DTVENR,  " 
        cQuery += " REC.E1_VALOR   AS VLRTIT,  " 
        cQuery += " REC.E1_SALDO   AS SLDTIT,  " 
        cQuery += " BXA.E5_DATA    AS DTAPDD,  " 
        cQuery += " CASE WHEN BXA.E5_RECPAG = 'P' THEN BXA.E5_VALOR*-1 ELSE BXA.E5_VALOR END AS VLRPDD,  "  
        cQuery += " REC.E1_TIPO    AS TIPDOC,  " 
        cQuery += " '1'            AS FLAGSI " 
        cQuery += " FROM  " 
        cQuery += " SE5" + aEmp[nAux][1] + "0 (NOLOCK) AS BXA  " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " LEFT JOIN  " 
        cQuery += " SE1" + aEmp[nAux][1] + "0 (NOLOCK) AS REC ON  " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " REC.E1_FILIAL = BXA.E5_FILIAL  " 
        cQuery += " AND REC.E1_NUM = BXA.E5_NUMERO  " 
        cQuery += " AND REC.E1_PREFIXO = BXA.E5_PREFIXO  " 
        cQuery += " AND REC.E1_CLIENTE = BXA.E5_CLIFOR " 
        cQuery += " AND REC.E1_LOJA = BXA.E5_LOJA  " 
        cQuery += " AND REC.E1_PARCELA = BXA.E5_PARCELA  " 
        cQuery += " AND REC.E1_TIPO = BXA.E5_TIPO "
        cQuery += " AND REC.D_E_L_E_T_ <> '*' " 
        cQuery += " WHERE  " 
        cQuery += " (BXA.E5_BANCO='P99')  " 
        cQuery += " AND (BXA.D_E_L_E_T_ <> '*')  " 
        cQuery += " AND (BXA.E5_DATA >= CAST(YEAR(GETDATE())-5 AS VARCHAR) + '0101') " 
        cQuery += " UNION ALL " 
        cQuery += " SELECT  " 
        cQuery += " REC.E1_CLIENTE,  " 
        cQuery += " REC.E1_LOJA,  " 
        cQuery += " REC.E1_EMISSAO, " 
        cQuery += " REC.E1_VENCTO, " 
        cQuery += " REC.E1_VENCREA, " 
        cQuery += " REC.E1_VALOR,  " 
        cQuery += " REC.E1_SALDO,  " 
        cQuery += " '', " 
        cQuery += " E1_SALDO, " 
        cQuery += " E1_TIPO,  " 
        cQuery += " '2' " 
        cQuery += " FROM  " 
        cQuery += " SE1" + aEmp[nAux][1] + "0 (NOLOCK) REC " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHERE  " 
        cQuery += " REC.E1_VENCREA < (GETDATE()-90)  " 
        cQuery += " AND REC.E1_SALDO > 0  " 
        cQuery += " AND REC.D_E_L_E_T_ = ''  " 
        cQuery += " AND REC.E1_TIPO  " 
        cQuery += " NOT IN ('NCC','RA','NDC') " //Everson - 29/07/2020. Chamado 059641. 
        cQuery += "  " 
        cQuery += " )AS TITULOSRECPDD " 
        cQuery += " INNER JOIN   " 
        cQuery += " (   " 
        cQuery += " SELECT    " 
        cQuery += " A1_COD    AS CODCLI,    " 
        cQuery += " A1_LOJA   AS LOJACLI,    " 
        cQuery += " LEFT(RTRIM(LTRIM(A1_CGC)),8) AS CNPJRA,   " 
        cQuery += " A1_NOME   AS RZSOCI,    " 
        cQuery += " A1_VEND   AS VENDED,     " 
        cQuery += " '.'       AS CODREDE,   " 
        cQuery += " A1_BCO1   AS PORTAD   " 
        cQuery += " FROM    " 
        cQuery += " SA1" + aEmp[nAux][1] + "0  (NOLOCK) AS SA1 " //Everson - 29/07/2020. Chamado 058854.
        cQuery += " WHERE    " 
        cQuery += " SA1.D_E_L_E_T_ = ''   " 
        cQuery += " ) AS CADCLIENTE ON   " 
        cQuery += " TITULOSRECPDD.CODCLI = CADCLIENTE.CODCLI   " 
        cQuery += " AND TITULOSRECPDD.LOJACL = CADCLIENTE.LOJACLI   " 
        cQuery += " LEFT OUTER JOIN   " 
        cQuery += " (   " 
        cQuery += " SELECT   " 
        cQuery += " ZF_CGCMAT AS CNPJRD,    " 
        cQuery += " ZF_REDE   AS CODRED     " 
        cQuery += " FROM    " 

        //Everson - 29/07/2020. Chamado 058854.
        If aEmp[nAux][1] == "02"
            cQuery += " SZF010 (NOLOCK) AS SZF  "

        Else 
            cQuery += " SZF" + aEmp[nAux][1] + "0 (NOLOCK) AS SZF  "

        EndIf 

        //
        cQuery += " WHERE    " 
        cQuery += " SZF.D_E_L_E_T_ =''   " 
        cQuery += " ) AS CADREDE ON   " 
        cQuery += " CADCLIENTE.CNPJRA = CADREDE.CNPJRD   " 

        //
        If nAux < Len(aEmp) //Everson - 29/07/2020. Chamado 058854.
            cQuery += " UNION ALL "

        EndIf

    Next nAux
	
Return cQuery
/*/{Protheus.doc} envEmail
    Envia e-mail. 
    @type  Static Function
    @author Everson
    @since 28/06/2018
    @version 01
    /*/
Static Function envEmail(cAssunto,cMsg,cDestWFgas,cCopDeswf,cArq)
	
    //Variáveis.
	Local aArea			 := GetArea()
	Local lOk           := .T.
	Local cErrorMsg     := ""
	Local cServer       := Alltrim(GetMv("MV_RELSERV"))
	Local cAccount      := AllTrim(GetMv("MV_RELACNT"))
	Local cPassword     := AllTrim(GetMv("MV_RELPSW"))
	Local lSmtpAuth     := GetMv("MV_RELAUTH",,.F.)
	Local lAutOk        := .F.  
		
	Local cFrom         := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
	Local cSubject      := cAssunto
	Local cTo           := cDestWFgas
	Local cCopia		:= cCopDeswf
	Local cBody         := cMsg
	Local cAtach		:= cArq

	//Conecta ao servidor SMTP.
	Connect Smtp Server cServer Account cAccount  Password cPassword Result lOk
	
	If !lAutOk
	   If ( lSmtpAuth )
	      lAutOk := MailAuth(cAccount,cPassword)
	      
	   Else
	      lAutOk := .T.
	      
	   EndIf
	   
	EndIf
	
	If lOk .And. lAutOk   
	   
	   //Envia o e-mail.     
	   Send Mail From cFrom To cTo CC cCopia Subject cSubject Body cBody ATTACHMENT cAtach Result lOk  
	    
	   //Tratamento de erro no envio do e-mail.          
	   If !lOk
	      Get Mail Error cErrorMsg
	      ConOut("Não foi possível enviar o e-mail ao comprador. 3 - " + cErrorMsg)
	      
	   EndIf
	   
	Else
	   Get Mail Error cErrorMsg
	   ConOut("Não foi possível enviar o e-mail ao comprador. 4 - " + cErrorMsg)
	  
	EndIf
	
	If lOk
	   Disconnect Smtp Server
	   
	EndIf
	
	RestArea(aArea)
	
Return Nil
/*/{Protheus.doc} User Function ADCOWFCA
    Execucao de Agendamento de Workflow.
    @type  Function
    @author Ricardo Lima
    @since 02/05/2018
    @version 01
    /*/
User Function ADCOWFCA(ZCJDESWFK)

    //Variáveis.
    Local cMsgEnv := ""
    Local cQuery  := ""
    Local sNivBlq  := ""
    Local cAssunto := "Central de Aprovação - Pendencias de Aprovação"
    Local lEnvWkf  := .F.

    U_ADINF009P('ADCOM020P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    ZCJDESWFK := Alltrim( Substr( ZCJDESWFK,Len(ZCJDESWFK)-2,len(ZCJDESWFK) ) )
    if ZCJDESWFK = '01'
        sNivBlq := ""
    Else
        sNivBlq := ZCJDESWFK
    EndIf

    cQuery := " SELECT * "
    cQuery += " FROM "+RetSqlName("ZC7")+" ZC7 "
    cQuery += " WHERE ZC7_USRAPR = ' ' AND ZC7_TPBLQ <> '000003' AND ZC7_NIVEL = '"+sNivBlq+"' "
    cQuery += " AND ZC7.D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY ZC7_FILIAL, ZC7_TPBLQ "
    If Select("ADCOWFCA") > 0
    	ADCOWFCA->(DbCloseArea())
    EndIf	
    TcQuery cQuery New Alias "ADCOWFCA"

    cMsgEnv := U_WFADCO020( '1', ADCOWFCA->ZC7_FILIAL , ADCOWFCA->ZC7_PREFIX , ADCOWFCA->ZC7_NUM , ADCOWFCA->ZC7_PARCEL , ADCOWFCA->ZC7_CLIFOR , ADCOWFCA->ZC7_LOJA , ADCOWFCA->ZC7_VLRBLQ , ADCOWFCA->ZC7_DSCBLQ , ADCOWFCA->ZC7_RECPAG )
    While ADCOWFCA->( !EOF() )  
            cMsgEnv += U_WFADCO020( '2', ADCOWFCA->ZC7_FILIAL , ADCOWFCA->ZC7_PREFIX , ADCOWFCA->ZC7_NUM , ADCOWFCA->ZC7_PARCEL , ADCOWFCA->ZC7_CLIFOR , ADCOWFCA->ZC7_LOJA , ADCOWFCA->ZC7_VLRBLQ , ADCOWFCA->ZC7_DSCBLQ , ADCOWFCA->ZC7_RECPAG )
            lEnvWkf  := .T.
        ADCOWFCA->(DbSkip())
    End
    cMsgEnv += U_WFADCO020( '3', ADCOWFCA->ZC7_FILIAL , ADCOWFCA->ZC7_PREFIX , ADCOWFCA->ZC7_NUM , ADCOWFCA->ZC7_PARCEL , ADCOWFCA->ZC7_CLIFOR , ADCOWFCA->ZC7_LOJA , ADCOWFCA->ZC7_VLRBLQ , ADCOWFCA->ZC7_DSCBLQ , ADCOWFCA->ZC7_RECPAG )

    c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
    c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
    c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
    c2Query += " WHERE ZCF_NIVEL = '"+sNivBlq+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
    c2Query += " ORDER BY ZCF_NIVEL "
    If Select("ADCOPACA") > 0
        ADCOPACA->(DbCloseArea())		
    EndIf
    TcQuery c2Query New Alias "ADCOPACA"

    cDestWFgas := AllTrim(UsrRetMail( ADCOPACA->ZC3_CODUSU ))
    cCopDeswf  := ""
    if lEnvWkf
        IF !EMPTY(cDestWFgas)
            U_F50En2WF(cDestWFgas , cCopDeswf , cAssunto , cMsgEnv , '' )
        ENDIF
    endif

Return
/*/{Protheus.doc} User Function WFADCO020
    Central de Aprovacao. Chamado 038609.
    @type  Function
    @author Ricardo Lima
    @since 14/11/2017
    @version 01
    /*/
User Function WFADCO020( OPC , FilialSE2 , E2PREFIXO , E2NUM , E2PARCELA , E2FORNECE , E2LOJA , E2VALOR , X5DESCRI , cTpbsc )

    //Variáveis.
    Local cMsg := ""
    local cNomFor := ""

    U_ADINF009P('ADCOM020P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    If OPC = '2'
        if cTpbsc = 'P'
            cNomFor := GetAdvFVal( "SA2", "A2_NOME", xFilial("SA2") + E2FORNECE + E2LOJA , 1, "" )
        else
            cNomFor := GetAdvFVal( "SA1", "A1_NOME", xFilial("SA1") + E2FORNECE + E2LOJA , 1, "" )
        endif
    EndIf

    If OPC = '1'
        cMsg := " <head> "
        cMsg += " <meta http-equiv='Content-Language' content='pt-br' /> "
        cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> "
        cMsg += " <title>Central de Aprovação</title> "
        cMsg += " <style type='text/css'> "
        cMsg += " .style1 { "
        cMsg += " 				font-family: 'Century Gothic'; "
        cMsg += " 				text-align: center; "
        cMsg += " 				text-decoration: underline; "
        cMsg += " 				font-size: x-large; "
        cMsg += " } "
        cMsg += " .style2 { "
        cMsg += " 				text-align: left; "
        cMsg += " 				font-family: 'Century Gothic'; "
        cMsg += " } "
        cMsg += " td "
        cMsg += " 	{border-style: none; "
        cMsg += " 				border-color: inherit; "
        cMsg += " 				border-width: medium; "
        cMsg += " 				padding-top:1px; "
        cMsg += " 					padding-right:1px; "
        cMsg += " 					padding-left:1px; "
        cMsg += " 					color:gray; "
        cMsg += " 					font-size:9.0pt; "
        cMsg += " 					font-weight:400; "
        cMsg += " 					font-style:normal; "
        cMsg += " 					text-decoration:none; "
        cMsg += " 					font-family:'Century Gothic', sans-serif; "
        cMsg += " 					text-align:general; "
        cMsg += " 					vertical-align:middle; "
        cMsg += " 					white-space:nowrap; "
        cMsg += " 	} "
        cMsg += " .style3 { "
        cMsg += " 				border-collapse: collapse; "
        cMsg += " 				margin-bottom: 0px; "
        cMsg += " } "
        cMsg += " .style4 { "
        cMsg += " 				font-family: 'Century Gothic'; "
        cMsg += " } "
        cMsg += " </style> "
        cMsg += " </head> "
        cMsg += " <body> "
        cMsg += " <p><img alt='ADORO' src='http://www.adoro.com.br/images/logo-adoro.png' style='float: left' /></p> "
        cMsg += " <p class='style1'><strong>Central de Aprovação</strong></p> "
        cMsg += " <p class='style2'>Caro Aprovador, Segue pendências na Central de Aprovação.</p> "
        cMsg += " <table border='0' cellpadding='0' cellspacing='0' width='1305' style='width: 979pt' class='style3'> "
        cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
        cMsg += " 								<td>Prefixo</td> "
        cMsg += " 								<td>Numero Titulo</td> "
        cMsg += " 								<td>Parcela</td> "
        cMsg += " 								<td>Fornecedor</td> "
        cMsg += " 								<td>Loja</td> "
        cMsg += " 								<td>Nome</td> "
        cMsg += " 								<td>Valor - R$</td> "
        cMsg += " 								<td>Tipo do Bloqueio</td> "
        cMsg += " 				</tr> "
    EndIf
    If OPC = '2'
        cMsg += " 				<tr height='24' style='mso-height-source: userset; height: 18.0pt'> "
        cMsg += " 								<td>"+ E2PREFIXO +"</td> "
        cMsg += " 								<td>"+ E2NUM +"</td> "
        cMsg += " 								<td>"+ E2PARCELA +"</td> "
        cMsg += " 								<td>"+ E2FORNECE +"</td> "
        cMsg += " 								<td>"+ E2LOJA  +"</td> "
        cMsg += " 								<td>"+ cNomFor +"</td> "
        cMsg += " 								<td>"+ Transform( E2VALOR , X3Picture( "E2_SALDO" ) ) +"</td> " 
        cMsg += " 								<td>"+ X5DESCRI +"</td> "
        cMsg += " 				</tr> "
    EndIf
    If OPC = '3'
        cMsg += " </table> "
        cMsg += " <p>&nbsp;</p> "
        cMsg += " <p class='style4'>Envio Automático - AD&#39;ORO ( Central de Aprovação )</p> "
        cMsg += " </body> "
        cMsg += " </html> "
    EndIf

Return( cMsg )
/*/{Protheus.doc} getIntCp
    Função retorna base CNPJ das intercompanies.
    @type  Static Function
    @author Everson
    @since 17/08/2020
    @version 01
    /*/
Static Function getIntCp()

//Ceres, Rineos, Folle, RNX2, Ceres Pro, Adoro, Safegg, CLML, Simplify.

Return "'02090384','03552786','07451656','12097672','13803055','60037058','20052541','03918104','15409315'"
