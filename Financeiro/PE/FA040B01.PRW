#Include 'Protheus.ch'


/*/{Protheus.doc} User Function FA040B01
    TKT  - 22767 Ponto de entrada utilizada para validação da exclusção de titulos do contas a receber (tratativa exclusivamente de RA)
    @type  Function
    @author TEO MONTEIRO - OBIFY  
    @since 21/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)

/*/


User Function FA040B01()

Local cAreaOld  := GetArea()
Local cAreaSE5  := SE5->( GetArea() )
Local cChave    := M->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+E1_SEQBX)
Local _lRet     := .T.
If M->E1_TIPO$"RA "
    SE5->( DbSetOrder(7))
    If SE5->( DbSeek(cChave) )
        If SE5->E5_DATA <> ddatabase
            _lRet := .F.
            Aviso("FA040B01","A database do sistema ("+DtoC(dDataBase)+") não é a mesma da data da movimentação do RA ("+DtoC(SE5->E5_DATA)+"). Exclusão não poderá ocorrer em database do diferente... ",{"Ok"},3 ,"Atencao! Exclusão em database diferente..")
        Endif
    Endif
Endif
RestArea(cAreaOld)
RestArea(cAreaSE5)
Return (_lRet)
