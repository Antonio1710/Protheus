#include "protheus.ch"

/*/{Protheus.doc} User Function LP513()
    Função chamada no LP513 em virtude da alteração do parâmetro MV_CTMOVPA para 1 = SE2
    @type  Function
    @author FWNM
    @since 24/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 059956 || OS 061455 || FINANCAS || ANA || 972680072 || LP - APAGAR II
/*/
User Function LP513(cEntidade)

    Local uRet
    Local aAreaSE5 := SE5->( GetArea() )
    Local aAreaSA6 := SA6->( GetArea() )

    Default cEntidade := ""

    SE5->( dbSetOrder(2) ) // E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ                                                             
    If SE5->( msSeek(SE2->E2_FILIAL+AllTrim(SE2->E2_TIPO)+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_EMISSAO)+SE2->E2_FORNECE+SE2->E2_LOJA) )

        If AllTrim(cEntidade) == "VALOR"
            uRet := SE5->E5_VALOR
        
        ElseIf AllTrim(cEntidade) == "CREDITO"
            uRet := AllTrim(Posicione("SA6",1,FWxFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA),"A6_CONTA"))

        EndIf
    
    EndIf

    RestArea( aAreaSE5 )
    RestArea( aAreaSA6 )
    
Return uRet
