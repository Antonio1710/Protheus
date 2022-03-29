
#Include "Protheus.ch"
#include 'Fileio.ch'
#Include 'Totvs.ch'
#Include 'Restful.ch'
#Include 'Topconn.ch'
#include "rwmake.ch"
#include "TbiConn.ch"

// Variaveis estaticas
Static cRotina  := "ADFIN120P"

/*/{Protheus.doc} User Function ADFIN120P
    Função para gerar alçada de aprovação das despesas dos acordos trabalhistas
    @type  Function
    @author Fernando Macieira
    @since 27/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 18141 - RM - Acordos - Integração Protheus
    @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    @ticket 18141 - Fernando Macieira - 28/01/2022 - RM - Acordos - Tratativa para gerar central aprovação (ZC7) para despesas sem favorecido
    @ticket 18141 - Fernando Macieira - 10/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
    @ticket 18141 - Fernando Macieira - 14/03/2022 - RM - Acordos - Integração Protheus - Financeiro com favorecidos que nao foram vinculados na hora do cadastro
    @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
/*/
User Function ADFIN120P()

    Local cQuery      := ""
    Local lZCF01      := .f.
    Local cTpDespesa  := GetMV("MV_#RMDESP",,"10")

    // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
    Local cZHC_BANCO  := ""
    Local cZHC_AGENCI := ""
    Local cZHC_CONTA  := ""
    Local cZHC_DIGCTA := ""
    Local cZHC_FAVORE := ""
    Local cZHC_CPFCGC := ""

    Private lSigaOn := GetMV("MV_#RMSIGA",,.T.)
    Private aDadRM  := {}

    // @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    Private cLinked :=  GetMV("MV_#RMLINK",,"RM") // DEBUG - "LKD_PRT_RM" 
	Private cSGBD   :=  GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // DEBUG - "CCZERN_119205_RM_DE"

    // Garanto uma única thread sendo executada
    If !LockByName(cRotina, .T., .F.)
        ConOut( cRotina + " Rotina não executada pois existe outro processamento" )
        Return
    EndIf

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função para gerar alçada de aprovação das despesas dos acordos trabalhistas')

    lZCF01 := GetZCF()

    If lZCF01

        If Select("WorkRM") > 0
            WorkRM->( dbCloseArea() )
        EndIf

        If lSigaOn

            //cQuery := " SELECT ZHB_GERSE2 FLAG_SIGA, ZHB_FILIAL FILIAL_SIGA, '' PREFIXO_SIGA, '' NUM_SIGA, ZHB_PARCEL PARCELAS_SIGA, ZHC_BANCO BANCO_SIGA, ZHC_AGENCI AGENCIA_SIGA, '' DIGAGENCIA_SIGA, ZHC_CONTA CONTA_SIGA, ZHC_DIGCTA DIGCONTA_SIGA, ZHC_FAVORE BENEFICIARIO_SIGA, ZHC_CPFCGC CPF_CNPJ_SIGA, ZHB_VALOR VALOR, ZHB_VENCTO VENCTO_PARCELA1, 0 CODCOLIGADA, '' CODFORUM, ZHB_PROCES NUMPROCESSO, ZHB_ITEM, ZHB_TIPDES, ZHB_NOMDES
            //cQuery := " SELECT ZHB_GERSE2 FLAG_SIGA, ZHB_FILIAL FILIAL_SIGA, '' PREFIXO_SIGA, '' NUM_SIGA, ZHB_PARCEL PARCELAS_SIGA, ISNULL(ZHC_BANCO,'') BANCO_SIGA, ISNULL(ZHC_AGENCI,'') AGENCIA_SIGA, '' DIGAGENCIA_SIGA, ISNULL(ZHC_CONTA,'') CONTA_SIGA, ISNULL(ZHC_DIGCTA,'') DIGCONTA_SIGA, ISNULL(ZHC_FAVORE,'') BENEFICIARIO_SIGA, ISNULL(ZHC_CPFCGC,'') CPF_CNPJ_SIGA, ZHB_VALOR VALOR, ZHB_VENCTO VENCTO_PARCELA1, 0 CODCOLIGADA, '' CODFORUM, ZHB_PROCES NUMPROCESSO, ZHB_ITEM, ZHB_TIPDES, ZHB_NOMDES " // @ticket 18141 - Fernando Macieira - 28/01/2022 - RM - Acordos - Tratativa para gerar central aprovação (ZC7) para despesas sem favorecido
            cQuery := " SELECT ZHB_GERSE2 FLAG_SIGA, ZHB_FILIAL FILIAL_SIGA, '' PREFIXO_SIGA, '' NUM_SIGA, ZHB_PARCEL PARCELAS_SIGA, '' BANCO_SIGA, '' AGENCIA_SIGA, '' DIGAGENCIA_SIGA, '' CONTA_SIGA, '' DIGCONTA_SIGA, '' BENEFICIARIO_SIGA, '' CPF_CNPJ_SIGA, ZHB_VALOR VALOR, ZHB_VENCTO VENCTO_PARCELA1, 0 CODCOLIGADA, '' CODFORUM, ZHB_PROCES NUMPROCESSO, ZHB_ITEM, ZHB_TIPDES, ZHB_NOMDES, ZHB_FAVORE " // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
            cQuery += " FROM " + RetSqlName("ZHB") + " ZHB (NOLOCK)
            //cQuery += " INNER JOIN " + RetSqlName("ZHC") + " ZHC (NOLOCK) ON ZHC_FILIAL=ZHB_FILIAL AND ZHC_PROCES=ZHB_PROCES AND ZHC_TIPDES=ZHB_TIPDES AND ZHC.D_E_L_E_T_=''
            //cQuery += " LEFT JOIN " + RetSqlName("ZHC") + " ZHC (NOLOCK) ON ZHC_FILIAL=ZHB_FILIAL AND ZHC_PROCES=ZHB_PROCES AND ZHC_TIPDES=ZHB_TIPDES AND ZHC.D_E_L_E_T_='' " // @ticket 18141 - Fernando Macieira - 28/01/2022 - RM - Acordos - Tratativa para gerar central aprovação (ZC7) para despesas sem favorecido
            //cQuery += " LEFT JOIN " + RetSqlName("ZHC") + " ZHC (NOLOCK) ON ZHC_FILIAL=ZHB_FILIAL AND ZHC_PROCES=ZHB_PROCES AND ZHC_CODIGO=ZHB_FAVORE AND ZHC.D_E_L_E_T_='' " // @ticket 18141 - Fernando Macieira - 08/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
            cQuery += " WHERE ZHB_FILIAL='"+FWxFilial("ZHB")+"' 
            cQuery += " AND ZHB_APROVA='F'
            cQuery += " AND ZHB_GERSE2='F'
            cQuery += " AND ZHB.D_E_L_E_T_=''

        Else

            cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '
            cQuery += "	    SELECT FLAG_SIGA, FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA, PARCELAS_SIGA, BANCO_SIGA, AGENCIA_SIGA, DIGAGENCIA_SIGA, CONTA_SIGA, DIGCONTA_SIGA, BENEFICIARIO_SIGA, CPF_CNPJ_SIGA, VALOR, VENCTO_PARCELA1, A.CODCOLIGADA, A.CODFORUM, A.NUMPROCESSO, '' ZHB_ITEM, '' ZHB_TIPDES, '' ZHB_NOMDES, '' ZHB_FAVORE
            cQuery += "		FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL] A (NOLOCK)
            cQuery += "		INNER JOIN [" + cSGBD + "].[DBO].[VPROCESSOS] B (NOLOCK) ON A.CODCOLIGADA=B.CODCOLIGADA AND A.CODFORUM=B.CODFORUM AND A.NUMPROCESSO=B.NUMPROCESSO
            cQuery += "		INNER JOIN [" + cSGBD + "].[DBO].[VDESPESAPROCESSOS] C (NOLOCK) ON A.CODCOLIGADA=C.CODCOLIGADA AND A.CODFORUM=C.CODFORUM AND A.NUMPROCESSO=C.NUMPROCESSO AND C.CODTIPODESPESAS=''"+cTpDespesa+"''
            cQuery += "		WHERE (FLAG_SIGA IS NULL OR FLAG_SIGA <> ''T'') 
            cQuery += "		AND (PARCELAS_SIGA IS NOT NULL OR PARCELAS_SIGA > 0)
            cQuery += "		AND (NUM_SIGA IS NULL OR NUM_SIGA <> '''')
            cQuery += "		AND (VALOR IS NOT NULL OR VALOR > 0)
            cQuery += "		AND (VENCTO_PARCELA1 IS NULL OR VENCTO_PARCELA1 <> '''')
            cQuery += " ')

        EndIf

        tcQuery cQuery New Alias "WorkRM"

        aTamSX3 := TamSX3("ZHB_VALOR")
        tcSetField("WorkRM", "VALOR", aTamSX3[3], aTamSX3[1], aTamSX3[2])

        aTamSX3 := TamSX3("ZHB_VENCTO")
        tcSetField("WorkRM", "VENCTO_PARCELA1", aTamSX3[3], aTamSX3[1], aTamSX3[2])

        WorkRM->( dbGoTop() )
        Do While WorkRM->( !EOF() )

            // @ticket 18141 - Fernando Macieira - 14/03/2022 - RM - Acordos - Integração Protheus - Financeiro com favorecidos que nao foram vinculados na hora do cadastro
            cZHC_BANCO  := ""
            cZHC_AGENCI := ""
            cZHC_CONTA  := ""
            cZHC_DIGCTA := ""
            cZHC_FAVORE := ""
            cZHC_CPFCGC := ""

            // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
            ZHC->( dbSetOrder(2) ) // ZHC_FILIAL+ZHC_CODIGO // @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Remodelagem tabela ZHC e ZHD
            If ZHC->( dbSeek(FWxFilial("ZHC")+WorkRM->ZHB_FAVORE) )
                cZHC_BANCO  := ZHC->ZHC_BANCO
                cZHC_AGENCI := ZHC->ZHC_AGENCI
                cZHC_CONTA  := ZHC->ZHC_CONTA
                cZHC_DIGCTA := ZHC->ZHC_DIGCTA
                cZHC_FAVORE := ZHC->ZHC_FAVORE
                cZHC_CPFCGC := ZHC->ZHC_CPFCGC
            EndIf
            //

            aDadRM := {}
            aAdd( aDadRM, { WorkRM->PARCELAS_SIGA,;
                            WorkRM->VALOR,;
                            WorkRM->CODCOLIGADA,;
                            WorkRM->CODFORUM,;
                            WorkRM->NUMPROCESSO,;
                            WorkRM->VENCTO_PARCELA1,;
                            cZHC_BANCO,;
                            cZHC_AGENCI,;
                            WorkRM->DIGAGENCIA_SIGA,;
                            cZHC_CONTA,;
                            cZHC_DIGCTA,;
                            WorkRM->ZHB_ITEM,;
                            WorkRM->ZHB_TIPDES,;
                            WorkRM->ZHB_NOMDES,; 
                            cZHC_FAVORE,; 
                            cZHC_CPFCGC } )

            GeraZC7RM(aDadRM)

            WorkRM->( dbSkip() )

        EndDo

        If Select("WorkRM") > 0
            WorkRM->( dbCloseArea() )
        EndIf

    EndIf

    UnLockByName(cRotina)

Return /*aDadRM*/

/*/{Protheus.doc} Static Function GeraZC7RM()
    Gera Central Aprovação para títulos acordos trabalhistas
    @type  Static Function
    @author Fernando Macieira
    @since 27/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 11556 - Processo Trabalhista - Títulos
/*/
Static Function GeraZC7RM(aDadRM)

	Local aAreaAtu  := GetArea()
    Local cQuery    := ""
    Local cSQL      := ""
	Local cCodSX5   := "Z9"
	Local cCodBlq   := GetMV("MV_#ZC7RC1",,"000013")
	Local cDscBlq   := AllTrim(Posicione("SX5",1,xFilial("SX5")+cCodSX5+cCodBlq,"X5_DESCRI"))
    Local cCCusto   := GetMV("MV_#RMCCUS",,"2204") // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos

    // Email
    Local lEmail    := GetMV("MV_#ZC7EMA",,.F.)
    Local cAssunto	:= "[Acordo Trabalhista] - Central Aprovação"
	Local cMensagem	:= ""
	Local cmaildest := SuperGetMv( "MV_#ADCOM1" , .F. , "sistemas@adoro.com.br" ,  )

    // Dados necessários para central aprovação
    Local cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    Local cTipo     := GetMV("MV_#ZC7TIP",,"PR")
    Local cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    Local cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja     := GetMV("MV_#ZC7LOJ",,"01")
    
    // Dados enviados do RM via parâmetro
    Local cQtdParc  := AllTrim(Str(aDadRM[1,1]))
    Local nValor    := aDadRM[1,2]
    Local cColigada := AllTrim(Str(aDadRM[1,3]))
    Local cForum    := aDadRM[1,4]
    Local cProcesso := aDadRM[1,5]
    Local dVenctoP1 := aDadRM[1,6]

    Local cBanco    := aDadRM[1,7]
    Local cAgencia  := aDadRM[1,8]
    Local cDigAg    := aDadRM[1,9]
    Local cConta    := aDadRM[1,10]
    Local cDigCta   := aDadRM[1,11]

    Local cZHBItem  := aDadRM[1,12]
    Local cZHBTip   := aDadRM[1,13]
    Local cZHBDes   := aDadRM[1,14]

    Local cFavore   := aDadRM[1,15]
    Local cCPFCGC   := aDadRM[1,16]

    Local aDadPR    := {}
    Local cHist     := cAssunto + " - Processo " + AllTrim(cProcesso) + ", " + AllTrim(cZHBItem) + ", " + AllTrim(cZHBTip) + ", " + AllTrim(cCPFCGC)
    Local cSitAprov := ""

    Local lExisteP12:= .f.
    Local lExistSE2 := .f.
    Local lExistZHB := .f.
    Local cNumero   := GetSXENUM("RC1","RC1_NUMTIT")   //NextRC1()

    //cDscBlq := "Processo " + AllTrim(cProcesso) + AllTrim(cZHBItem) + AllTrim(cZHBTip) + AllTrim(Str(nValor)) + DtoC(dVenctoP1)
    cDscBlq := AllTrim(cProcesso) + AllTrim(cZHBItem) + AllTrim(cCPFCGC) + DtoC(dVenctoP1) + AllTrim(cQtdParc) + AllTrim(Str(nValor)) + AllTrim(cZHBTip) // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos

    lExisteP12 := ChkProcess(cDscBlq)
    
    If !lExisteP12

        nLoop := 0
        Do While .t.
            
            nLoop++

            ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
            If ZHB->( dbSeek(FWxFilial("ZHB")+cNumero))
                lExitZHB := .T.
                cNumero := Soma1(AllTrim(cNumero))
                dbSelectArea("RC1")
                ConfirmSX8()
            Else
                lExitZHB := .F.
                SE2->( dbSetOrder(6) ) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE2->( dbSeek(FWxFilial("SE2")+cFornece+cLoja+cPrefixo+cNumero/*+cQtdParc+cTipo*/))
                    lExitSE2 := .T.
                    cNumero := Soma1(AllTrim(cNumero))
                    dbSelectArea("RC1")
                    ConfirmSX8()
                Else
                    lExitSE2 := .F.
                    If !lExistZHB .and. !lExistSE2
                        Exit
                    EndIf
                EndIf
            EndIf
            
            If nLoop > 100
                Exit
            EndIf

        EndDo
    
        aDadPR := { { "E2_FILIAL" , FWxFilial("SE2") , NIL },;
                    { "E2_PREFIXO", cPrefixo         , NIL },;
                    { "E2_NUM"    , cNumero	    	 , NIL },;
                    { "E2_PARCELA", cQtdParc         , NIL },;
                    { "E2_TIPO"   , cTipo 		     , NIL },;
                    { "E2_NATUREZ", cNaturez		 , NIL },;
                    { "E2_FORNECE", cFornece 		 , NIL },;
                    { "E2_LOJA"   , cLoja 	    	 , NIL },;
                    { "E2_EMISSAO", msDate()         , NIL },;
                    { "E2_VENCTO" , dVenctoP1        , NIL },;
                    { "E2_VENCREA", dVenctoP1        , NIL },;
                    { "E2_VALOR"  , nValor           , NIL },;
                    { "E2_HIST"   , cHist            , NIL }}

        // gera registro para aprovacao		
        Begin Transaction 

            // Central Aprovação
            RecLock("ZC7",.T.)
            
                ZC7->ZC7_FILIAL := FwxFilial("ZC7")
                ZC7->ZC7_PREFIX	:= cPrefixo
                ZC7->ZC7_NUM   	:= cNumero
                ZC7->ZC7_PARCEL := cQtdParc
                ZC7->ZC7_TIPO   := cTipo
                ZC7->ZC7_CLIFOR	:= cFornece
                ZC7->ZC7_LOJA  	:= cLoja
                ZC7->ZC7_VLRBLQ	:= nValor
                ZC7->ZC7_TPBLQ 	:= cCodBlq
                ZC7->ZC7_DSCBLQ	:= cDscBlq
                ZC7->ZC7_RECPAG := "P"
                //ZC7->ZC7_NIVSEG := '03'
                ZC7->ZC7_USRALT := __cUserID
                ZC7->ZC7_OBS    := "Processo " + AllTrim(cProcesso) + " Forum " + AllTrim(cForum) + " Coligada " + AllTrim(cColigada)
                ZC7->ZC7_MSGSOL := "Processo " + AllTrim(cProcesso) + " Forum " + AllTrim(cForum) + " Coligada " + AllTrim(cColigada)

            ZC7->( msUnLock() )

            // Gera PR no Contas a Pagar
            lMsErroAuto := .f.
            dbSelectArea("SE2")
            msExecAuto( { |x,y| FINA050(x,y) }, aDadPR, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

            If lMsErroAuto

                DisarmTransaction()
                Break

            Else

                RecLock("SE2", .F.)

                    SE2->E2_ORIGEM  := "GPEM670" // Em função das customizações existentes
                    SE2->E2_XDIVERG := 'S'
                    SE2->E2_LOGDTHR	:= DtoC(msDate()) + ' ' + TIME()

                    // Banco
                    SE2->E2_BANCO := cBanco

                    // Agencia
                    SE2->E2_AGEN := cAgencia

                    // Dig Agencia
                    SE2->E2_DIGAG := cDigAg

                    // Conta
                    SE2->E2_NOCTA := cConta

                    // Dig Conta
                    SE2->E2_DIGCTA := cDigCta

                    // Favorecido
                    SE2->E2_NOMCTA := AllTrim(cFavore)
                    SE2->E2_CNPJ   := AllTrim(cCPFCGC)

                    // SBPL
                    SE2->E2_OBS_AP := AllTrim(cZHBDes)

                    // CCusto
                    SE2->E2_CCUSTO := cCCusto // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos

                SE2->( msUnLock() )

                //gera log
                u_GrLogZBE( msDate(), TIME(), cUserName, "GEROU CENTRAL APROVACAO - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN120P",;
                "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                // Flego RM (LK tem que ser fora do begin transaction senão dá erro)
                /*
                cSQL := " UPDATE OPENQUERY ( " + cLinked + ",
                cSQL += " ' SELECT FLAG_SIGA, FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA
                cSQL += "   FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL]
                cSQL += "   WHERE CODCOLIGADA = ''"+cColigada+"''
                cSQL += "   AND CODFORUM = ''"+cForum+"''
                cSQL += "   AND NUMPROCESSO = ''"+cProcesso+"'' ' )
                cSQL += " SET FLAG_SIGA = 'T', FILIAL_SIGA = '"+FWxFilial("SE2")+"', PREFIXO_SIGA = '"+cPrefixo+"', NUM_SIGA = '"+cNumero+"'

                If tcSqlExec(cSQL) < 0
                    msgAlert("UPDATE no RM não foi realizado! Envie o erro que será mostrado na próxima tela ao TI...")
                    MessageBox(tcSqlError(),"",16)
                    Conout( DtoC(msDate()) + " " + Time() + " ADFIN115P - RM ACORDOS " + TCSQLError() )
                EndIf

                cSql := " UPDATE [" + cLinked + "].[" + cSGBD + "].[DBO].[VPROCESSOCOMPL]
                cSql += " SET FLAG_SIGA = 'T', FILIAL_SIGA = '"+FWxFilial("SE2")+"', PREFIXO_SIGA = '"+cPrefixo+"', NUM_SIGA = '"+cNumero+"'
                cSQL += "   WHERE CODCOLIGADA = '"+cColigada+"'
                cSQL += "   AND CODFORUM = '"+cForum+"'
                cSQL += "   AND NUMPROCESSO = '"+cProcesso+"'

                tcSqlExec(cSQL)
                */
            
            EndIf

            If !lMsErroAuto

                cSitAprov := u_GetSitZC7(SE2->E2_FILIAL, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO)

                If lSigaOn

                    ZHB->( dbSetOrder(2) ) // ZHB_FILIAL, ZHB_PROCES, ZHB_ITEM, ZHB_TIPDES, R_E_C_N_O_, D_E_L_E_T_
                    If ZHB->( dbSeek(FWxFilial("ZHB")+cProcesso+cZHBItem+cZHBTip) )
                        RecLock("ZHB", .F.)
                            ZHB->ZHB_GERSE2 := .T.
                            ZHB->ZHB_NUM    := cNumero
                            ZHB->ZHB_STATUS := AllTrim(cSitAprov)
                        ZHB->( msUnLock() )
                    EndIf

                Else

                    // Flego RM (LK tem que ser fora do begin transaction senão dá erro)
                    cSQL := " UPDATE OPENQUERY ( " + cLinked + ",
                    cSQL += " ' SELECT FLAG_SIGA, FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA, STATUS_APROVACAO
                    cSQL += "   FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL]
                    cSQL += "   WHERE CODCOLIGADA = ''"+cColigada+"''
                    cSQL += "   AND CODFORUM = ''"+cForum+"''
                    cSQL += "   AND NUMPROCESSO = ''"+cProcesso+"'' ' )
                    cSQL += " SET FLAG_SIGA = 'T', FILIAL_SIGA = '"+FWxFilial("SE2")+"', PREFIXO_SIGA = '"+cPrefixo+"', NUM_SIGA = '"+cNumero+"', STATUS_APROVACAO = '"+cSitAprov+"'

                    If tcSqlExec(cSQL) < 0
                        msgAlert("UPDATE no RM não foi realizado! Envie o erro que será mostrado na próxima tela ao TI...")
                        MessageBox(tcSqlError(),"",16)
                        Conout( DtoC(msDate()) + " " + Time() + " ADFIN115P - RM ACORDOS " + TCSQLError() )
                    EndIf

                EndIf

            Else
                DisarmTransaction()
                Break
            EndIf

        End Transaction

        // Envio de Pendencia Para o Aprovador não Ausente
        If lEmail

            If Select("TMPZC3") > 0
                TMPZC3->( dbCloseArea() )
            EndIf

            cQuery := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV 
            cQuery += " FROM " + RetSqlName("ZC3") + " ZC3 (NOLOCK)
            cQuery += " INNER JOIN " + RetSqlName("ZCF") + " ZCF (NOLOCK) ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ''
            cQuery += " WHERE ZCF_CODIGO = '"+cCodBlq+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ''
            cQuery += " ORDER BY ZCF_NIVEL

            TcQuery cQuery New Alias "TMPZC3"

            If !Empty(TMPZC3->ZC3_CODUSU)
                cmaildest := AllTrim(UsrRetMail(TMPZC3->ZC3_CODUSU))
            EndIf

            cMensagem := u_WGFA050FIN( cFilRM, cPrefixo, cNumero, cParcela, cFornece, cLoja, nValor, cDscBlq, 'F' )
            
            If !Empty(cmaildest)
                u_F050EnvWF( cAssunto, cMensagem, cmaildest, '' )
            Endif

            If Select("TMPZC3") > 0
                TMPZC3->( dbCloseArea() )
            EndIf

        EndIf

    EndIf

	RestArea( aAreaAtu ) 
	
Return

/*/{Protheus.doc} Static Function NextRC1
    Função para substituir Rc1TitIni() 
    @type  Function
    @author FWNM
    @since 07/05/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 11556 - Fernando Macieira - 29/04/2021 - Processo Trabalhista - Títulos (Consulta Aprovação)
/*/
Static Function NextRC1()

    Local cNextCod := ""
    Local cQuery   := ""

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT MAX(RC1_NUMTIT) AS NEXT_COD 
    cQuery += " FROM " + RetSqlName("RC1") + " (NOLOCK) 
    cQuery += " WHERE RC1_FILIAL='"+FWxFilial("RC1")+"' 
    cQuery += " AND D_E_L_E_T_='' 

    tcQuery cQuery New Alias "Work"

    cNextCod := Soma1(AllTrim(Work->NEXT_COD))

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    dbSelectArea("RC1")
    ConfirmSX8()
    //

Return cNextCod

/*/{Protheus.doc} Static Function ChkProcess(cProcesso)
    Checa se o Processo já foi integrado ao Protheus
    @type  Static Function
    @author FWNM
    @since 28/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkProcess(cProcesso)

    Local lRet    := .f.
    Local cQuery  := ""
    Local cCodBlq   := GetMV("MV_#ZC7RC1",,"000013")

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    cQuery := " SELECT COUNT(1) TT
    cQuery += " FROM " + RetSqlName("ZC7") + " (NOLOCK)
    cQuery += " WHERE ZC7_TPBLQ='"+cCodBlq+"' 
    cQuery += " AND ZC7_DSCBLQ LIKE '%"+cProcesso+"%'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery New Alias "Work"

    Work->( dbGoTop() )
    If Work->TT > 0
        lRet := .t.
    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf
    
Return lRet

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author user
    @since 03/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function GetSitZC7(E2FILIAL, E2FORNECE, E2LOJA, E2PREFIXO, E2NUM, E2PARCELA, E2TIPO)

    Local cTxt     := ""
    Local cZC7_USRALT := ""
    Local aAreaZC7 := ZC7->( GetArea() )

	ZC7->( dbSetOrder(2) ) // ZC7_FILIAL, ZC7_CLIFOR, ZC7_LOJA, ZC7_PREFIX, ZC7_NUM, ZC7_PARCEL, ZC7_TIPO
	If ZC7->( dbSeek( E2FILIAL + E2FORNECE + E2LOJA + E2PREFIXO + E2NUM + E2PARCELA + E2TIPO ) )

        Do While ZC7->( !EOF() ) .and. ZC7->ZC7_FILIAL==E2FILIAL .and. ZC7->ZC7_CLIFOR==E2FORNECE .and. ZC7->ZC7_LOJA==E2LOJA .and. ZC7->ZC7_PREFIX==E2PREFIXO .and. ZC7->ZC7_NUM==E2NUM .and. ZC7->ZC7_PARCEL==E2PARCELA .and. ZC7->ZC7_TIPO==E2TIPO

            IF !EMPTY(ZC7->ZC7_USRAPR)
                cZC7_USRALT := UsrRetName(ZC7->ZC7_USRAPR)
            Else
                cZC7_USRALT := POSAPR(ZC7->ZC7_TPBLQ, ZC7->ZC7_NIVEL)
            EndIf

            cTxt += IIF(EMPTY(ZC7->ZC7_USRAPR), OemToAnsi("AGUARDANDO APROVAÇÃO"), IIF(!EMPTY(ZC7->ZC7_REPROV), OemToAnsi("REJEITADO"), OemToAnsi("APROVADO")) ) + ", " + cZC7_USRALT + " " + chr(13) + chr(10)

            ZC7->( dbSkip() )

        EndDo

    EndIf

    RestArea( aAreaZC7 )
    
Return cTxt

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Ricardo Lima
    @since 15/05/2017
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function POSAPR( ZC7TPBLQ , ZC7NIVEL )

	Local cQuery := ""
	Local sRet   := ""
	Local aArea	  := GetArea()

	cQuery := " SELECT ZCF_CODIGO, ZCF_APROVA "
	cQuery += " FROM "+RetSqlName("ZCF")+" "
	cQuery += " WHERE ZCF_CODIGO = '"+ZC7TPBLQ+"' AND ZCF_NIVEL >= '"+ZC7NIVEL+"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ZCF_NIVEL "

	If Select("ADFINB61") > 0
    	ADFINB61->(DbCloseArea())		
    EndIf	

    TcQuery cQuery New Alias "ADFINB61"

	sRet := ADFINB61->ZCF_APROVA+"-"+UsrRetName(ADFINB61->ZCF_APROVA)

	RestArea(aArea)

Return(sRet)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 04/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetZCF()

    Local lOk     := .f.
    Local cCodBlq := GetMV("MV_#ZC7RC1",,"000013")
    Local cCodUsr := RetCodUsr()

    If IsInCallStack("u_ADFI118")
        cCodUsr := GetMV("MV_#ZC7ZHB",,"002184")
    EndIf

    If Select("WorkZCF") > 0
        WorkZCF->( dbCloseArea() )
    EndIf

    cQuery := " SELECT ZCF_NIVEL, ZCF_APROVA
    cQuery += " FROM " + RetSqlName("ZCF") + " (NOLOCK)
    cQuery += " WHERE ZCF_FILIAL='"+FWxFilial("ZCF")+"' 
    cQuery += " AND ZCF_CODIGO='"+cCodBlq+"'
    cQuery += " AND ZCF_APROVA='"+cCodUsr+"' 
    cQuery += " AND ZCF_NIVEL='01'
    cQuery += " AND D_E_L_E_T_=''

    tcQuery cQuery new Alias "WorkZCF"

    WorkZCF->( dbGoTop() )
    If WorkZCF->( !EOF() )
        lOk := .t.
    EndIf

    If Select("WorkZCF") > 0
        WorkZCF->( dbCloseArea() )
    EndIf
    
Return lOk
