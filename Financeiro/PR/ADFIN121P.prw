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
    @ticket 18141 - Fernando Macieira - 10/02/2022 - RM - Acordos - Integração Protheus - Processos com 2 ou + favorecidos
    @ticket TI    - Fernando Macieira - 24/02/2022 - RM - Acordos - Título vencido com error log está impedindo a geração dos demais
    @ticket 18141 - Fernando Macieira - 25/02/2022 - RM - Acordos - Integração Protheus - Parcelas com Data vencimento errado (sem respeitar o sequencial de 30 dias)
    @ticket 18141 - Fernando Macieira - 03/03/2022 - RM - Acordos - Integração Protheus - Tratamento na função de gerar parcelas (Título 047073054 de R$ 7.000,00 gerou 3 parcelas de R$ 2.333,33 (faltou 1 centavo));
    @ticket 70440 - Fernando Macieira - 28/03/2022 - acordos lançados em fevereiro geraram a parcela de março para a data errada, não podera ser 30 dias nesse caso
    @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Integração Protheus - Desativação função fix
    @ticket 18141 - Fernando Macieira - 30/03/2022 - RM - Acordos - Integração Protheus - Gerar contas a pagar com a database e não pela data do servidor
    @ticket 18141 - Fernando Macieira - 31/03/2022 - RM - Acordos - Integração Protheus - Reativação função fix - Visa garantir a integridade das regras
    @ticket 70924 - Fernando Macieira - 06/04/2022 - RM - Acordos - verificar os acordos em meses que tem 31 dias, não podemos ter duas parcelas dentro do mesmo mês, exemplos os titulos final 3081 e 3087
    @ticket 68607 - Fernando Macieira - 19/04/2022 - RM - Acordos - Desenvolvimento e configuração da rotina ADFIN121P para rodar em job via schedule
    @ticket 68607 - Fernando Macieira - 25/04/2022 - RM - Acordos - Parcelas não estão gerando com a emissão do tipo PR
    @ticket 68607 - Fernando Macieira - 26/04/2022 - RM - Acordos - despesa parcelamento CPC - Parcelado, a opção da primeira parcela ser 30% do valor do total e o restante escolher a quantidade de parcelas.
    @ticket 72310 - Fernando Macieira - 10/05/2022 - RM - Acordos - Parcelas NDI
    @ticket 72340 - Fernando Macieira - 12/05/2022 - RM - Acordos - Inclusao de filial
    @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
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
    Local nDifParcelas := 0
    Local cParcela     := ""
    Local dVencto      := CtoD("//")
    Local nDias        := 0
    Local aEmpresas    := {}
    Local nSeqBx       := 1
    Local lExibeLanc   := .f.
    Local lOnline      := .f.
    Local aDadSE2      := {}
    Local cStatusRM    := ""
    Local dDtBkp       := dDataBase // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
    
    // @ticket 68607 - Fernando Macieira - 26/04/2022 - RM - Acordos - despesa parcelamento CPC - Parcelado, a opção da primeira parcela ser 30% do valor do total e o restante escolher a quantidade de parcelas.
    Local nVlrParc1    := 0
    Local lPerc1P      := .f.
    Local nSldParc1    := 0
    Local nVlrSE2      := 0

    // Dados necessários para central aprovação
    Local cPrefixo  := ""
    Local cNaturez  := ""
    Local cFornece  := ""
    Local cLoja     := ""

    Default lAuto := .t.

    Private lSigaOn := .t.
    Private cLinked := "RM"
	Private cSGBD   := "CCZERN_119204_RM_PD"

    Private cTipoPR  := "PR"
    Private cTipoNDI := "NDI"

    //U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para gerar as parcelas dos acordos trabalhistas oriundos do RM') // @ticket 68607 - Fernando Macieira - 19/04/2022 - RM - Acordos - Desenvolvimento e configuração da rotina ADFIN121P para rodar em job via schedule
    
	// Inicializo ambiente
    If lAuto

        rpcClearEnv()
        //rpcSetType(3)
            
        If !rpcSetEnv(cEmpRun, cFilRun,,,,,{"SM0"})
            ConOut( cRotina + " Não foi possível inicializar o ambiente, empresa 01, filial 02" )
            Return
        EndIf

    EndIf

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Job para gerar as parcelas dos acordos trabalhistas oriundos do RM') // @ticket 68607 - Fernando Macieira - 19/04/2022 - RM - Acordos - Desenvolvimento e configuração da rotina ADFIN121P para rodar em job via schedule

    // Garanto uma única thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 29/06/2020
    If !LockByName(cRotina, .T., .F.)
        ConOut( cRotina + " Rotina não executada pois existe outro processamento" )
        Return
    EndIf

    PtInternal(1,ALLTRIM(PROCNAME()))

    lSigaOn := GetMV("MV_#RMSIGA",,.T.)

    // @ticket 18141 - Fernando Macieira - 26/01/2022 - RM - Acordos - Integração Protheus - Parâmetro Linked Server
    cLinked := GetMV("MV_#RMLINK",,"RM") // DEBUG - "LKD_PRT_RM" 
	cSGBD   := GetMV("MV_#RMSGBD",,"CCZERN_119204_RM_PD") // DEBUG - "CCZERN_119205_RM_DE"
    cEmpRun := GetMV("MV_#RMAEMP",,"01#02#07#09")
    cFilRun := GetMV("MV_#RMAFIL",,"02|03") // @ticket 72340 - Fernando Macieira - 12/05/2022 - RM - Acordos - Inclusao de filial
    
    // Dados necessários para central aprovação
    cPrefixo  := GetMV("MV_#ZC7PRE",,"GPE")
    cTipoPR   := GetMV("MV_#ZC7TIP",,"PR")
    cNaturez  := GetMV("MV_#ZC7NAT",,"22326")
    cFornece  := GetMV("MV_#ZC7SA2",,"001901")
    cLoja     := GetMV("MV_#ZC7LOJ",,"01")

    cTipoNDI := GetMV("MV_#ACOTIP",,"NDI")

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
        cQuery += " AND E2_VENCTO>='"+DtoS(msDate())+"' " // @ticket TI    - Fernando Macieira - 24/02/2022 - RM - Acordos - Título vencido com error log está impedindo a geração dos demais
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
                            {"E2_TIPO"     ,cTipoNDI        ,Nil },;
                            {"E2_FORNECE"  ,SE2->E2_FORNECE ,Nil },;
                            {"E2_LOJA"     ,SE2->E2_LOJA    ,Nil },;
                            {"E2_NATUREZ"  ,SE2->E2_NATUREZ ,Nil },;
                            {"E2_PARCELA"  ,SE2->E2_PARCELA ,Nil },;
                            {"AUTMOTBX"    ,"STP"           ,Nil },;
                            {"CBANCO"      ,""              ,Nil },;
                            {"CAGENCIA"    ,""              ,Nil },;
                            {"CCONTA"      ,""              ,Nil },;
                            {"AUTDTBAIXA"  ,SE2->E2_EMISSAO/*msDate()*/        ,Nil },; // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
                            {"AUTDTCREDITO",SE2->E2_EMISSAO/*msDate()*/        ,Nil },; // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
                            {"AUTHIST"     ,cHist           ,Nil },;
                            {"AUTJUROS"    ,0               ,Nil,.T.}}
                            //{"NVALREC" ,SE1->E1_VALOR,Nil }}

                // @ticket 68607 - Fernando Macieira - 26/04/2022 - RM - Acordos - despesa parcelamento CPC - Parcelado, a opção da primeira parcela ser 30% do valor do total e o restante escolher a quantidade de parcelas.
                If ZHB->(FieldPos("ZHB_PERC1P")) > 0
                    lPerc1P := .f.
                    ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
                    If ZHB->( dbSeek(FWxFilial("ZHB")+SE2->E2_NUM) )
                        If ZHB->ZHB_PERC1P > 0
                            lPerc1P := .t.
                            nVlrParc1 := Round(SE2->E2_VALOR * (ZHB->ZHB_PERC1P / 100),TamSX3("E2_VALOR")[2])
                            nSldParc1 := SE2->E2_VALOR - nVlrParc1
                        EndIf
                    EndIf
                EndIf

                If lPerc1P
                    nQtdParcelas := Val(SE2->E2_PARCELA) - 1
                    nVlrParcelas := Round((nSldParc1 / nQtdParcelas),TamSX3("E2_VALOR")[2])
                    nDifParcelas := nSldParc1 - (nQtdParcelas * nVlrParcelas)
                    nQtdParcelas := Val(SE2->E2_PARCELA)
                Else
                    nQtdParcelas := Val(SE2->E2_PARCELA)
                    nVlrParcelas := Round((SE2->E2_VALOR / nQtdParcelas),TamSX3("E2_VALOR")[2])
                    nDifParcelas := SE2->E2_VALOR - (nQtdParcelas * nVlrParcelas) // @ticket 18141 - Fernando Macieira - 03/03/2022 - RM - Acordos - Integração Protheus - Tratamento na função de gerar parcelas (Título 047073054 de R$ 7.000,00 gerou 3 parcelas de R$ 2.333,33 (faltou 1 centavo));
                EndIf

                Begin Transaction

                    //gera log
                    u_GrLogZBE( msDate(), TIME(), cUserName, "TITULO PR (ANTES MUDAR PARA NDI PARA FAZER BAIXA - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                    "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                    RecLock("SE2", .F.)
						SE2->E2_TIPO   := cTipoNDI // Mudo para NDI devido exigência do padrão para efetuar a baixa
                        SE2->E2_ORIGEM := "FINA050"
					SE2->( msUnLock() )

                    //gera log
                    u_GrLogZBE( msDate(), TIME(), cUserName, "TITULO PR (DEPOIS DE MUDAR PARA NDI PARA FAZER BAIXA - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                    "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                    //Pergunte da rotina
                    AcessaPerg("FINA080", .F.)                  
         
                    // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
                    dDtBkp    := dDataBase
                    dDataBase := SE2->E2_EMISSAO 
                    //

                    //Chama a execauto da rotina de baixa manual (FINA080)
                    MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, 3, .F., nSeqBx, lExibeLanc, lOnline)
                    
                    //Em caso de erro na baixa
                    If lMsErroAuto

                        dDataBase := dDtBkp // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras
                        
                        //gera log
                        u_GrLogZBE( msDate(), TIME(), cUserName, "TITULO PR ESTÁ COMO NDI (EXECAUTO BAIXA FINA080 DEU ERRO - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                        "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                    	// @ticket 72310 - Fernando Macieira - 10/05/2022 - RM - Acordos - Parcelas NDI
                        SE2->( dbGoTo(nRecnoE2PR) )
                        RecLock("SE2", .F.)
                            SE2->E2_TIPO   := cTipoPR // Volto para PR devido error log
                            SE2->E2_ORIGEM := "GPEM670"
					    SE2->( msUnLock() )
                        //

                        //gera log
                        u_GrLogZBE( msDate(), TIME(), cUserName, "TITULO PR VOLTOU PARA PR (EXECAUTO BAIXA FINA080 DEU ERRO - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                        "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )
                    
                        If !lAuto
                            MostraErro()
                        EndIf

                        DisarmTransaction() 
                        Break 
                    
                    Else

                        SE2->( dbGoTo(nRecnoE2PR) )

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
                        
                        nDias := 0 // @ticket 18141 - Fernando Macieira - 25/02/2022 - RM - Acordos - Integração Protheus - Parcelas com Data vencimento errado (sem respeitar o sequencial de 30 dias)
                        aDadSE2 := {}
                        
                        For ii:=1 to nQtdParcelas

                            // @ticket 68607 - Fernando Macieira - 26/04/2022 - RM - Acordos - despesa parcelamento CPC - Parcelado, a opção da primeira parcela ser 30% do valor do total e o restante escolher a quantidade de parcelas.
                            nVlrSE2 := nVlrParcelas+nDifParcelas
                            If lPerc1P .and. ii == 1
                                nVlrSE2 := nVlrParc1
                            EndIf
                            //

                            SE2->( dbGoTo(nRecnoE2PR) )
                            
                            cParcela := StrZero(ii,TamSX3("E2_PARCELA")[1])
                            If ii == 1
                                dVencto := SE2->E2_VENCTO
                            Else
                                dVencto := SE2->E2_VENCTO+nDias
                            EndIf

                            aDadNDI := {}
                            aDadNDI := {{ "E2_PREFIXO", SE2->E2_PREFIXO          , NIL },;
                                        { "E2_NUM"    , SE2->E2_NUM		         , NIL },;
                                        { "E2_PARCELA", cParcela                 , NIL },;
                                        { "E2_TIPO"   , cTipoNDI                 , NIL },;
                                        { "E2_NATUREZ", SE2->E2_NATUREZ	         , NIL },;
                                        { "E2_FORNECE", SE2->E2_FORNECE          , NIL },;
                                        { "E2_LOJA"   , SE2->E2_LOJA             , NIL },;
                                        { "E2_EMISSAO", SE2->E2_EMISSAO /*msDate()*/                 , NIL },;
                                        { "E2_VENCTO" , dVencto                  , NIL },;
                                        { "E2_VENCREA", DataValida(dVencto)      , NIL },;
                                        { "E2_VALOR"  , nVlrSE2 /*nVlrParcelas+nDifParcelas*/, NIL },;
                                        { "E2_HIST"   , cHist                    , NIL }}
			
                            lMsErroAuto := .f.
                            dbSelectArea("SE2")
                            msExecAuto( { |x,y| FINA050(x,y) }, aDadNDI, 3 )  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

                            If lMsErroAuto

                                dDataBase := dDtBkp // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras

                                //gera log
                                u_GrLogZBE( msDate(), TIME(), cUserName, "TITULO NDI - PARCELA (EXECAUTO INCLUSAO FINA050 DEU ERRO - TITULO/PARCELA/TIPO " + SE2->E2_NUM+"/"+SE2->E2_PARCELA+"/"+SE2->E2_TIPO,"RH-ACORDOS","ADFIN121P",;
                                "DATA/VALOR " + DtoC(SE2->E2_VENCTO) + " / " + AllTrim(Str(SE2->E2_VALOR)), ComputerName(), LogUserName() )

                                If !lAuto
                                    MostraErro()
                                EndIf
                                DisarmTransaction() 
                                Break 

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
                                
                                // @ticket 68607 - Fernando Macieira - 26/04/2022 - RM - Acordos - despesa parcelamento CPC - Parcelado, a opção da primeira parcela ser 30% do valor do total e o restante escolher a quantidade de parcelas.
                                If !lPerc1P .or. (lPerc1P .and. ii >= 2)
                                    nDifParcelas := 0
                                EndIf
                                //

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

                        u_FixParcNDI(SE2->E2_NUM) // @ticket 18141 - Fernando Macieira - 29/03/2022 - RM - Acordos - Integração Protheus - Desativação função fix

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

    dDataBase := dDtBkp // @ticket 72340 - Fernando Macieira - 16/05/2022 - RM - Acordos - Inclusao de filial - Baixas futuras

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
    Local cFornece := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja    := GetMV("MV_#ZC7LOJ",,"01")
    Local aArea    := GetArea()

    cTipoNDI    := GetMV("MV_#ACOTIP",,"NDI")

    If Select("WorkSE2") > 0
        WorkSE2->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E2_PARCELA, E2_VENCREA
    cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
    cQuery += " WHERE E2_FILIAL='"+SE2->E2_FILIAL+"'
    cQuery += " AND E2_PREFIXO='"+SE2->E2_PREFIXO+"'
    cQuery += " AND E2_NUM='"+SE2->E2_NUM+"'
    cQuery += " AND E2_TIPO='"+cTipoNDI+"'
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
    Local cFornece := GetMV("MV_#ZC7SA2",,"001901")
    Local cLoja    := GetMV("MV_#ZC7LOJ",,"01")
    Local aDadPR   := {}
    Local cStatusRM := "Excluído em " + DtoC(msDate())

    cTipoPR  := GetMV("MV_#ZC7TIP",,"PR")
    cTipoNDI := GetMV("MV_#ACOTIP",,"NDI")

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

/*/{Protheus.doc} User Function FixParcNDI
    Garante/Corrige parcelas para serem sempre sequenciais 30 dias
    @type  Function
    @author FWNM
    @since 25/02/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function FixParcNDI(cNumNDI)

    Local nMes       := 0
    Local nMesAnt    := 0
    Local nDias      := 0
    Local nSumDias   := 0
    Local dNewVencto := CtoD("//")
    Local cPrefixo   := GetMV("MV_#ZC7PRE",,"GPE")
    Local aAreaSE2   := SE2->( GetArea() )
    Local aAreaZHB   := ZHB->( GetArea() )

    Default cNumNDI := ""

    cTipoNDI   := GetMV("MV_#ACOTIP",,"NDI")

    ZHB->( dbGoTop() )
    ZHB->( dbSetOrder(3) ) // ZHB_FILIAL, ZHB_NUM, R_E_C_N_O_, D_E_L_E_T_
    If ZHB->( dbSeek(FWxFilial("ZHB")+cNumNDI) )
    
        Do While ZHB->( !EOF() ) .and. ZHB->ZHB_FILIAL==FWxFilial("ZHB") .and. ZHB->ZHB_NUM==cNumNDI

            If !Empty(ZHB->ZHB_NUM) .and. ZHB->ZHB_PARCEL>1 //.and. ZHB->ZHB_GERPAR

                SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
                If SE2->( dbSeek(FWxFilial("SE2")+PadR(cPrefixo,TamSX3("E2_PREFIXO")[1])+ZHB->ZHB_NUM) )

                    nDias := 0

                    Do While SE2->( !EOF() ) .and. SE2->E2_FILIAL==FWxFilial("SE2") .and. AllTrim(SE2->E2_PREFIXO)==cPrefixo .and. SE2->E2_NUM==ZHB->ZHB_NUM

                        If AllTrim(SE2->E2_TIPO) == cTipoNDI

                            dNewVencto := ZHB->ZHB_VENCTO + nDias

                            // @ticket 70924 - Fernando Macieira - 06/04/2022 - RM - Acordos - verificar os acordos em meses que tem 31 dias, não podemos ter duas parcelas dentro do mesmo mês, exemplos os titulos final 3081 e 3087
                            nMes := Month(dNewVencto)

                            If nMes > 0 .and. nMesAnt > 0 .and. ZHB->ZHB_PARCEL > 1 .and. SE2->E2_PARCELA > "001"
                                Do While nMes == nMesAnt
                                    dNewVencto := dNewVencto + 1
                                    nMes := Month(dNewVencto)
                                EndDo
                            EndIf
                            //

                            If SE2->E2_VENCTO <> dNewVencto
                                RecLock("SE2", .F.)
                                    SE2->E2_VENCTO  := dNewVencto
                                    SE2->E2_VENCREA := DataValida(dNewVencto)
                                SE2->( msUnLock() )
                            EndIf
                            
                            nMesAnt := Month(dNewVencto) // // @ticket 70924 - Fernando Macieira - 06/04/2022 - RM - Acordos - verificar os acordos em meses que tem 31 dias, não podemos ter duas parcelas dentro do mesmo mês, exemplos os titulos final 3081 e 3087
                        
                            // @ticket 70440 - Fernando Macieira - 28/03/2022 - acordos lançados em fevereiro geraram a parcela de março para a data errada, não podera ser 30 dias nesse caso
                            nSumDias := 30
                            If Month(ZHB->ZHB_VENCTO) == 2 .and. ZHB->ZHB_PARCEL > 1 .and. SE2->E2_PARCELA == "001"
                                nSumDias := 28
                                If LastDay(ZHB->ZHB_VENCTO) == 29
                                    nSumDias := 29
                                EndIf
                            EndIf
                            //

                            nDias := nDias + nSumDias
                        
                        EndIf

                        SE2->( dbSkip() )
                
                    EndDo

                EndIf

            EndIf

            ZHB->( dbSkip() )

        EndDo

    EndIf

    RestArea( aAreaSE2 )
    RestArea( aAreaZHB )

Return

/*/{Protheus.doc} User Function FixParcNDI
    Garante/Corrige parcelas para serem sempre sequenciais 30 dias
    @type  Function
    @author FWNM
    @since 25/02/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function FixAllNDI()

    Local nDias      := 0
    Local nSumDias   := 0
    Local dNewVencto := CtoD("//")
    Local cPrefixo   := GetMV("MV_#ZC7PRE",,"GPE")
    
    cTipoNDI   := GetMV("MV_#ACOTIP",,"NDI")

    ZHB->( dbGoTop() )
    Do While ZHB->( !EOF() ) .and. ZHB->ZHB_FILIAL==FWxFilial("ZHB")

        If !Empty(ZHB->ZHB_NUM) .and. ZHB->ZHB_PARCEL>1 .and. ZHB->ZHB_GERPAR

            SE2->( dbSetOrder(1) ) // E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_
            If SE2->( dbSeek(FWxFilial("SE2")+PadR(cPrefixo,TamSX3("E2_PREFIXO")[1])+ZHB->ZHB_NUM) )

                nDias := 0

                Do While SE2->( !EOF() ) .and. SE2->E2_FILIAL==FWxFilial("SE2") .and. AllTrim(SE2->E2_PREFIXO)==cPrefixo .and. SE2->E2_NUM==ZHB->ZHB_NUM

                    If AllTrim(SE2->E2_TIPO) == cTipoNDI

                        dNewVencto := ZHB->ZHB_VENCTO + nDias

                        If SE2->E2_VENCTO <> dNewVencto
                            RecLock("SE2", .F.)
                                SE2->E2_VENCTO  := dNewVencto
                                SE2->E2_VENCREA := DataValida(dNewVencto)
                            SE2->( msUnLock() )
                        EndIf
                    
                        // @ticket 70440 - Fernando Macieira - 28/03/2022 - acordos lançados em fevereiro geraram a parcela de março para a data errada, não podera ser 30 dias nesse caso
                        nSumDias := 30
                        If Month(ZHB->ZHB_VENCTO) == 2 .and. ZHB->ZHB_PARCEL > 1 .and. SE2->E2_PARCELA == "001"
                            nSumDias := 28
                            If LastDay(ZHB->ZHB_VENCTO) == 29
                                nSumDias := 29
                            EndIf
                        EndIf
                        //
                        
                        nDias := nDias + nSumDias
                    
                    EndIf

                    SE2->( dbSkip() )
            
                EndDo

            EndIf

        EndIf

        ZHB->( dbSkip() )

    EndDo

    RestArea( aAreaSE2 )
    RestArea( aAreaZHB )

Return
