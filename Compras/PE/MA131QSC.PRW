#Include 'Protheus.ch'

 /*/{Protheus.doc} User Function MA131QSC
     (O ponto de entrada MA131QSC  é executado no início da rotina de processamento das solicitações de compra que devem gerar cotação, permitindo incluir um bloco de código que realizará as quebras das solicitações de compras.)
     @type  Function
     @author ADRIANO SAVOINE
     @since 05/08/2020
     @version 01
     @history Chamado: 059985 - ADRIANO SAVOINE - 05/08/2020 - Ponto de entrada para nao agrupar codigo de produtos iguais ao gerar cotações.
     /*/


User Function MA131QSC()

Local bQuebra := PARAMIXB[1]

 
    bQuebra  := {|| C1_FILIAL+C1_NUM+C1_ITEM }


Return bQuebra
