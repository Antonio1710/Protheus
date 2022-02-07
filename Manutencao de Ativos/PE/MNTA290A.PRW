#Include "Totvs.ch"

/*/{Protheus.doc} User Function MNTA290A
    (Ponto de Entrada para preenchimento automático de informações no fechamento da solicitação de serviço vinculada a ordem de serviço.)
    @type  Function
    @author ADRIANO SAVOINE
    @since 29/07/2020
    @version 01
    @history chamado: 059874 - 29/07/2020 - ADRIANO SAVOINE - Preenchimento automatico com base nos dados lançados no apontamento do colaborador.
    /*/

User Function MNTA290A()
  
    //Variável utilizada para retorno

    Local aArea   := GetArea()   
    Local aReturn := {}
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'add fechamento da solicitação de serviço')

 
    dbSelectArea( 'STL' )

    //Adiciona campos para o preenchimento automático

    aAdd(aReturn, {"TQB_DTFECH", "Posicione( 'STL', 1, xFilial('STL') + TQB->TQB_ORDEM, 'TL_DTFIM' )"})
    aAdd(aReturn, {"TQB_HOFECH", "Posicione( 'STL', 1, xFilial('STL') + TQB->TQB_ORDEM, 'TL_HOFIM' )"})
 
    RestArea(aArea)
 
Return aReturn
