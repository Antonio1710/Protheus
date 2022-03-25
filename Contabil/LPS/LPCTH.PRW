#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function LPCTH
    Função utilizada na CT5, campos de classe de valor

    Regra: 
    Se estiver:
•	Entre as contas 131210001 e 131220009 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997;
•	Entre as contas 131240001 e 131250003 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997;
•	Entre as contas 131270001 e 131270003 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997.
*** centro de custo da nota fiscal.

    @type  Function
    @author FWNM
    @since 14/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 055749 || OS 057158 || CONTROLADORIA || ANDRE || 8386 || CLASSE DE VALOR SIG
    @Ticket 69338 	- Leonardo P. Monteiro - 	Ajuste no CC para 5131 quando o produto for '190590'. Alterar LanÇamento PadrÃo 641-008 - Quirera.
/*/
User Function LPCTH(cTab, cEntidade)

    Local cClasse := ""
    Local cCCusto := ""
    Local aAreaAtu := GetArea()
    Local aAreaSD2 := SD2->( GetArea() )
    Local aAreaSCP := SCP->( GetArea() )
    Local aAreaSN1 := SN1->( GetArea() )

    Default cTab := cEntidade := ""

    // Define evento/tabela/lp para buscar dados condicionais
    If AllTrim(cTab) == "SD1" // LPs 640, 641, 650 e 655 (COMPRAS E DEV COMPRAS)
        cClasse := SD1->D1_PROJETO
        cCCusto := AllTrim(SD1->D1_CC)

    ElseIf AllTrim(cTab) == "SDE" // LP 651 (RATEIO CC)
        cClasse := SDE->DE_CLVL
        cCCusto := AllTrim(SDE->DE_CC)

    ElseIf AllTrim(cTab) == "SD3" // LPs 666 e 668 (SOLICITACAO ARMAZEM)
        cClasse := Posicione("SCP",1,SD3->(D3_FILIAL+D3_NUMSA+D3_ITEMSA),"CP_CONPRJ")
        
        If AllTrim(cEntidade) == "DEBITO"
            cCCusto := AllTrim(CTK->CTK_CCD)
        ElseIf AllTrim(cEntidade) == "CREDITO"
            cCCusto := AllTrim(CTK->CTK_CCC)
        EndIf

    ElseIf AllTrim(cTab) == "SN1" // LP 812 BAIXA ADIANTAMENTOS PROJETOS

        cClasse := SN1->N1_PROJETO
        If Empty(cClasse)
            // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD                                                                                                     
            SD1->(dbOrderNickName("D1INTERFAC"))
            If SD1->( dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_NFITEM)) )
                cClasse := SD1->D1_PROJETO
            EndIf
        EndIf

        // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD                                                                                                     
        SD1->(dbOrderNickName("D1INTERFAC"))
        If SD1->( dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_NFITEM)) )
            cCCusto := SD1->D1_CC
        EndIf

        If Empty(cCCusto)
            If AllTrim(cEntidade) == "DEBITO"
                cCCusto := AllTrim(CTK->CTK_CCD)
            ElseIf AllTrim(cEntidade) == "CREDITO"
                cCCusto := AllTrim(CTK->CTK_CCC)
            EndIf
        EndIf

    EndIf

    // Define classe de valor da excecao
    If AllTrim(cCCusto) < '9000' .or. AllTrim(cCCusto) > '9998'
    
        // LPs Debito
        If AllTrim(cEntidade) == "DEBITO"

            If (AllTrim(CTK->CTK_DEBITO) >= '131210001' .and. AllTrim(CTK->CTK_DEBITO) <= '131220009') .or.;
               (AllTrim(CTK->CTK_DEBITO) >= '131240001' .and. AllTrim(CTK->CTK_DEBITO) <= '131250003') .or.;
               (AllTrim(CTK->CTK_DEBITO) >= '131270001' .and. AllTrim(CTK->CTK_DEBITO) <= '131270003')
                cClasse := "999999997"
            EndIf

        // LPs Credito
        ElseIf AllTrim(cEntidade) == "CREDITO"

            If (AllTrim(CTK->CTK_CREDIT) >= '131210001' .and. AllTrim(CTK->CTK_CREDIT) <= '131220009') .or.;
               (AllTrim(CTK->CTK_CREDIT) >= '131240001' .and. AllTrim(CTK->CTK_CREDIT) <= '131250003') .or.;
               (AllTrim(CTK->CTK_CREDIT) >= '131270001' .and. AllTrim(CTK->CTK_CREDIT) <= '131270003')
                cClasse := "999999997"
            EndIf
        
        EndIf

    EndIf

    RestArea( aAreaAtu )
    RestArea( aAreaSD2 )
    RestArea( aAreaSCP )
    RestArea( aAreaSN1 )
    
Return cClasse

/*/{Protheus.doc} User Function LPCTHCC
    Função utilizada na CT5, campos de CCustos, atrelados a classe de valor

    Regra: 
    Se estiver:
•	Entre as contas 131210001 e 131220009 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997;
•	Entre as contas 131240001 e 131250003 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997;
•	Entre as contas 131270001 e 131270003 e o centro de custo for diferente de 9000 a 9998, utilizar classe de valor 999999997.
*** centro de custo da nota fiscal.

    @type  Function
    @author FWNM
    @since 23/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 055749 || OS 057158 || CONTROLADORIA || ANDRE || 8386 || CLASSE DE VALOR SIG
    @history Ticket 69338 	- Leonardo P. Monteiro - 	Ajuste no CC para 5131 quando o produto for '190590'. Alterar Lançamento Padrão 641-008 - Quirera.
/*/
User Function LPCTHCC(cTab, cEntidade)

    Local cCCusto := ""
    Local cConta  := ""
    Local aAreaAtu := GetArea()
    Local aAreaSD2 := SD2->( GetArea() )
    Local aAreaSCP := SCP->( GetArea() )
    Local aAreaSN1 := SN1->( GetArea() )

    Default cTab := cEntidade := ""

    If AllTrim(cEntidade) == "DEBITO"
        cConta := CTK->CTK_DEBITO
    ElseIf AllTrim(cEntidade) == "CREDITO"
        cConta := CTK->CTK_CREDIT
    EndIf

    If Left(AllTrim(cConta),1) $ "3|4" .or. (;
        (AllTrim(cConta) >= '131210001' .and. AllTrim(cConta) <= '131220009') .or.;
        (AllTrim(cConta) >= '131240001' .and. AllTrim(cConta) <= '131250003') .or.;
        (AllTrim(cConta) >= '131270001' .and. AllTrim(cConta) <= '131270003') )

        // Define evento/tabela/lp para buscar dados condicionais
        If AllTrim(cTab) == "SD1" // LPs 640, 641, 650 e 655 (COMPRAS E DEV COMPRAS)
            cCCusto := AllTrim(SD1->D1_CC)

            If Empty(cCCusto) .and. AllTrim(SD1->D1_TIPO) == "D"
                // SD2 - ORDER 3 = D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     
                cCCusto := Posicione("SD2",3,SD1->(D1_FILIAL+D1_NFORI+D1_SERIORI+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEMORI),"D2_CCUSTO")
            
            elseif AllTrim(cEntidade) == "CREDITO"

                //@history Ticket 69338 	- Leonardo P. Monteiro - 	Ajuste no CC para 5131 quando o produto for '190590'. Alterar Lançamento Padrão 641-008 - Quirera.
                if Alltrim(SD1->D1_COD) == "190590"
                    cCCusto := "5131"
                endif
            EndIf

        ElseIf AllTrim(cTab) == "SDE" // LP 651 (RATEIO CC)
            cCCusto := AllTrim(SDE->DE_CC)

        /*
        ElseIf AllTrim(cTab) == "SD3" // LPs 666 e 668 (SOLICITACAO ARMAZEM)
            If !Empty(SD3->D3_CC)
                cCCusto := SD3->D3_CC
            Else
                cCCusto := Posicione("SCP",1,SD3->(D3_FILIAL+D3_NUMSA+D3_ITEMSA),"CP_CC")
            EndIf
        */

        ElseIf AllTrim(cTab) == "SN1" // LP 812 BAIXA ADIANTAMENTOS PROJETOS
            If !Empty(SN3->N3_CCUSTO)
                cCCusto := SN3->N3_CCUSTO
            Else
                If !Empty(SN3->N3_CUSTBEM)   
                    cCCusto := SN3->N3_CUSTBEM
                Else
                    // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD                                                                                                     
                    SD1->(dbOrderNickName("D1INTERFAC"))
                    If SD1->( dbSeek(SN1->(N1_FILIAL+N1_NFISCAL+N1_NSERIE+N1_FORNEC+N1_LOJA+N1_NFITEM)) )
                        cCCusto := AllTrim(SD1->D1_CC)
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea( aAreaAtu )
    RestArea( aAreaSD2 )
    RestArea( aAreaSCP )
    RestArea( aAreaSN1 )

Return cCCusto
