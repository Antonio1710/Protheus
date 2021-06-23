#include 'rwmake.ch'

/*/{Protheus.doc} User Function MT410ACE
    Valida permissão do vendedor na tela de pedido de vendas
    https://tdn.totvs.com.br/pages/releaseview.action?pageId=6784346
    @type  Function
    @author Ricardo Lima
    @since 09/05/2018
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history chamado 056247 - FWNM     - || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS
/*/
User Function MT410ACE()

    Local lContinua := .T.  
    Local nOpc  := PARAMIXB [1] // 1 - Excluir / 3 - Copiar / 4 - Alterar / 2 - Visualizar, Residuo

    // Chamado n. 056247 || OS 057671 || FINANCEIRO || LUIZ || 8451 || BOLETO BRADESCO WS - FWNM - 24/03/2020
    If /*nOpc == 1 .or. */ nOpc == 4 .or. IsInCallStack("Ma410Resid")
        FIE->( dbSetOrder(1) ) // FIE_FILIAL, FIE_CART, FIE_PEDIDO
        If FIE->( dbSeek(FWxFilial("FIE")+"R"+SC5->C5_NUM) )
            lContinua := .f.
            msgAlert("Pedido possui adiantamento/boleto... Alteração/Exclusão/Resíduo não permitida!", "[MT410ACE-01]")
        EndIf
    EndIf
    //

    If lContinua

        If CEMPANT <> '01' // Somente para a Empresa AD'oro
            Return(lContinua)
        Endif

        If IsInCallStack('RESTEXECUTE')
            Return(lContinua)
        Endif

        IF nOpc == 1 // excluir    
            dbSelectArea("SA3")
            dbSetOrder(7)
            If dbSeek(xFilial("SA3")+__cUserID)
                If SUBSTR(SA3->A3_XVLDPER,4,1) = '4'
                    ApMsgInfo('Vendedor sem PERMISSÃO para Excluir Pedido, verifique com a Supervisão!','Permissões de Vendedores')
                    lContinua := .F.    
                Endif
            Endif
        ElseIf nOpc == 3 // Copiar
            dbSelectArea("SA3")
            dbSetOrder(7)
            If dbSeek(xFilial("SA3")+__cUserID)
                If SUBSTR(SA3->A3_XVLDPER,3,1) = '3'
                    ApMsgInfo('Vendedor sem PERMISSÃO para Copiar Pedido, verifique com a Supervisão!','Permissões de Vendedores')
                    lContinua := .F.    
                Endif
            Endif
        ElseIf nOpc == 4 // Alterar        
            dbSelectArea("SA3")
            dbSetOrder(7)
            If dbSeek(xFilial("SA3")+__cUserID)
                If SUBSTR(SA3->A3_XVLDPER,2,1) = '2'
                    ApMsgInfo('Vendedor sem PERMISSÃO para Alterar Pedido, verifique com a Supervisão!','Permissões de Vendedores')
                    lContinua := .F.    
                Endif
            Endif
        Endif 

    EndIf

Return lContinua
