#Include "RwMake.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Totvs.CH"
#Include "Topconn.ch"  
#Include "FWBrowse.ch"   
/*/{Protheus.doc} User Function nomeFunction
    Monta as Cargas de entrega de Ração com leitura dos Romaneios do SAG por Integração Ch:029058.
    @type  Function
    @author Ricardo Lima
    @since 25/01/2019
    @version 01
    @history Ricardo Lima-05/02/2019-Ch:029058|inclusão do campo de numero de viagem do SAG               
    @history Ricardo Lima-06/02/2019-Ch:029058| Altera posição de atribuição de um novo numero de carga 
    @history Everson-06/03/2019-Ch:029058| Adicionada função cValToChar. 
    @history Everson-16/01/2020-Ch:054941-Adicionado tratamento para tipo de frete.  
    @history Everson-20/01/2020-Ch:054941-Corrigido para o tipo correto de frete.     
    @history Everson-14/02/2020-Ch:054941-Tratamento para geração de registro de carga de ração.  
    @history Everson-19/03/2020. Chamado 054941. Tratamento para gravar a distância percorrida de frete combinado e tabelas de região e região x produto.
    @history Abel   -28/09/2020. Ticket  000001. Tratamento para não executar para NF´s originadas do Ativo Fixo (Baixas e Transferências)
    /*/
User Function ADLOG052P(cTpGer,cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea := GetArea()

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Monta as Cargas de entrega de Ração com leitura dos Romaneios do SAG por Integração')

    //Abel   -06/07/2020. Chamado 058172. Tratamento para não executar para NF´s originadas do Ativo Fixo (Baixas e Transferências)
    IF !IsInCallStack('ATFA036') .AND. !IsInCallStack('ATFA060')
        //Everson-14/02/2020-Ch:054941.
        If cTpGer == "1"
            geraCarga(cEmpAnt , cFilAnt )

        ElseIf cTpGer == "2"
            geraFrt(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, @lStorFr, lAutoJob)

        EndIf
    ENDIF
    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraCarga
    Gera registro de carga tabela ZFD.
    @type  Static Function
    @author Ricardo Lima
    @since 25/01/2019
    @version 01
    /*/
Static Function geraCarga(cEmpAnt , cFilAnt )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cNumCrg   := ""
    Local cNumVgm   := ""
    Local lAutoJob  := .F.
    Local dDataIni  := ""
    Local sSeqCarg  := "0001"
    Local cLojaTrp  := ""
    Local cNomeTrp  := ""
    Local cNomeCli  := ""
    Local nKmMaior  := 0
    Local lKmMaior  := .F.
    Local cCPFMot   := "" //Everson-14/02/2020-Ch:054941.
    Local cNmMot    := "" //Everson-14/02/2020-Ch:054941.

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG052P - geraCarga" )
       
    // Ricardo Lima-06/02/2019-Ch:029058
    dDataIni := StrZero(Year(Date()-1),4)+"-"+StrZero(Month(Date()-1),2)+"-"+StrZero(Day(Date()-1),2)

    //
    cQuery := ""
    cQuery += " SELECT Data_Hora, Transportadora, Protheus, Loja, Placa, Ordem, Viagem, Empresa, TEXTPESA, Tara, Liquido, Fase, Integrado, TabelaFrete, KM__ROTA, Pedido "
    cQuery += " FROM SCSRV03.ADORO.dbo.VW_ADO_PESAGEM_FRETE_PROTHEUS "
    cQuery += " WHERE Data_Hora >= '" + dDataIni + "' "
    cQuery += " AND Ordem NOT IN ( "
    cQuery += "     SELECT ZFD_ORDSAG FROM "+RetSqlName("ZFD")+" WHERE ZFD_FILIAL = '"+FWxFilial("ZFD")+"' AND D_E_L_E_T_ = ' ' "
    cQuery += "     ) "
    cQuery += " ORDER BY Ordem, Viagem "
    
    //
    If Select("ROMSAG") > 0
        ROMSAG->(DbCloseArea())
        
    EndIf
    
    //
    TcQuery cQuery NEW Alias "ROMSAG"

    //
    While ROMSAG->(!Eof())   

        //
        DbSelectArea("SC5")
        SC5->(DbOrderNickName("PEDSAG0001"))
        If SC5->(DbSeek( FWxFilial("SC5") + Alltrim(ROMSAG->Pedido) ))

            //
            DbSelectArea("ZFD")
            ZFD->(DbSetOrder(5))
            If ! ZFD->(DbSeek( FWxFilial("ZFD") + SC5->C5_NUM ))
                
                // Ricardo Lima-06/02/2019-Ch:029058
                If cNumVgm <> Alltrim(Str(ROMSAG->Ordem))
                    If lKmMaior
                        TcSqlExec( " UPDATE "+RetSqlName("ZFD")+" SET ZFD_KMGER = "+Alltrim(Str(nKmMaior))+" WHERE ZFD_FILIAL = '"+FWxFilial("ZFD")+"' AND ZFD_COD = '"+cNumCrg+"' AND D_E_L_E_T_ = ' ' " )
                    
                    EndIf
                    
                    cNumCrg  := GetSXENum("ZFD","ZFD_COD")
                    sSeqCarg := '0001'
                    ConOut('Montagem da Carga: '+cNumCrg )
                    ConfirmSX8()
                    cNumVgm  := Alltrim(Str(ROMSAG->Ordem))
                    lKmMaior := .F.
                    nKmMaior := ROMSAG->KM__ROTA
                    
                EndIf
                
                //
                DbSelectArea("SA2")
                SA2->(DbSetOrder(1))
                If dbSeek( FWxFilial("SA2") + SC5->C5_CLIENTE + SC5->C5_LOJACLI )
                    cNomeCli := SA2->A2_NOME
                    
                EndIf

                //
                DbSelectArea("SA4")
                SA4->(DbSetOrder(1))
                If SA4->(DbSeek( FWxFilial("SA4") + SC5->C5_TRANSP ))
                    cLojaTrp := SA4->A4_LOJTRA
                    cNomeTrp := SA4->A4_NOME

                EndIf

                //Everson - 14/02/2020. Chamado 054941.
                DbSelectArea("ZV4")
                ZVC->(DbSetOrder(1))
                If ZVC->(DbSeek( FWxFilial("ZV4") + ROMSAG->Placa ))
                    cCPFMot  := Alltrim(cValToChar(ZV4->ZV4_CPF))
                    cNmMot   := Alltrim(cValToChar(ZV4->ZV4_MOTORI))

                EndIf
                
                //
                RecLock("ZFD",.T.)
                    ZFD->ZFD_FILIAL := FWxFilial("ZFD")
                    ZFD->ZFD_COD    := cNumCrg
                    ZFD->ZFD_SEQCAR := sSeqCarg
                    ZFD->ZFD_ROTEIR := SC5->C5_ROTEIRO
                    ZFD->ZFD_CAMINH := StrTran( ROMSAG->Placa,"-","" )
                    ZFD->ZFD_MOTORI := cCPFMot //Everson - 14/02/2020. Chamado 054941.
                    ZFD->ZFD_NOMEMO := cNmMot  //Everson - 14/02/2020. Chamado 054941.
                    ZFD->ZFD_PESO   := SC5->C5_PESOL
                    ZFD->ZFD_CAPVOL := SC5->C5_VOLUME1
                    ZFD->ZFD_FEZNF  := "N"
                    ZFD->ZFD_FLGUNI := "2"
                    ZFD->ZFD_TRANSP := SC5->C5_TRANSP
                    ZFD->ZFD_LOJTRA := cLojaTrp
                    ZFD->ZFD_NOMTRA := cNomeTrp
                    ZFD->ZFD_PEDIDO := Alltrim(cValToChar(SC5->C5_NUM))
                    ZFD->ZFD_CLIENT := Alltrim(cValToChar(SC5->C5_CLIENTE))
                    ZFD->ZFD_LOJA   := Alltrim(cValToChar(SC5->C5_LOJACLI))
                    ZFD->ZFD_NOMECL := cNomeCli
                    ZFD->ZFD_KMGER  := ROMSAG->KM__ROTA
                    ZFD->ZFD_VLRPDG := 0
                    ZFD->ZFD_FECHA  := "N"
                    ZFD->ZFD_NFDEV  := "N"
                    ZFD->ZFD_ORDSAG := cNumVgm  //Ricardo Lima-05/02/2019-Ch:029058
                    ZFD->ZFD_DTENTR := SC5->C5_DTENTR // Ricardo Lima-06/02/2019-Ch:029058
                    ZFD->ZFD_VA     := "5" //Everson - 16/01/2020. Chamado 054941. //Everson-20/01/2020-Ch:054941.
                MsUnlock()
                
                If ROMSAG->KM__ROTA > nKmMaior
                    nKmMaior := ROMSAG->KM__ROTA
                    lKmMaior := .T.
                    
                EndIf
                
                sSeqCarg := Soma1(sSeqCarg)
                
            EndIf
            
        EndIf
        
        ROMSAG->(dbSkip())
        
    End
    
    //
    If lKmMaior
        //Everson - 06/03/2019. Chamado 029058. Adicionada cValToChar.
        TcSqlExec( " UPDATE "+RetSqlName("ZFD")+" SET ZFD_KMGER = "+ cValToChar(nKmMaior) +" WHERE ZFD_FILIAL = '"+FWxFilial("ZFD")+"' AND ZFD_COD = '"+ cValToChar(cNumCrg) +"' AND D_E_L_E_T_ = ' ' " )
    
    EndIf

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} geraFrt
    Gera registro de frete tabela ZFA.
    @type  Static Function
    @author Everson
    @since 14/02/2020
    @version 01
    /*/
Static Function geraFrt(cEmpAnt , cFilAnt , F2DOC , F2SERIE , F2CLIENTE , F2LOJA  , C5NUM , cOpc , C5DTENTR, lStorFr, lAutoJob)
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variávies.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea     := GetArea()
    Local cTpFrt    := ""
    Local nVlrTab   := 0
    Local nVlrEnt   := 0
    Local nVlrUnFr  := 0
    Local nVlrMin   := 0
    Local nVlrTon   := 0
    Local cObsFrR   := ""
    Local cNumCrg   := ""
    Local cTpNF     := ""
    Local nVlrFrt   := 0

    //
    Private cOcorre     := GetMv("MV_#ADL462")
    Private cDescOcor   := ""
    Private cDCOcor     := ""
    Private lInser      := .T.
    Private cCarga      := ""
    Private dDtEntr     := Nil
    Private nNumEnt     := ""
    Private cPlaca      := ""
    Private cCodTran    := ""
    Private cLjTran     := ""
    Private cNmTran     := ""
    Private nKm         := 0
    Private nPesoL      := 0
    Private nPesoB      := 0
    Private nVolume     := 0
    Private cTabFrt     := ""
    Private cDescTab    := ""
    Private nVlr        := 0
    Private cTpCrg      := "5"
    Private cZFACod     := ""
    Private cOrigem     := "ADLOG052P"

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG052P - geraFrt" )

    //Valida parâmetros.
    If Empty(F2DOC) .Or. Empty(F2SERIE) .Or. Empty(C5NUM)
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - Não recebeu NF ou série " + F2DOC + " / " + F2SERIE )
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    DbSelectArea("ZFD")
    ZFD->(DbSetOrder(5))
    ZFD->(DbGoTop())
    If ! ZFD->( DbSeek( FWxFilial("ZFD") + C5NUM ) )
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - Pedido de venda não encontrado (ZFD) " + C5NUM )
        RestArea(aArea)
        Return Nil 

    EndIf  

    //Valida se o item da carga já está com flag.
    If Alltrim(ZFD->ZFD_FEZNF) == "S"
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - nota fiscal já processada " + F2DOC + " / " + F2SERIE )
        RestArea(aArea)
        Return Nil 

    EndIf

    //
    cNumCrg := Alltrim(cValToChar(ZFD->ZFD_COD))
    cPlaca  := Alltrim(cValToChar(ZFD->ZFD_CAMINH)) 

    //
    DbSelectArea("SC5")
    SC5->(DbSetOrder(1))
     If ! SC5->( DbSeek( FWxFilial("SC5") + C5NUM ) )
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - Pedido de venda não encontrado (SC5) " + C5NUM )
        RestArea(aArea)
        Return Nil 

    EndIf  

    //Obtém o tipo do pedido de saída.
    cTpNF := Alltrim(cValToChar(SC5->C5_TIPO)) 

    //Obtém dados da ocorrência.
    cDescOcor   := Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DESC")
    cDCOcor     := Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre, "ZF7_DBCD")

    //
    Begin Transaction

        //Marca registro como processado.
        RecLock("ZFD",.F.)
            ZFD->ZFD_NUMNF := F2DOC
            ZFD->ZFD_SERIE := F2SERIE
            ZFD->ZFD_FEZNF := "S"
        ZFD->(MsUnlock())
        
        //Obtém script sql com dados da carga.
        cQuery  := sqlZFD(cNumCrg,cTpCrg)

        //
        If Select("D_ZFD") > 0
            D_ZFD->(DbCloseArea())

        EndIf

        //
        TcQuery cQuery New Alias "D_ZFD"
        DbSelectArea("D_ZFD")
        D_ZFD->(DbGoTop())
        If D_ZFD->(Eof())
            Conout( DToC(Date()) + " " + Time() + " ADLOG052P - carga não localizada cNumCrg/cTpFrt" + cNumCrg + " / " + cTpCrg )
            DisarmTransaction()
            Break
            
        EndIf

        //Carrega dados da carga.
        cCarga  := Alltrim(D_ZFD->ZFD_COD)
        dDtEntr := SToD(D_ZFD->ZFD_DTENTR)
        nNumEnt := D_ZFD->NUMENT
        cPlaca  := Alltrim(D_ZFD->ZFD_CAMINH)
        cCodTran:= Alltrim(D_ZFD->ZFD_TRANSP)
        cLjTran := Alltrim(D_ZFD->ZFD_LOJTRA)
        cNmTran := Alltrim(D_ZFD->ZFD_NOMTRA)
        nKm     := Val(cValToChar(D_ZFD->ZFD_KMGER))
        nPesoL  := D_ZFD->C5_PESOL
        nPesoB  := D_ZFD->C5_PBRUTO
        nVolume := D_ZFD->C5_VOLUME1
        nTotKgC := D_ZFD->C5_PESOL

        //Carrega dados da tabela de frete.
        cQuery := " SELECT ZF5_TABCOD, ZF5_TABDES, ZF5_VLRENT, ZF5_TABSAI, ZF5_ANOVEI, ZF5_CAPKG, ZF5_VLRMIN, ZF6_TABPRC, ZF5_TPFRPG, ZF5_TABTDE, ZF6_TABKMI, ZF6_TABKMF "
        cQuery += " FROM " + RetSqlName("ZF5") + " ZF5 "
        cQuery += " INNER JOIN "+RetSqlName("ZF6")+" ZF6 ON ZF6_FILIAL=ZF5_FILIAL AND ZF6_TABCOD=ZF5_TABCOD AND ZF6.D_E_L_E_T_ = ' ' "
        cQuery += " WHERE ZF5_TABCOD IN ( "
        cQuery += "     SELECT ZV4_XFRET "
        cQuery += "     FROM " + RetSqlName("ZV4") + " ZV4 "
        cQuery += "     WHERE ZV4_PLACA IN ( "
        cQuery += "         SELECT C5_PLACA "
        cQuery += "         FROM " + RetSqlName("SC5") + " C5 "
        cQuery += "         WHERE C5_FILIAL = '"+FWxFilial("SC5")+"' "
        cQuery += "         AND C5_NUM = '" + C5NUM + "' "
        cQuery += "         AND C5.D_E_L_E_T_ = ' ' "
        cQuery += "         ) "
        cQuery += "     AND ZV4.D_E_L_E_T_ = ' ' "
        cQuery += "     ) "
        cQuery += " AND ZF5.D_E_L_E_T_ = ' ' "

        //
        If Select("ADLOG42D") > 0
            ADLOG42D->(DbCloseArea())

        EndIf

        //
        TcQuery cQuery NEW Alias "ADLOG42D"
        ADLOG42D->(DbGoTop())

        //
        nVlrTab     := ADLOG42D->ZF5_TABSAI
        nVlrEnt     := ADLOG42D->ZF5_VLRENT
        nVlrUnFr    := ADLOG42D->ZF6_TABPRC
        nVlrMin     := ADLOG42D->ZF5_VLRMIN
        cTabFrt     := Alltrim(ADLOG42D->ZF5_TABCOD)
        cDescTab    := ADLOG42D->ZF5_TABDES
        cTpFrt      := ADLOG42D->ZF5_TPFRPG
        nVlrTon     := Val(cValToChar(ADLOG42D->ZF5_TABTDE)) 
        
        //
        If Empty(cTabFrt)
            Conout( DToC(Date()) + " " + Time() + " Veículo sem tabela de frete cadastrada", "placa " + cPlaca )
            logZBE( "Veículo sem tabela de frete cadastrada", "placa " + cPlaca )
            DisarmTransaction()
            Break
            
        EndIf
        
        //
        While ADLOG42D->(!Eof())

            //
            Conout( DToC(Date()) + " " + Time() + " ADLOG052P - geraFrt - nKm " + cValToChar(nKm) )

            If nKm >= ADLOG42D->ZF6_TABKMI .And. nKm <= ADLOG42D->ZF6_TABKMF
                nVlrUnFr := ADLOG42D->ZF6_TABPRC

            EndIf

            ADLOG42D->(DbSkip())

        End
        
        //
        ADLOG42D->(DbGoTop())

        //
        nVlrFrt += nVlrTab //Soma-se ao valor de frete, o valor de saída mínima.
        nVlrFrt += ( nVlrEnt * nNumEnt ) //Soma-se ao valor de frete, o valor por entrega vezes a quantidade de entregas.
        
        //
        If cTpFrt = "R" //Frete por região.
            cObsFrR := ""
            nVlrFrt += vlrReg(cNumCrg,dDtEntr,cTabFrt,@cObsFrR,cTpNF,@nKm)
            
        ElseIf cTpFrt = "P" //Frete por região x produto.
            cObsFrR := ""
            nVlrFrt += (nTotKgC/1000) * vlrRegProd(cNumCrg,dDtEntr,cTabFrt,@cObsFrR,cTpNF,@nKm)
                                
        Else
            nVlrFrt += ( nKm * nVlrUnFr )
        
        EndIf

        //
        DbSelectArea("ZFA")
        ZFA->(DbSetOrder(1))
        ZFA->(DbGoTop())
        If ZFA->( DbSeek( FWxFilial("ZFA") + cNumCrg ) )
            cZFACod := Alltrim(ZFA->ZFA_COD)
            lInser   := .F.     

        EndIf

        //
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - geraFrt - cTpFrt " + cValToChar(cTpFrt) )

        //
		If cTpFrt == "F"
			nVlr  := Iif( nVlrTab < nVlrMin, nVlrMin, nVlrTab )

		ElseIf ( cTpFrt == "V" .Or. cTpFrt == "R" .Or. 	cTpFrt == "P" )
			nVlr := Iif( nVlrFrt < nVlrMin, nVlrMin, nVlrFrt )
			
		ElseIf 	cTpFrt == "T"
			nVlr	:= Iif( ((nTotKgC/1000) * nVlrTon) < nVlrMin, nVlrMin, ((nTotKgC/1000) * nVlrTon) )
			
		Else
			nVlr	:= 0
			cObsFrR	:= "VLR N/D. VERIFIQUE O TIPO DE FRETE NO CADASTRO DA TABELA DE FRETE."

		EndIf

        //
        grvZFA()

    End Transaction

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} sqlZFD
    Script sql com informações da carga/roteiro.
    @type  Static Function
    @author Everson
    @since 14/02/2020
    @version 01
    /*/
Static Function sqlZFD(cNumCrg,cTpCrg)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Local aArea  := GetArea()
    Local cQuery := ""

    //
    cQuery := ""
    cQuery += " SELECT    " 
    cQuery += " ZFD_VA, " 
    cQuery += " ZFD_COD, " 
    cQuery += " ZFD_DTENTR, " 
    cQuery += " ZFD_CAMINH, " 
    cQuery += " ZFD_TRANSP, " 
    cQuery += " ZFD_LOJTRA, " 
    cQuery += " ZFD_NOMTRA, " 
    cQuery += " SUM(ZFD_KMGER) AS ZFD_KMGER, " 
    cQuery += " COUNT(DISTINCT C5_NUM) AS NUMENT, " 
    cQuery += " SUM(C5_PESOL) AS C5_PESOL, " 
    cQuery += " SUM(C5_PBRUTO) AS C5_PBRUTO, " 
    cQuery += " SUM(C5_VOLUME1) AS C5_VOLUME1, " 
    cQuery += " SUM(ZFD_VLRFRT) AS ZFD_VLRFRT " 
    cQuery += " FROM   " 
    cQuery += " " + RetSqlName("ZFD") + "  (NOLOCK) AS ZFD " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 ON " 
    cQuery += " ZFD_FILIAL = C5_FILIAL " 
    cQuery += " AND ZFD_PEDIDO = C5_NUM   " 
    cQuery += " WHERE   " 
    cQuery += " ZFD_FILIAL = '" + FWxFilial("ZFD") + "'   " 
    cQuery += " AND ZFD_COD = '" + cNumCrg + "'   " 
    cQuery += " AND ZFD_VA = '" + cTpCrg + "' " 
    cQuery += " AND ZFD_FEZNF = 'S' "
    cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
    cQuery += " AND SC5.D_E_L_E_T_ = '' " 
    cQuery += " GROUP BY " 
    cQuery += " ZFD_VA, " 
    cQuery += " ZFD_COD, " 
    cQuery += " ZFD_DTENTR, " 
    cQuery += " ZFD_CAMINH, " 
    cQuery += " ZFD_TRANSP, " 
    cQuery += " ZFD_LOJTRA, " 
    cQuery += " ZFD_NOMTRA " 

    //
    Conout( DToC(Date()) + " " + Time() + " ADLOG052P - sqlZFD - cQuery " + cQuery )

Return cQuery
/*/{Protheus.doc} vlrRegProd
	Valor por tabela de região x produto. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 14/02/2019
	@version 01
	/*/
Static Function vlrRegProd(cNumCrg,dDtEntr,cTabFrt,cObs,cTpNF,nKm)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nVlr		:= 0
	
	Default cObs	:= ""

	//
	If cTpNF = "B" 
	
		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " TOP 1 RTRIM(LTRIM(A2_EST)) + '-' + RTRIM(LTRIM(A2_COD_MUN)) + '-' + RTRIM(LTRIM(TABREGCID.ZF6_NUMCID)) + '-' + RTRIM(LTRIM(C6_PRODUTO)) AS NM_FRM_PG, " 
		cQuery += " TABREGCID.VLR_CID AS VLR_FRT, TABREGCID.KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
		cQuery += " C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SA2") + " (NOLOCK) AS SA2 ON " 
		cQuery += " C5_CLIENTE = A2_COD " 
		cQuery += " AND C5_LOJACLI = A2_LOJA " 
		cQuery += " INNER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_PRODUT, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = ''  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A2_EST = TABREGCID.ZF6_UF " 
		cQuery += " AND A2_COD_MUN = TABREGCID.ZF6_CIDADE " 
		cQuery += " AND C6_PRODUTO = TABREGCID.ZF6_PRODUT "
        cQuery += " INNER JOIN 
        cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON
        cQuery += " C5_FILIAL = ZFD_FILIAL
        cQuery += " AND C5_NUM = ZFD_PEDIDO "
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND ZFD_COD = '" + cValToChar(cNumCrg) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 	
		cQuery += " AND SA2.D_E_L_E_T_ = '' "
        cQuery += " AND ZFD.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY VLR_FRT DESC "
			
	Else
	
		//
		cQuery := ""
		cQuery += " SELECT " 
		cQuery += " TOP 1 RTRIM(LTRIM(A1_EST)) + '-' + RTRIM(LTRIM(A1_COD_MUN)) + '-' + RTRIM(LTRIM(TABREGCID.ZF6_NUMCID)) + '-' + RTRIM(LTRIM(C6_PRODUTO)) AS NM_FRM_PG, " 
		cQuery += " TABREGCID.VLR_CID AS VLR_FRT, TABREGCID.KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SC6") + " (NOLOCK) AS SC6 ON " 
		cQuery += " C5_FILIAL = C6_FILIAL " 
		cQuery += " AND C5_NUM = C6_NUM " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("SA1") + " (NOLOCK) AS SA1 ON " 
		cQuery += " C5_CLIENTE = A1_COD " 
		cQuery += " AND C5_LOJACLI = A1_LOJA " 
		cQuery += " INNER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_PRODUT, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = ''  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A1_ESTE = TABREGCID.ZF6_UF "
		cQuery += " AND A1_CODMUNE = TABREGCID.ZF6_CIDADE " 
		cQuery += " AND C6_PRODUTO = TABREGCID.ZF6_PRODUT " 
        cQuery += " INNER JOIN 
        cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON
        cQuery += " C5_FILIAL = ZFD_FILIAL
        cQuery += " AND C5_NUM = ZFD_PEDIDO "
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND ZFD_COD = '" + cValToChar(cNumCrg) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND SC6.D_E_L_E_T_ = '' " 
		cQuery += " AND SA1.D_E_L_E_T_ = '' "
        cQuery += " AND ZFD.D_E_L_E_T_ = '' "
		cQuery += " ORDER BY VLR_FRT DESC "
	
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG052P - vlrRegProd - cQuery " + cQuery )
	
	//
	If Select("VLR_REGP") > 0
		VLR_REGP->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "VLR_REGP"
	DbSelectArea("VLR_REGP")
		nVlr := Val(cValToChar(VLR_REGP->VLR_FRT))
		cObs := Alltrim(VLR_REGP->NM_FRM_PG)

        //
        If nKm <= 0
            nKm := Val(cValToChar(VLR_REGP->KM_ROD)) //Everson - 19/03/2020. Chamado 054941.

        EndIf

	VLR_REGP->(DbCloseArea())

	//
	RestArea(aArea)
	
Return nVlr
/*/{Protheus.doc} vlrReg
	Valor por tabela de região. Chamado 044314. 
	@type  Static Function
	@author Everson
	@since 14/02/2019
	@version 01
	/*/
Static Function vlrReg(cNumCrg,dDtEntr,cTabFrt,cObs,cTpNF,nKm)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local nVlr		:= 0
	
	Default cObs	:= ""

	//
	If cTpNF = "B"
	
		//
		cQuery := ""
		cQuery += " SELECT TOP 1 " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " ' 2- PAGO POR ESTADO '  ELSE  " 
		cQuery += " ' 1- PAGO POR CIDADE '  END AS FRM_PG, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " TABREGEST.ZF6_UF     ELSE  " 
		cQuery += " TABREGCID.ZF6_CIDADE + '-' + TABREGCID.ZF6_NUMCID  END AS NM_FRM_PG, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " ISNULL(TABREGEST.VLR_EST,0) ELSE ISNULL(TABREGCID.VLR_CID,0) END AS VLR_EST, " 
        cQuery += " ISNULL(CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN TABREGEST.KM_ROD ELSE TABREGCID.KM_ROD END,0) AS KM_ROD " //Km rodado. //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON " 
		cQuery += " C5_FILIAL = ZFD_FILIAL " 
		cQuery += " AND C5_NUM = ZFD_PEDIDO " 
		cQuery += " INNER JOIN " 
		cQuery += " ( SELECT * FROM " + RetSqlName("SA2") + " (NOLOCK) AS SA2 WHERE SA2.D_E_L_E_T_ = '' ) AS SA2 ON " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " C5_CLIENTE = A2_COD " 
		cQuery += " AND C5_LOJACLI = A2_LOJA " 
		cQuery += " LEFT OUTER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " TOP 1 ZF6_UF, ZF6_VLRREG AS VLR_EST, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE = '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5_TPFRPG = 'R' "
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY VLR_EST DESC " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " ) AS TABREGEST ON " 
		cQuery += " A2_EST = TABREGEST.ZF6_UF " 
		cQuery += " LEFT OUTER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " TOP 1 ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5_TPFRPG = 'R' "
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY VLR_CID DESC " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A2_EST = TABREGCID.ZF6_UF " 
		cQuery += " AND A2_COD_MUN = TABREGCID.ZF6_CIDADE "    
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' " 
		cQuery += " AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND ZFD_COD = '" + cValToChar(cNumCrg) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY FRM_PG, VLR_EST DESC "		
	
	Else
		
		//
		cQuery := ""
		cQuery += " SELECT TOP 1 " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " ' 2- PAGO POR ESTADO '  ELSE  " 
		cQuery += " ' 1- PAGO POR CIDADE '  END AS FRM_PG, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " TABREGEST.ZF6_UF     ELSE  " 
		cQuery += " TABREGCID.ZF6_CIDADE + '-' + TABREGCID.ZF6_NUMCID  END AS NM_FRM_PG, " 
		cQuery += " CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN  " 
		cQuery += " ISNULL(TABREGEST.VLR_EST,0) ELSE ISNULL(TABREGCID.VLR_CID,0) END AS VLR_EST, " 
        cQuery += " ISNULL(CASE WHEN ISNULL(TABREGCID.VLR_CID,0) <= 0 THEN TABREGEST.KM_ROD ELSE TABREGCID.KM_ROD END,0) AS KM_ROD " //Km rodado. //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM " 
		cQuery += " " + RetSqlName("SC5") + " (NOLOCK) AS SC5 " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZFD") + " (NOLOCK) AS ZFD ON " 
		cQuery += " C5_FILIAL = ZFD_FILIAL " 
		cQuery += " AND C5_NUM = ZFD_PEDIDO " 
		cQuery += " INNER JOIN " 
		cQuery += " ( SELECT * FROM " + RetSqlName("SA1") + " (NOLOCK) AS SA1 WHERE SA1.D_E_L_E_T_ = '' ) AS SA1 ON " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " C5_CLIENTE = A1_COD " 
		cQuery += " AND C5_LOJACLI = A1_LOJA " 
		cQuery += " LEFT OUTER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " TOP 1 ZF6_UF, ZF6_VLRREG AS VLR_EST, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941.
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE = '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5_TPFRPG = 'R' "
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY VLR_EST DESC " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " ) AS TABREGEST ON " 
		cQuery += " C5_EST = TABREGEST.ZF6_UF " 
		cQuery += " LEFT OUTER JOIN " 
		cQuery += " ( " 
		cQuery += " SELECT  " 
		cQuery += " TOP 1 ZF6_UF, ZF6_CIDADE, ZF6_NUMCID, ZF6_VLRREG AS VLR_CID, ZF6_TABKMF AS KM_ROD " //Everson - 19/03/2020. Chamado 054941. 
		cQuery += " FROM  " 
		cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5  " 
		cQuery += " INNER JOIN " 
		cQuery += " " + RetSqlName("ZF6") + " (NOLOCK) AS ZF6 ON " 
		cQuery += " ZF5_FILIAL = ZF6_FILIAL " 
		cQuery += " AND ZF5_TABCOD = ZF6_TABCOD " 
		cQuery += " WHERE  " 
		cQuery += " ZF5_FILIAL = '" + FWxFilial("ZF5") + "'  " 
		cQuery += " AND ZF6_CIDADE <> '' " 
		cQuery += " AND ZF5_TABCOD = '" + cValToChar(cTabFrt) + "'  " 
		cQuery += " AND ZF5_TPFRPG = 'R' "
		cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZF6.D_E_L_E_T_ = '' " 
        cQuery += " ORDER BY VLR_CID DESC " //Everson, 19/03/2020. Chamado 054941.
		cQuery += " ) AS TABREGCID ON " 
		cQuery += " A1_ESTE = TABREGCID.ZF6_UF " 
		cQuery += " WHERE " 
		cQuery += " C5_FILIAL = '" + FWxFilial("SC5") + "' "
		cQuery += " AND ZFD_DTENTR = '" + DToS(dDtEntr) + "' " 
		cQuery += " AND ZFD_COD = '" + cValToChar(cNumCrg) + "' " 
		cQuery += " AND C5_NOTA <> '' " 
		cQuery += " AND C5_SERIE <> '' " 
		cQuery += " AND SC5.D_E_L_E_T_ = '' " 
		cQuery += " AND ZFD.D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY FRM_PG, VLR_EST DESC " 
	
	EndIf
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG052P - vlrReg - cQuery " + cQuery )
	
	//
	If Select("VLR_REG") > 0
		VLR_REG->(DbCloseArea())
		
	EndIf
	
	//
	TcQuery cQuery New Alias "VLR_REG"
	DbSelectArea("VLR_REG")
		nVlr := Val(cValToChar(VLR_REG->VLR_EST))
		cObs := Alltrim(VLR_REG->FRM_PG) + " " + Alltrim(VLR_REG->NM_FRM_PG)

        //
        If nKm <= 0
            nKm := Val(cValToChar(VLR_REG->KM_ROD)) //Everson - 19/03/2020. Chamado 054941.

        EndIf

	VLR_REG->(DbCloseArea())

	//
	RestArea(aArea)
	
Return nVlr
/*/{Protheus.doc} grvZFA
    Grava lançamento na tabela ZFA.
    @type  Static Function
    @author Everson
    @since 14/02/2020
    @version 01
    /*/
Static Function grvZFA()
	
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    Local aArea     := GetArea()
    Local lRet      := .T.

    //
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

    //
	Begin Transaction

        //
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - grvZFA - lInser " + cValToChar(lInser) )
        Conout( DToC(Date()) + " " + Time() + " ADLOG052P - grvZFA - cPlaca " + cValToChar(cPlaca) )

        //
        oModel:= FwLoadModel ("ADLOG040P")

        //
        If lInser
            oModel:SetOperation(MODEL_OPERATION_INSERT)

        Else
            oModel:SetOperation(MODEL_OPERATION_UPDATE)

        EndIf
        
        //
        oModel:Activate() 

        //
        oModel:SetValue("ZFAMASTER","ZFA_VA"		,cTpCrg)
        oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")

        //
        If ! lInser
            oModel:SetValue("ZFAMASTER","ZFA_COD"	,cZFACod)         
            
        EndIf

        //
        oModel:SetValue("ZFAMASTER","ZFA_CARGA"	  	,cCarga)
        oModel:SetValue("ZFAMASTER","ZFA_DTENTR"	,dDtEntr)
        oModel:SetValue("ZFAMASTER","ZFA_ROTEIR"	,cCarga)
        oModel:SetValue("ZFAMASTER","ZFA_NUMENT"	,nNumEnt)
        oModel:SetValue("ZFAMASTER","ZFA_VEICUL"	,cPlaca)
        oModel:SetValue("ZFAMASTER","ZFA_TRANSP"	,cCodTran)
        oModel:SetValue("ZFAMASTER","ZFA_LOJTRA"	,cLjTran)
        oModel:SetValue("ZFAMASTER","ZFA_NMTRAN"	,cNmTran)
        oModel:SetValue("ZFAMASTER","ZFA_KMTOT"		,nKm)
        oModel:SetValue("ZFAMASTER","ZFA_CARCX"		,nVolume)
        oModel:SetValue("ZFAMASTER","ZFA_CARKG"		,nPesoL)
        oModel:SetValue("ZFAMASTER","ZFA_KGBT"		,nPesoB)
        oModel:SetValue("ZFAMASTER","ZFA_TABFRT"	,cTabFrt)
        oModel:SetValue("ZFAMASTER","ZFA_DSCFRT"	,cDescTab)
        oModel:SetValue("ZFAMASTER","ZFA_TPFRT"		,"C")
        oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,dDtEntr)
        oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorre)
        oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDescOcor)
        oModel:SetValue("ZFAMASTER","ZFA_DC"		,cDCOcor)
        oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,cPlaca)
        oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,cCodTran)
        oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,cLjTran)
        oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,cNmTran)
        oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlr)
        oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
        oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
        oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
        oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
        oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
        oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(Val(cTpCrg))) 
        oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,cOrigem)		

        //
        If oModel:VldData()
            oModel:CommitData()

        Else
            lRet := .F.
            aError := oModel:GetErrorMessage()
            Conout( DToC(Date()) + " " + Time() + " ADLOG052P - ERRO - GetErrorMessage " )
            Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
            Help(Nil, Nil, "Função ADLOG052P(ADLOG052P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

        EndIf 
        
        //
        oModel:DeActivate()
        oModel:Destroy()
        oModel := Nil

	End Transaction

    // 
    RestArea(aArea)

Return lRet
/*/{Protheus.doc} logZBE
    Rotina para gerar log na tabela ZBE. Chamado 044314. 
    @type  Static Function
    @author Everson
    @since 14/02/2020
    @version 01
    /*/
Static Function logZBE(cLog,cParam)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea	:= GetArea()

	//
	DbSelectArea("ZBE")
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	With xFilial("ZBE")
		Replace ZBE_DATA 	   	With dDataBase
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cLog
		Replace ZBE_PARAME 		With cParam
		Replace ZBE_MODULO	    With "LOGISTICA"
		Replace ZBE_ROTINA	    With "ADLOG052P" 
	MsUnlock()

	//
	RestArea(aArea)

Return Nil
