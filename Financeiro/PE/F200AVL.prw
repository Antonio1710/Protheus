#include "protheus.ch"
#include "topconn.ch"

// Opções do MessageBox
  #define MB_OK                       0
  #define MB_OKCANCEL                 1
  #define MB_YESNO                    4
  #define MB_ICONHAND                 16
  #define MB_ICONQUESTION             32
  #define MB_ICONEXCLAMATION          48
  #define MB_ICONASTERISK             64
  
  // Retornos possíveis do MessageBox
  #define IDOK			    1
  #define IDCANCEL		    2
  #define IDYES			    6
  #define IDNO			    7

/*/{Protheus.doc} User Function F200AVL
    O Array passado como parâmetro permitirá que qualquer exceção ou necessidade seja tratada através do ponto de entrada. No momento da chamada do ponto de entrada, as tabelas SEE e SA6 estão posicionadas. O ponto de entrada prevê retorno de um valor lógico (verdadeiro ou falso) sendo: quando retorno for verdadeiro, continua a execução da rotina normalmente; quando retorno for falso, a rotina executará um "Loop", ou seja, o processamento da linha atual do arquivo de retorno será abortado e a rotina continuará executando a partir da linha seguinte.
    Estrutura do Array:[01] - Número do Título[02] - Data da Baixa[03] - Tipo do Título[04] - Nosso Número[05] - Valor da Despesa[06] - Valor do Desconto[07] - Valor do Abatimento[08] - Valor Recebido[09] - Juros[10] - Multa[11] - Outras Despesas[12] - Valor do Crédito[13] - Data Crédito[14] - Ocorrência[15] - Motivo da Baixa[16] - Linha Inteira[17] - Data de Vencto
    Consulte: http://tdn.totvs.com/pages/releaseview.action?pageId=6071394
    @type  Function
    @author Fernando Macieira
    @since 08/04/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
    @history chamado 056247 - Fernando Macieira - 21/05/2020 - Melhoria para liberar crédito e estoque automaticamente quando C5_XWSPAGO = S
    @history chamado 056247 - Fernando Macieira - 27/05/2020 - Ajuste para liberar crédito e estoque automaticamente quando C5_XWSPAGO = S de todos os itens do pedido de venda
    @history chamado 059444 - Everson - 03/07/2020 - Limpeza da tabela de motivos de bloqueio. 
    @history Everson, 07/07/2020, Chamado T.I. - Tratamento para não bloquear pedido com flag Bradesco.
    @history chamado 059688 - Fernando Macieira - 22/07/2020 - || OS 061190 || FINANCEIRO || YEDA || 93029-5663 || PEDIDOS ANTECIPADOS
    @history chamado 059415 - Fernando Macieira - 23/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
    @history chamado 060029 - Fernando Macieira - 27/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
    @history chamado 060029 - Fernando Macieira - 28/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
    @history chamado TI     - Fernando Macieira - 03/08/2020 - E1_IDCNAB Duplicado
    @history ticket 102     - Fernando Macieira - 18/08/2020 - WS Bradesco - Gravar C5_XAPREAPR=L quando C5_XWSPAGO=S
    @history ticket 102     - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1
    @history ticket 745     - Fernando Macieira - 21/09/2020 - Implementação título PR
    @history ticket 745     - Fernando Macieira - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    @history ticket 70929   - Fernando Macieira - 08/04/2022 - Baixa retorno CNAB, TIPO PR, mesmo após baixado por STP
    @history ticket 71284   - Fernando Macieira - 12/04/2022 - Baixa Retorno CNAB - Tratar msg
/*/
User Function F200AVL()

    Local lProcessa  := .T.
    Local lAchouTit  := .f.
    Local cOcorre    := AllTrim(ParamIXB[1,14])
    Local cIDCNAB    := cNumTit
    Local aAreaSE1   := SE1->( GetArea() )
    Local aAreaSC5   := SC5->( GetArea() )
    Local aAreaFIE   := FIE->( GetArea() )
    Local cCodRetOk  := GetMV("MV_#WSOCOK",,"00")
    Local cCodRet69  := GetMV("MV_#WSOC69",,"69") // chamado 059688 - Fernando Macieira - 22/07/2020 - || OS 061190 || FINANCEIRO || YEDA || 93029-5663 || PEDIDOS ANTECIPADOS
    Local aPARAMIXB  := PARAMIXB[1]
    Local cKey1SE1WS := Subs(AllTrim(PARAMIXB[1,16]),71,11)
    Local cKey2SE1WS := Subs(AllTrim(PARAMIXB[1,16]),135,11)
    Local cKey3SE1WS := Subs(AllTrim(PARAMIXB[1,16]),117,10) // E1_IDCNAB // @history ticket 745 - Fernando Macieira - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    Local cQuery     := ""
    Local cFIEPEDIDO := ""
	
    // ticket 745 - Fernando Macieira - Implementação título PR - 21/09/2020
    Local cTipoE1    := GetMV("MV_#WSTIPO",,"PR") 
    Local lBxPROk    := .f.
    //

    // E1_IDCNAB // @history ticket 745 - Fernando Macieira - 08/10/2020 - Retorno CNAB Cobrança - Título não encontrado
    If AllTrim(cIDCNAB) <> AllTrim(cKey3SE1WS)
        cIDCNAB := cKey3SE1WS
    EndIf

    // E1_IDCNAB Duplicado - Chamado TI - Fernando Macieira - 03/08/2020
    lProcessa := ChkIDCNAB(cIDCNAB)

    If !lProcessa
        logZBE("E1_IDCNAB n. " + cIdCnab + " duplicado na base! Título " + SE1->E1_NUM + " não será baixado por segurança...")
        Alert("[F200AVL] - E1_IDCNAB n. " + cIDCNAB + " está duplicado! Este título não será baixado! Anote e verifique depois...")
        Return lProcessa
    EndIf
    //

    // @history ticket 70929   - Fernando Macieira - 08/04/2022 - Baixa retorno CNAB, TIPO PR, mesmo após baixado por STP
    If !Empty(AllTrim(cIDCNAB)) // @history ticket 71284   - Fernando Macieira - 12/04/2022 - Baixa Retorno CNAB - Tratar msg
        lProcessa := ChkBxSTP(cIDCNAB)

        If !lProcessa
            logZBE("E1_IDCNAB n. " + cIdCnab + " , tipo PR, já possui baixa por substituição E5_MOTBX = STP! Título " + SE1->E1_NUM + " não será baixado por segurança...")
            //Alert("[F200AVL] - E1_IDCNAB n. " + cIDCNAB + " , tipo PR, já possui baixa por substituição E5_MOTBX = STP! Este título não será baixado! Anote e verifique depois...") // @history ticket 71284   - Fernando Macieira - 12/04/2022 - Baixa Retorno CNAB - Tratar msg
            Return lProcessa
        EndIf
    EndIf

    If AllTrim(cBanco) == "237" .and. cOcorre == "06" // Bradesco WS

        If !Empty(AllTrim(cIDCNAB))

            SE1->( dbSetOrder(19) ) // E1_IDCNAB
            If SE1->( dbSeek(cIDCnab) )
            
                lAchouTit := .t.

                //If AllTrim(SE1->E1_TIPO) == "RA" .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // chamado 059688 - Fernando Macieira - 22/07/2020 - || OS 061190 || FINANCEIRO || YEDA || 93029-5663 || PEDIDOS ANTECIPADOS
                If AllTrim(SE1->E1_TIPO) == AllTrim(cTipoE1) .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) )  // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR

                    //@history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1
                    /*
                    FIE->( dbSetOrder(2) ) // FIE_FILIAL+FIE_CART+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO+FIE_PEDIDO
                    If FIE->( dbSeek(SE1->(E1_FILIAL+"R"+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
                    */
                      
                        cFIEPEDIDO := PadR(AllTrim(SE1->E1_NUM),TamSX3("E1_NUM")[1])

                        SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
                        If SC5->( dbSeek(SE1->E1_FILIAL+cFIEPEDIDO) )
                        //If SC5->( dbSeek(SE1->E1_FILIAL+FIE->FIE_PEDIDO) ) // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1

                            If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1
                            
                                lProcessa := .f. //chamado 060029 - Fernando Macieira - 28/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
                                
                                // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                msAguarde( { || lBxPROk := u_BxWSPR(.F., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA) }, "Substituindo boleto por (RA), PV n. " + SC5->C5_NUM )
                        
                                If lBxPROk

                                    RecLock("SC5", .f.)
                                        SC5->C5_XWSPAGO := "S"
                                        SC5->C5_XPREAPR := "L" //@history ticket 102 - Fernando Macieira - 18/08/2020 - WS Bradesco - Gravar C5_XAPREAPR=L quando C5_XWSPAGO=S
                                    SC5->( msUnLock() )

                                    logZBE(SC5->C5_NUM + " GRAVADO CAMPO C5_XWSPAGO=S PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04)) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020

                                    //Everson - 07/07/2020. Chamado T.I.
                                    //Everson - 03/07/2020. Chamado 059444.
                                    limpZBH(Alltrim(cValToChar(SC5->C5_NUM)))
                                    //

                                    // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020                            
                                    SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
                                    If SC9->( dbSeek(SC5->(C5_FILIAL+C5_NUM)) )
                                        Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 27/05/2020
                                            a450Grava(1,.T.,.T.)
                                            SC9->( dbSkip() )
                                        EndDo
                                        logZBE(SC5->C5_NUM + " FOI LIBERADO CREDITO/ESTOQUE PELO RETORNO CNAB ROTINA PADRAO A450GRAVA") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020
                                    EndIf
                                    //

                                Else
                                    
                                    // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                    logZBE( SC5->C5_NUM + " NAO GEROU RA! FATURAMENTO NAO LIBERADO PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04) )
                                    MessageBox( "Boleto n. " + SC5->C5_NUM + " não gerou RA! Faturamento não liberado...","WS Bradesco - Substituição Retorno CNAB PR -> RA", MB_ICONHAND )
                                
                                EndIf
                                //
                            
                            EndIf

                        EndIf
                    
                    //EndIf

                EndIf
            
            EndIf

        EndIf

        // Pesquiso por nosso número (E1_NUMBCO)
        If !lAchouTit

            // Chave 1
            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
            cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
            cQuery += " WHERE E1_NUMBCO='"+cKey1SE1WS+"'
            cQuery += " AND E1_NUMBCO<>''
            cQuery += " AND D_E_L_E_T_=''

            tcQuery cQuery New Alias "Work"

            SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
            If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )

                lAchouTit := .t.

                //If AllTrim(SE1->E1_TIPO) == "RA" .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // chamado 059688 - Fernando Macieira - 22/07/2020 - || OS 061190 || FINANCEIRO || YEDA || 93029-5663 || PEDIDOS ANTECIPADOS
                If AllTrim(SE1->E1_TIPO) == AllTrim(cTipoE1) .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // Ticket 745 - Implementação substituição PR x RA no PV de adiantamento - 21/09/2020

                    //@history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1
                    /*
                    FIE->( dbSetOrder(2) ) // FIE_FILIAL+FIE_CART+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO+FIE_PEDIDO
                    If FIE->( dbSeek(SE1->(E1_FILIAL+"R"+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
                    */

                        cFIEPEDIDO := PadR(AllTrim(SE1->E1_NUM),TamSX3("E1_NUM")[1])

                        SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
                        If SC5->( dbSeek(SE1->E1_FILIAL+cFIEPEDIDO) ) 
                        //If SC5->( dbSeek(SE1->E1_FILIAL+FIE->FIE_PEDIDO) ) // Cond Adiantamento = SIM // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1

                            If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1

                                lProcessa := .f. // chamado 060029 - Fernando Macieira - 28/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
                                
                                // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                msAguarde( { || lBxPROk := u_BxWSPR(.F., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA) }, "Substituindo boleto por (RA), PV n. " + SC5->C5_NUM )
                        
                                If lBxPROk

                                    RecLock("SC5", .f.)
                                        SC5->C5_XWSPAGO := "S"
                                        SC5->C5_XPREAPR := "L" //@history ticket 102 - Fernando Macieira - 18/08/2020 - WS Bradesco - Gravar C5_XAPREAPR=L quando C5_XWSPAGO=S
                                    SC5->( msUnLock() )

                                    logZBE(SC5->C5_NUM + " GRAVADO CAMPO C5_XWSPAGO=S PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04)) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020
                                    
                                    //Everson - 07/07/2020. Chamado T.I.
                                    //Everson - 03/07/2020. Chamado 059444.
                                    limpZBH(Alltrim(cValToChar(SC5->C5_NUM)))
                                    //

                                    // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020                            
                                    SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
                                    If SC9->( dbSeek(SC5->(C5_FILIAL+C5_NUM)) )
                                        Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 27/05/2020
                                            a450Grava(1,.T.,.T.)
                                            SC9->( dbSkip() )
                                        EndDo
                                        logZBE(SC5->C5_NUM + " FOI LIBERADO CREDITO/ESTOQUE PELO RETORNO CNAB ROTINA PADRAO A450GRAVA") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020
                                    EndIf
                                    //

                                Else
                                    
                                    // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                    logZBE( SC5->C5_NUM + " NAO GEROU RA! FATURAMENTO NAO LIBERADO PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04) )
                                    MessageBox( "Boleto n. " + SC5->C5_NUM + " não gerou RA! Faturamento não liberado...","WS Bradesco - Substituição Retorno CNAB PR -> RA", MB_ICONHAND )
                                
                                EndIf
                                //
    
                            EndIf

                        EndIf
                    
                    //EndIf

                EndIf

            EndIf

            If Select("Work") > 0
                Work->( dbCloseArea() )
            EndIf

            If !lAchouTit

                // Chave 2
                If Select("Work") > 0
                    Work->( dbCloseArea() )
                EndIf

                cQuery := " SELECT E1_NUMBCO, E1_IDCNAB, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, R_E_C_N_O_ RECNO
                cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
                cQuery += " WHERE E1_NUMBCO='"+cKey2SE1WS+"'
                cQuery += " AND E1_NUMBCO<>''
                cQuery += " AND D_E_L_E_T_=''

                tcQuery cQuery New Alias "Work"

                SE1->( dbSetOrder(1) ) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
                If SE1->( dbSeek( Work->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) ) )

                    lAchouTit := .t.

                    //If AllTrim(SE1->E1_TIPO) == "RA" .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // chamado 059688 - Fernando Macieira - 22/07/2020 - || OS 061190 || FINANCEIRO || YEDA || 93029-5663 || PEDIDOS ANTECIPADOS
                    If AllTrim(SE1->E1_TIPO) == AllTrim(cTipoE1) .and. !Empty(SE1->E1_XWSBRAC) .and. ( Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRetOk)) .or. Val(AllTrim(SE1->E1_XWSBRAC)) == Val(AllTrim(cCodRet69)) ) // ticket 745 - Implentação substituição PR x RA para PV de adiantamento - 21/09/2020

                        //@history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1
                        /*
                        FIE->( dbSetOrder(2) ) // FIE_FILIAL+FIE_CART+FIE_CLIENT+FIE_LOJA+FIE_PREFIX+FIE_NUM+FIE_PARCEL+FIE_TIPO+FIE_PEDIDO
                        If FIE->( dbSeek(SE1->(E1_FILIAL+"R"+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)) )
                        */

                            cFIEPEDIDO := PadR(AllTrim(SE1->E1_NUM),TamSX3("E1_NUM")[1])

                            SC5->( dbSetOrder(1) ) // C5_FILIAL+C5_NUM
                            If SC5->( dbSeek(SE1->E1_FILIAL+cFIEPEDIDO) ) 
                            //If SC5->( dbSeek(SE1->E1_FILIAL+FIE->FIE_PEDIDO) )  // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1

                                If AllTrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_CTRADT")) == "1" // Cond Adiantamento = SIM // @history ticket 102 - Fernando Macieira - 28/08/2020 - WS Bradesco - FIE deletados sem explicação, mesmo tendo C5 e E1

                                    lProcessa := .f. // chamado 060029 - Fernando Macieira - 28/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
                                    
                                    // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                    msAguarde( { || lBxPROk := u_BxWSPR(.F., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA) }, "Substituindo boleto por (RA), PV n. " + SC5->C5_NUM )
                            
                                    If lBxPROk

                                        RecLock("SC5", .f.)
                                            SC5->C5_XWSPAGO := "S"
                                            SC5->C5_XPREAPR := "L" //@history ticket 102 - Fernando Macieira - 18/08/2020 - WS Bradesco - Gravar C5_XAPREAPR=L quando C5_XWSPAGO=S
                                        SC5->( msUnLock() )

                                        logZBE(SC5->C5_NUM + " GRAVADO CAMPO C5_XWSPAGO=S PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04)) // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020

                                        //Everson - 07/07/2020. Chamado T.I.
                                        //Everson - 03/07/2020. Chamado 059444.
                                        limpZBH(Alltrim(cValToChar(SC5->C5_NUM)))
                                        //

                                        // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020                            
                                        SC9->( dbSetOrder(1) ) // C9_FILIAL, C9_PEDIDO, C9_ITEM, C9_SEQUEN, C9_PRODUTO, C9_BLEST, C9_BLCRED, R_E_C_N_O_, D_E_L_E_T_
                                        If SC9->( dbSeek(SC5->(C5_FILIAL+C5_NUM)) )
                                            Do While SC9->( !EOF() ) .and. SC9->C9_FILIAL==SC5->C5_FILIAL .and. SC9->C9_PEDIDO==SC5->C5_NUM // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 27/05/2020
                                                a450Grava(1,.T.,.T.)
                                                SC9->( dbSkip() )
                                            EndDo
                                            logZBE(SC5->C5_NUM + " FOI LIBERADO CREDITO/ESTOQUE PELO RETORNO CNAB ROTINA PADRAO A450GRAVA") // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - Fernando Macieira - 21/05/2020
                                        EndIf
                                        //

                                    Else
                                    
                                        // ticket 745 - Fernando Macieira - 21/09/2020 - Implementação título PR
                                        logZBE( SC5->C5_NUM + " NAO GEROU RA! FATURAMENTO NAO LIBERADO PELO RETORNO CNAB ARQ " + AllTrim(MV_PAR04) )
                                        MessageBox( "Boleto n. " + SC5->C5_NUM + " não gerou RA! Faturamento não liberado...","WS Bradesco - Substituição Retorno CNAB PR -> RA", MB_ICONHAND )
                                    
                                    EndIf
                                    //
                                
                                EndIf
                            
                            EndIf
                        
                        //EndIf

                    EndIf

                EndIf

                If Select("Work") > 0
                    Work->( dbCloseArea() )
                EndIf

            EndIf

            If !lAchouTit
                lProcessa := .f. // deixar falso qdo não encontrar... // chamado 059415 - Fernando Macieira - 23/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
                // chamado 060029 - Fernando Macieira - 27/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
                RestArea( aAreaSE1 )
                RestArea( aAreaSC5 )
                RestArea( aAreaFIE )
                //
            EndIf

        EndIf

    EndIf

    // chamado 060029 - Fernando Macieira - 27/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO    
    /*
    If !lAchouTit // chamado 059415 - Fernando Macieira - 23/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
        lProcessa := .f. // deixar falso qdo não encontrar... // chamado 059415 - Fernando Macieira - 23/07/2020 - || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
        RestArea( aAreaSE1 )
        RestArea( aAreaSC5 )
        RestArea( aAreaFIE )
    EndIf
    */
    
Return lProcessa

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
	@history chamado 056247 - Fernando Macieira - 21/05/2020 - Error log apenas via execauto na criação do arquivo e inclusao de ZBE em diversos pontos
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "F200AVL"  //Everson, 07/07/2020, Chamado T.I.
	ZBE->( msUnlock() )

Return

/*/{Protheus.doc} limpZBH
    Função apaga motivos de bloqueio da tabela ZBH.
    @type  Static Function
    @author Everson
    @since 03/07/2020
    @version 01
/*/
Static Function limpZBH(cPedido)
    
    //Variáveis.
    Local aArea := GetArea()
    Local cUpt  := ""

    //
    Default cPedido := ""

    //Everson, 07/07/2020, Chamado T.I.
    logZBE(cPedido + " INÍCIO EXCLUSÃO DE MENSAGENS DE BLOQUEIO - ZBH")

    //
    If Empty(cPedido)
        Conout( DToC(Date()) + " " + Time() + " F200AVL - limpZBH - variável cPedido vazia." )
        RestArea(aArea)
        Return Nil 

    EndIf
    
    //
    cUpt  := " UPDATE " + RetSqlName("ZBH") + " SET D_E_L_E_T_ = '*' WHERE ZBH_FILIAL = '" + FWxFilial("ZBH") + "' AND ZBH_PEDIDO = '" + cPedido + "' AND D_E_L_E_T_  = '' "

    //
    If TcSqlExec(cUpt) < 0
        Conout( DToC(Date()) + " " + Time() + " F200AVL - limpZBH - motivos de bloqueio NÃO excluídos (ZBH) " + cPedido + " " + TCSQLError() )
        logZBE(cPedido + " MENSAGENS DE BLOQUEIO NÃO FORAM EXCLUÍDAS - ZBH")

    Else 
        Conout( DToC(Date()) + " " + Time() + " F200AVL - limpZBH - motivos de bloqueio excluídos (ZBH) " + cPedido )
        logZBE(cPedido + " MENSAGENS DE BLOQUEIO EXCLUÍDAS - ZBH")

    EndIf

    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} Static Function ChkIDCNAB
    Não processar se existir 2 ou mais títulos com o mesmo IDCNAB
    @type  Function
    @author Fernando Macieira
    @since 03/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ChkIDCNAB(cIDCNAB)

    Local lRet   := .t.
    Local cQuery := ""

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E1_IDCNAB, COUNT(1) TT_IDCNAB
    cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
    cQuery += " WHERE D_E_L_E_T_=''
    cQuery += " AND E1_SALDO>0
    cQuery += " AND E1_IDCNAB='"+cIDCNAB+"'
    cQuery += " AND E1_IDCNAB<>''
    cQuery += " GROUP BY E1_IDCNAB
    cQuery += " HAVING COUNT(1) >= 2

    tcQuery cQuery New Alias "WorkIDCNAB"

    WorkIDCNAB->( dbGoTop() )

    If WorkIDCNAB->( !EOF() )
        lRet := .f.
    EndIf

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

Return lRet

/*/{Protheus.doc} Static Function ChkIDCNAB
    Não processar se existir 2 ou mais títulos com o mesmo IDCNAB
    @type  Function
    @author Fernando Macieira
    @since 08/04/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 70929 - Fernando Macieira - 08/04/2022 - Baixa retorno CNAB, TIPO PR, mesmo após baixado por STP
/*/
Static Function ChkBxSTP(cIDCNAB)

    Local lRet    := .t.
    Local cQuery  := ""

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

    cQuery := " SELECT TOP 1 E5_MOTBX
    cQuery += " FROM " + RetSqlName("SE5") + " SE5 (NOLOCK)
    cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 (NOLOCK) ON E1_FILIAL=E5_FILIAL AND E1_PREFIXO=E5_PREFIXO AND E1_NUM=E5_NUMERO AND E1_PARCELA=E5_PARCELA AND E1_TIPO=E5_TIPO AND E1_CLIENTE=E5_CLIFOR AND E1_LOJA=E5_LOJA AND SE5.D_E_L_E_T_=''
    cQuery += " WHERE E1_IDCNAB='"+cIDCNAB+"'
    cQuery += " AND E1_IDCNAB<>''
    cQuery += " AND E5_MOTBX='STP'
    cQuery += " AND E1_TIPO='PR'
    cQuery += " AND SE5.D_E_L_E_T_=''

    tcQuery cQuery New Alias "WorkIDCNAB"

    WorkIDCNAB->( dbGoTop() )
    If WorkIDCNAB->( !EOF() )
        lRet := .f.
    EndIf

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

Return lRet
