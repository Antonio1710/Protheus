#include "rwmake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} User Function EECAP100
	Ponto de Entrada rotina de inclusão processo de exportação e confecção do Pedido de Venda
	@type  Function
	@author  
	@since 16/10/2018
	@version 01
	@history 29/10/2018 - Chamado 044318 Fernando Sigoli - Projeto Controle de laudos
	@history 06/08/2019 - Chamado 050701 Abel Babini Filho - Corrige Local Padrão baseado no Indicador de Produtos SC6
	@history 26/08/2019 - Chamado 051303 Abel Babini Filho - Corrige Local Padrão baseado no Indicador de Produtos SC9
	@history 07/11/2019 - Chamado 053097 Adriana Oliveira - Corrige gravação do campo C5_VOLUME1, considerando todos os itens do pedido                       
    @history 17/03/2021 - Chamado  11022 Leonardo P. Monteiro - Tratamento do tipo de frete na integração do SIGAEEC (EE7) com o módulo de faturamento(SC5).
    @history 25/03/2021 - Chamado   8465 Leonardo P. Monteiro - Tratamento da data de entrega do pedido de venda no módulo de faturamento e tipo de frete.
    @history 14/04/2021 - Chamado  12079 Leonardo P. Monteiro - Preenchimento do grupo de inspeção como '01-Mercado Interno' quando campo está em branco.
    @history 16/04/2021 - Chamado   8465 Leonardo P. Monteiro - Implementação do tratamento dos campos e gatilhos na cópia dos pedidos de exportação.
    @history 22/05/2021 - Chamado   8465 Leonardo P. Monteiro - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção.
    @history 22/05/2021 - Chamado   8465 Leonardo P. Monteiro - Alteração na validação para considerar o número da placa ao invés do roteiro.
    @history 04/06/2021 - Chamado   8465 Leonardo P. Monteiro - Correção do error.log na linha 85.
/*/

User Function EECAP100

    Local cRespAux := ""
    Local EE7PESLIQ := EE7->EE7_PESLIQ
    Local EE7PESBRU := EE7->EE7_PESBRU
    Local EE8QE     := 0
    Local EE8EMBAL1 := ""
    Local EE7XGRPIN := EE7->EE7_XGRPIN //Chamado 044318
    //INICIO Chamado 050701 - Abel Babini - Corrigi Local Padrão baseado no Indicador de Produtos - 06/08/2019
    Local cAuxFil 	:= ""
    Local cAuxPed	:= ""
    Local cLocal	:= ""
    Local dDtEntr   := Stod("")
    //@Ticket  11022 Leonardo P. Monteiro - Criação de campo e atribuição da variável.
    Local EE7XTPF   := EE7->EE7_XTPFRE
    //@Ticket  8465 Leonardo P. Monteiro - Gravação da etiqueta de exportação.
    Local EE7XETQ   := EE7->EE7_XETQUE
    
    //FIM Chamado 050701 - Abel Babini - Corrigi Local Padrão baseado no Indicador de Produtos - 06/08/2019
    If Type("ParamIXB") == "C"
        cRespAux := ParamIXB
    ElseIf Type("ParamIXB") == "A"
        cRespAux := ParamIXB[1] 
    Else
        cRespAux := ""
    EndIf

    IF cRespAux == 'GRV_PED'
        //LPM
        dbSelectArea("EE7")

        if !Empty(EE7->EE7_XWFNED)
            IF msgYesNo("Deseja reenviar o workflow de notificação de embarque?")
                If Reclock("EE7",.F.)
                    EE7->EE7_XWFNEE := "N"
                    MsUnLock("EE7")
                endif
            endif
        endif


        dbSelectArea("EE8")
        EE8->(dbSetOrder(1))
        if EE8->(dbSeek( FWxFilial("EE8") + EE7->EE7_PEDIDO ))
            EE8EMBAL1 := EE8->EE8_EMBAL1 
            //INICIO Chamado 053097 Adriana Oliveira - 07/11/2019
            While EE8->EE8_FILIAL = FWxFilial("EE8") .AND. EE8->EE8_PEDIDO = EE7_PEDIDO
                EE8QE     += EE8->EE8_QTDEM1
                //Data 25/03/2021 - Chamado   8465 Leonardo P. Monteiro - Tratamento da data de entrega do pedido de venda no módulo de faturamento e tipo de frete.
                if !Empty(EE8->EE8_DTENTR)
                    if EE8->EE8_DTENTR <= dDtEntr .or. Empty(dDtEntr)
                        dDtEntr := EE8->EE8_DTENTR
                    endif
                endif

                EE8->(DbSkip())
            Enddo    
        endif

        //FIM Chamado 053097 Adriana Oliveira - 07/11/2019
        dbSelectArea("SC5")
        SC5->(dbSetOrder(1))
        
        If SC5->(dbSeek( FWxFilial("SC5") + EE7->EE7_PEDFAT ))
            //@history 24/06/2021 - Chamado   8465 Leonardo P. Monteiro - Correção do error.log na linha 85.
            IF SC5->C5_NUM == EE7->EE7_PEDFAT
                RecLock("SC5",.F.)
                    SC5->C5_PESOL   := EE7PESLIQ
                    SC5->C5_PBRUTO  := EE7PESBRU
                    SC5->C5_VOLUME1 := EE8QE
                    SC5->C5_ESPECI1 := IIF(EE8EMBAL1='BX','CAIXAS',EE8EMBAL1)
                    
                    //Ticket  12079 Leonardo P. Monteiro - Preenchimento do grupo de inspeção como '01-Mercado Interno' quando campo está em branco.
                    if Empty(EE7XGRPIN)
                        SC5->C5_XGRPINS := "01"
                    else
                        SC5->C5_XGRPINS := EE7XGRPIN                             //Chamado 044318
                    endif

                    //@Ticket  8465 Leonardo P. Monteiro - Gravação da etiqueta de exportação.
                    SC5->C5_XETQUET := EE7XETQ
                    //Data 25/03/2021 - Chamado   8465 Leonardo P. Monteiro - Tratamento da data de entrega do pedido de venda no módulo de faturamento e tipo de frete.
                    if Empty(SC5->C5_PLACA).AND. Empty(SC5->C5_X_SQED)
                        IF !Empty(dDtEntr)
                            SC5->C5_DTENTR  := dDtEntr
                        endif
                    endif
                    //@Ticket  11022 Leonardo P. Monteiro - Validação e integração do campo.
                    if !EMPTY(EE7XTPF)
                        SC5->C5_TPFRETE := EE7XTPF
                    ENDIF
                    // @history 22/05/2021 - Chamado   8465 Leonardo P. Monteiro - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção.
                    SC5->C5_XESPEM  := EE7->EE7_XESPEM
                    SC5->C5_CONTAIN := EE7->EE7_CONTAI
                    SC5->C5_NLACRE1 := EE7->EE7_NLACR1
                    SC5->C5_NLACRE2 := EE7->EE7_NLACR2
                    SC5->C5_TEMPERA := EE7->EE7_TEMPER
                    SC5->C5_DTPROD  := EE7->EE7_DTPROD

                MsUnlock("SC5")
                //INICIO Chamado 050701 - Abel Babini - Corrigi Local Padrão baseado no Indicador de Produtos - 06/08/2019
                If SC6->(dbSeek( FWxFilial("SC6") + EE7->EE7_PEDFAT ))
                    cAuxFil := FWxFilial("SC6")
                    cAuxPed	:= EE7->EE7_PEDFAT
                    While !SC6->(EOF()) .AND. SC6->C6_FILIAL == cAuxFil  .AND. SC6->C6_NUM == cAuxPed
                        cLocal := IIF(!RetArqProd(SC6->C6_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC6->C6_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD"))
                        RecLock("SC6",.F.)
                        SC6->C6_LOCAL := cLocal
                        
                        //Data 25/03/2021 - Chamado   8465 Leonardo P. Monteiro - Tratamento da data de entrega do pedido de venda no módulo de faturamento e tipo de frete.
                        if Empty(SC5->C5_PLACA).AND. Empty(SC5->C5_X_SQED)
                            if !Empty(dDtEntr)
                                SC6->C6_ENTREG := dDtEntr
                            endif
                        endif

                        SC6->(MsUnlock())
                        SC6->(DbSkip())
                    Enddo
                Endif
                //FIM Chamado 050701 - Abel Babini - Corrigi Local Padrão baseado no Indicador de Produtos - 06/08/2019
                //INICIO Chamado 051303 - Abel Babini - Corrigir Local Padrão baseado no Indicador de Produtos SC9 - 26/08/2019
                If SC9->(dbSeek( FWxFilial("SC9") + EE7->EE7_PEDFAT ))
                    cAuxFil := FWxFilial("SC9")
                    cAuxPed	:= EE7->EE7_PEDFAT
                    While !SC9->(EOF()) .AND. SC9->C9_FILIAL == cAuxFil  .AND. SC9->C9_PEDIDO == cAuxPed
                        
                        if Empty(SC9->C9_NFISCAL)
                            cLocal := IIF(!RetArqProd(SC9->C9_PRODUTO),POSICIONE("SBZ",1,xFilial("SBZ")+SC9->C9_PRODUTO,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_LOCPAD"))
                            
                            RecLock("SC9",.F.)
                                SC9->C9_LOCAL   := cLocal
                                // @history 22/05/2021 - Chamado   8465 Leonardo P. Monteiro - Implementação dos campos de container, temperatura, lacres SIF, lacres armador, e datas de produção.
                                if Empty(SC5->C5_PLACA).AND. Empty(SC5->C5_X_SQED)
                                    SC9->C9_DATENT	:= dDtentr
                                endif
                            SC9->(MsUnlock())
                        endif
                        
                        SC9->(DbSkip())
                    Enddo
                Endif
                //FIM Chamado 051303 - Abel Babini - Corrigir Local Padrão baseado no Indicador de Produtos SC9 - 26/08/2019
            else
                    msginfo("Pedido de venda não atualizado!")
            endif
        EndIf
    // Preenchimento dos campos na cópia dos processos de exportação.
    ELSEIF cRespAux == 'PE_COPYPED'    
        
        RunTrigger(1,nil,nil,,'EE7_VIA')
        RunTrigger(1,nil,nil,,'EE7_PAISET')
    EndIf

Return
