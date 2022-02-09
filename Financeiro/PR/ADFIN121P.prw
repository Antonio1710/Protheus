#include "protheus.ch"
#include "topconn.ch"
#Include "TbiConn.ch"
#Include "AP5MAIL.CH"      
#Include "Rwmake.ch" 

// BIBLIOTECAS NECESSÁRIAS
#Include "TOTVS.ch"
#INCLUDE "XMLXFUN.CH"

// BARRA DE SEPARAÇÃO DE DIRETÓRIOS
#Define BAR IIf(IsSrvUnix(), "/", "\")
#DEFINE ENTER Chr(13)+Chr(10)

// Variaveis estaticas
Static cRotina  := "ADFIN121P"
//Static cTitulo  := "Gera parcelas dos acordos trabalhistas oriundos do RM"
//Static lAuto    := .t.

/*/{Protheus.doc} User Function ADFIN121P
    Job para gerar as parcelas dos acordos trabalhistas oriundos do RM
    @type  Function
    @author Fernando Macieira
    @since 28/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 18141 - RM - Acordos - Integração Protheus
    @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
/*/
User Function ADFIN121P(lAuto)

    Local i, ii
    Local cEmpRun      := "01"
    Local cFilRun      := "02"
    Local nRecnoE2PR   := 0
    Local cHist        := ""
    Local aBaixa       := {}
    Local nQtdParcelas := 0
    Local nVlrParcelas := 0
    Local cTipo        := ""
    Local cParcela     := ""
    Local dVencto      := CtoD("//")
    Local nDias        := 0
    Local aEmpresas    := {}
    Local nSeqBx       := 1
    Local lExibeLanc   := .f.
    Local lOnline      := .f.
    Local aDadSE2      := {}
    Local cStatusRM    := ""

    // Dados necessários para central aprovação
    Local cPrefixo  := ""
    Local cTipoPR   := ""
    Local cTipoNDI  := ""
    Local cNaturez  := ""
    Local cFornece  := ""
    Local cLoja     := ""

    Default lAuto := .t.

    Private lSigaOn := .t.
    Private cLinked := "RM"
	Private cSGBD   := "CCZERN_119204_RM_PD"


    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para gerar as parcelas dos acordos trabalhistas oriundos do RM')

	// Inicializo ambiente
    If lAuto

        rpcClearEnv()
        //rpcSetType(3)
            
        If !rpcSetEnv(cEmpRun, cFilRun,,,,,{"SM0"})
            ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa 01, filial 02" )
            Return
        EndIf

    EndIf

    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
    If !LockByName(cRotina, .T., .F.)
        ConOut( cRotina + " Rotina não executada pois existe outro processamento" )
        Return
    EndIf

    PtInternal(1,ALLTRIM(PROCNAME()))

    lSigaOn := GetMV("MV_#RMSIGA",,.T.)
    // @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    cLinked :=  GetMV("MV_#RMLINK",,"RM") // DEBUG - "LKD_PRT_RM" 
	cSGBD   :=  GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // DEBUG - "CCZERN_119205_RM_DE"
    cEmpRun := GetMV("MV_#RMAEMP",,"01#02#07#09")
    cFilRun := GetMV("MV_#RMAFIL",,"02")
    
    // Dados necessários para central aprovação
    cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    cTipoPR   := GetMV("MV_#ZC7TIP",,"PR")
    cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    cLoja     := GetMV("MV_#ZC7LOJ",,"01")

	// Carrega Empresas para processamentos
	dbSelectArea("SM0")
	dbSetOrder(1)
	SM0->(dbGoTop())
	Do While SM0->(!EOF())
		If (SM0->M0_CODIGO $ cEmpRun) .and. (SM0->M0_CODFIL $ cFilRun)
			aAdd(aEmpresas, { SM0->M0_CODIGO, SM0->M0_CODFIL } )
		EndIf
		SM0->( dbSkip() )
	EndDo

    // Processa empresas
    For i:=1 to Len(aEmpresas)
	
    	If lAuto

            RpcClearEnv()
            //RpcSetType(3)
            RpcSetEnv( aEmpresas[ i,1 ] , aEmpresas[ i,2 ] )

        EndIf

        // EXCLUIR_SIGA
        If !lSigaON
            ExcTitPR()
        EndIf

        // Gera Parcelas
        cTipoPR := GetMV("MV_#ZC7TIP",,"PR")

        If Select("Work") > 0
            Work->( dbCloseArea() )
        EndIf

        // E2_XDIVERG = N (APROVADO)
        cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VALOR, E2_BANCO, E2_AGEN, E2_DIGAG, E2_NOCTA, E2_DIGCTA, E2_NOMCTA, E2_CNPJ, E2_OBS_AP, E2_CCUSTO
        cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
        cQuery += " WHERE E2_FILIAL='"+FWxFilial("SE2")+"' 
        cQuery += " AND E2_PREFIXO='"+cPrefixo+"' 
        cQuery += " AND E2_TIPO='"+cTipoPR+"' 
        cQuery += " AND E2_NATUREZ='"+cNaturez+"' 
        cQuery += " AND E2_FORNECE='"+cFornece+"' 
        cQuery += " AND E2_LOJA='"+cLoja+"' 
        cQuery += " AND E2_XDIVERG='N' AND E2_RJ<>'X'
        cQuery += " AND E2_BAIXA='' AND E2_SALDO>0 AND E2_STATUS<>'B'
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "Work"

        Work->( dbGoTop() )
        Do While Work->( !EOF() )

            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            If SE2->( dbSeek(Work->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)) )

                cHist := Right(AllTrim(SE2->E2_HIST),46)
                
                //Baixa PR
                lMsErroAuto := .F.
                dbSelectArea("SE2")

				nRecnoE2PR := SE2->( RecNo() )
				
                aBaixa := {}
                aBaixa := { {"E2_PREFIXO"  ,SE2->E2_PREFIXO ,Nil },;
                            {"E2_NUM"      ,SE2->E2_NUM     ,Nil },;
                            {"E2_TIPO"     ,"NDI"           ,Nil },;
                            {"E2_FORNECE"  ,SE2->E2_FORNECE ,Nil },;
                            {"E2_LOJA"     ,SE2->E2_LOJA    ,Nil },;
                            {"E2_NATUREZ"  ,SE2->E2_NATUREZ ,Nil },;
                            {"E2_PARCELA"  ,SE2->E2_PARCELA ,Nil },;
                            {"AUTMOTBX"    ,"STP"           ,Nil },;
                            {"CBANCO"      ,""              ,Nil },;
                            {"CAGENCIA"    ,""              ,Nil },;
                            {"CCONTA"      ,""              ,Nil },;
                            {"AUTDTBAIXA"  ,msDate()        ,Nil },;
                            {"AUTDTCREDITO",msDate()        ,Nil },;
                            {"AUTHIST"     ,cHist           ,Nil },;
                            {"AUTJUROS"    ,0               ,Nil,.T.}}
                            //{"NVALREC" ,SE1->E1_VALOR,Nil }}

                Begin Transaction

                    nQtdParcelas := Val(SE2->E2_PARCELA)
                    nVlrParcelas := SE2->E2_VALOR / nQtdParcelas

					RecLock("SE2", .F.)
						SE2->E2_TIPO   := "NDI"
                        SE2->E2_ORIGEM := "FINA050"
					SE2->( msUnLock() )

                    //Pergunte da rotina
                    AcessaPerg("FINA080", .F.)                  
         
                    //Chama a execauto da rotina de baixa manual (FINA080)
                    MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, 3, .F., nSeqBx, lExibeLanc, lOnline)
                    
                    //Em caso de erro na baixa
                    If lMsErroAuto
                        DisarmTransaction()
                        If !lAuto
                            MostraErro()
                        EndIf
                    Else

                        RecLock("SE2", .F.)
                            SE2->E2_TIPO    := cTipoPR
                        SE2->( msUnLock() )

                        RecLock("SE5", .F.)
                            SE5->E5_TIPO    := cTipoPR
                        SE5->( msUnLock() )

                        cTipoNDI   := GetMV("MV_#ACOTIP",,"NDI")

                        //gera log
                        u_GrLogZBE( msDate(), TIME(), cUserName, "BAIXOU PR - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                        "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )
                        
                        aDadSE2 := {}
                        
                        For ii:=1 to nQtdParcelas

                            SE2->( dbGoTo(nRecnoE2PR) )
                            
                            cParcela := StrZero(ii,TamSX3("E2_PARCELA")[1])
                            If ii == 1
                                dVencto  := SE2->E2_VENCTO
                            Else
                                dVencto  := dVencto+nDias
                            EndIf

                            aDadNDI := {}
                            aDadNDI := {{ "E2_PREFIXO", SE2->E2_PREFIXO  , NIL },;
                                        { "E2_NUM"    , SE2->E2_NUM		 , NIL },;
                                        { "E2_PARCELA", cParcela         , NIL },;
                                        { "E2_TIPO"   , cTipoNDI         , NIL },;
                                        { "E2_NATUREZ", SE2->E2_NATUREZ	 , NIL },;
                                        { "E2_FORNECE", SE2->E2_FORNECE  , NIL },;
                                        { "E2_LOJA"   , SE2->E2_LOJA     , NIL },;
                                        { "E2_EMISSAO", msDate()         , NIL },;
                                        { "E2_VENCTO" , dVencto          , NIL },;
                                        { "E2_VENCREA", DataValida(dVencto) , NIL },;
                                        { "E2_VALOR"  , nVlrParcelas     , NIL },;
                                        { "E2_HIST"   , cHist            , NIL }}
			
                            lMsErroAuto := .f.
                            dbSelectArea("SE2")
                            msExecAuto( { |x,y| FINA050(x,y) }, aDadNDI, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

                            If lMsErroAuto

                                DisarmTransaction()
                                If !lAuto
                                    MostraErro()
                                EndIf

                            Else

                                RecLock("SE2", .F.)
                                    SE2->E2_ORIGEM := "GPEM670"
                                    SE2->E2_LOGDTHR	:= DtoC(msDate()) + ' ' + TIME()
                                    // Dados CNAB
                                    SE2->E2_BANCO  := Work->E2_BANCO
                                    SE2->E2_AGEN   := Work->E2_AGEN
                                    SE2->E2_DIGAG  := Work->E2_DIGAG
                                    SE2->E2_NOCTA  := Work->E2_NOCTA
                                    SE2->E2_DIGCTA := Work->E2_DIGCTA
                                    SE2->E2_NOMCTA := Work->E2_NOMCTA
                                    SE2->E2_CNPJ   := Work->E2_CNPJ
                                    SE2->E2_OBS_AP := Work->E2_OBS_AP
                                    // Dados contabeis
                                    SE2->E2_CCUSTO := Work->E2_CCUSTO // @ticket 18141 - Fernando Macieira - 09/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
                                SE2->( msUnLock() )

                                nDias += 30

                                aAdd( aDadSE2, { SE2->(RecNo()) } )

                                //gera log
                                u_GrLogZBE( msDate(), TIME(), cUserName, "GEROU PARCELA - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                                "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                            EndIf

                        Next ii

                        SE2->( dbGoTo(nRecnoE2PR) )
                        RecLock("SE2", .F.)
                            SE2->E2_ORIGEM := "GPEM670"
                        SE2->( msUnLock() )

                    EndIf

                    // Flego RM
                    If Len(aDadSE2) > 0
                        
                        cVenctos := u_GetVenct()

                        If lSigaOn

                            ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
                            If ZHB->( dbSeek(FWxFilial("ZHB")+SE2->E2_NUM) )
                                RecLock("ZHB", .F.)
                                    ZHB->ZHB_GERPAR := .T.
                                    ZHB->ZHB_STATUS := AllTrim(ZHB->ZHB_STATUS) + " " + cVenctos
                                ZHB->( msUnLock() )
                            EndIf

                        Else

                            // Flego RM (tem que ser fora do begin transaction senão dá erro)
                            cSQL := " UPDATE OPENQUERY ( " + cLinked + ",
                            cSQL += " ' SELECT FLAG_SIGA, FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA, STATUS_APROVACAO
                            cSQL += "   FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL]
                            cSQL += "   WHERE FILIAL_SIGA = ''"+SE2->E2_FILIAL+"''
                            cSQL += "   AND PREFIXO_SIGA = ''"+SE2->E2_PREFIXO+"''
                            cSQL += "   AND NUM_SIGA = ''"+SE2->E2_NUM+"'' ' )
                            cSQL += " SET STATUS_APROVACAO = CONVERT(VARCHAR(1000),STATUS_APROVACAO) + '"+cVenctos+"' 
                            //cSQL += " SET STATUS_APROVACAO = '"+cStatusRM + cVenctos+"' 

                            If tcSqlExec(cSQL) < 0
                                Conout( DtoC(msDate()) + " " + Time() + " ADFIN121P - RM ACORDOS " + TCSQLError() )
                            EndIf

                        EndIf

                    EndIf

                End Transaction

            EndIf

            Work->( dbSkip() )

        EndDo

    Next i

    If Select("RM") > 0
        RM->( dbCloseArea() )
    EndIf

    If Select("Work") > 0
        Work->( dbCloseArea() )
    EndIf

    UnLockByName(cRotina)

Return

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
User Function GetVenct()

    Local cTxt     := ""
    Local cQuery   := ""
    Local cTipo    := GetMV("MV_#ACOTIP",,"NDI")
    Local cFornece := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja    := GetMV("MV_#ZC7LOJ",,"01")
    Local aArea    := GetArea()

    If Select("WorkSE2") > 0
        WorkSE2->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E2_PARCELA, E2_VENCREA
    cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
    cQuery += " WHERE E2_FILIAL='"+SE2->E2_FILIAL+"'
    cQuery += " AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'
    cQuery += " AND E2_NUM='"+SE2->E2_NUM+"'
    cQuery += " AND E2_TIPO='"+cTipo+"'
    cQuery += " AND E2_FORNECE='"+cFornece+"'
    cQuery += " AND E2_LOJA='"+cLoja+"'
    cQuery += " AND D_E_L_E_T_=''
    cQuery += " ORDER BY 1

    tcQuery cQuery New Alias "WorkSE2"

    aTamSX3	:= TamSX3("E2_VENCREA")
    tcSetField("WorkSE2", "E2_VENCREA", aTamSX3[3], aTamSX3[1], aTamSX3[2])

    WorkSE2->( dbGoTop() )
    Do While WorkSE2->( !EOF() )

        //cTxt += "Parcela " + WorkSE2->E2_PARCELA + ", Vencimento " + DtoC(WorkSE2->E2_VENCREA)  + chr(13) + chr(10)
        cTxt += WorkSE2->E2_PARCELA + " em " + DtoC(WorkSE2->E2_VENCREA)  + chr(13) + chr(10)

        WorkSE2->( dbSkip() )

    EndDo

    If Select("WorkSE2") > 0
        WorkSE2->( dbCloseArea() )
    EndIf

    RestArea( aArea )
    
Return cTxt

/*/{Protheus.doc} Static Function ExcTitPR()
    Exclui títulos integrados desde que não tenham sido baixados
    @type  Static Function
    @author Fernando Macieira
    @since 04/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ExcTitPR()

    Local cQuery   := ""
    Local cTipoPR  := GetMV("MV_#ZC7TIP",,"PR")
    Local cTipoNDI := GetMV("MV_#ACOTIP",,"NDI")
    Local cFornece := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja    := GetMV("MV_#ZC7LOJ",,"01")
    Local aDadPR   := {}
    Local cStatusRM := "Excluído em " + DtoC(msDate())

    If lSigaOn
        Return
    EndIf

    // Busco títulos integrados que devem ser excluídos
    If Select("WorkRM") > 0
        WorkRM->( dbCloseArea() )
    EndIf

    cQuery := " SELECT * FROM OPENQUERY ( " + cLinked + ", '
    cQuery += "	    SELECT FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA
    cQuery += "		FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL] (NOLOCK)
    cQuery += "     WHERE EXCLUIR_SIGA = ''T''
    cQuery += " ' )

    tcQuery cQuery New Alias "WorkRM"

    WorkRM->( dbGoTop() )
    Do While WorkRM->( !EOF() )

        // Tento excluir títulos integrados (cenário 1 = Apenas PR sem NDI)
        If Select("WorkPR") > 0
            WorkPR->( dbCloseArea() )
        EndIf

        cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_ RECNO
        cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
        cQuery += " WHERE E2_FILIAL='"+WorkRM->FILIAL_SIGA+"'
        cQuery += " AND E2_PREFIXO='"+WorkRM->PREFIXO_SIGA+"'
        cQuery += " AND E2_NUM='"+WorkRM->NUM_SIGA+"'
        cQuery += " AND E2_TIPO='"+cTipoPR+"'
        cQuery += " AND E2_FORNECE='"+cFornece+"'
        cQuery += " AND E2_LOJA='"+cLoja+"'
        cQuery += " AND E2_BAIXA='' AND E2_SALDO=E2_VALOR
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "WorkPR"

        WorkPR->( dbGoTop() )
        Do While WorkPR->( !EOF() )

            dbSelectArea("SE2")
            SE2->( dbGoTo(WorkPR->RECNO) )

            aDadPR := {}
            aDadPR := { { "E2_FILIAL" , SE2->E2_FILIAL , NIL },;
                        { "E2_PREFIXO", SE2->E2_PREFIXO, NIL },;
                        { "E2_NUM"    , SE2->E2_NUM    , NIL },;
                        { "E2_PARCELA", SE2->E2_PARCELA, NIL },;
                        { "E2_TIPO"   , SE2->E2_TIPO   , NIL },;
                        { "E2_NATUREZ", SE2->E2_NATUREZ, NIL },;
                        { "E2_FORNECE", SE2->E2_FORNECE, NIL },;
                        { "E2_LOJA"   , SE2->E2_LOJA   , NIL } }

            Begin Transaction

                RecLock("SE2", .F.)
                    SE2->E2_ORIGEM := "FINA050"
                SE2->( msUnLock() )
                
                // PR Contas a Pagar
                lMsErroAuto := .f.
                dbSelectArea("SE2")
                MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDadPR,, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

                If lMsErroAuto

                    RecLock("SE2", .F.)
                        SE2->E2_ORIGEM := "GPEM670"
                    SE2->( msUnLock() )

                    DisarmTransaction()

                EndIf

            End Transaction

            If !lMsErroAuto

                // Flego RM (tem que ser fora do begin transaction senão dá erro)
                cSQL := " UPDATE OPENQUERY ( " + cLinked + ",
                cSQL += " ' SELECT FLAG_SIGA, FILIAL_SIGA, PREFIXO_SIGA, NUM_SIGA, STATUS_APROVACAO, EXCLUIR_SIGA
                cSQL += "   FROM [" + cSGBD + "].[DBO].[VPROCESSOCOMPL]
                cSQL += "   WHERE FILIAL_SIGA = ''"+WorkRM->FILIAL_SIGA+"''
                cSQL += "   AND PREFIXO_SIGA = ''"+WorkRM->PREFIXO_SIGA+"''
                cSQL += "   AND NUM_SIGA = ''"+WorkRM->NUM_SIGA+"'' ' )
                cSQL += " SET EXCLUIR_SIGA = 'F', FLAG_SIGA = 'F', FILIAL_SIGA = '', PREFIXO_SIGA = '', NUM_SIGA = '', STATUS_APROVACAO = CONVERT(VARCHAR(1000),STATUS_APROVACAO) + '"+cStatusRM+"' 

                If tcSqlExec(cSQL) < 0
                    Conout( DtoC(msDate()) + " " + Time() + " ADFIN121P - RM ACORDOS " + TCSQLError() )
                EndIf

            EndIf

            WorkPR->( dbSkip() )

        EndDo

        WorkRM->( dbSkip() )

    EndDo

    If Select("WorkPR") > 0
        WorkPR->( dbCloseArea() )
    EndIf

    If Select("WorkRM") > 0
        WorkRM->( dbCloseArea() )
    EndIf

Return
