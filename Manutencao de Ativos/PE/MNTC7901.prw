#Include 'Protheus.ch'

/*/{Protheus.doc} User Function MNTC7901
    Ponto de entrada para adicionar opções à ações relacionadas da rotina O.S. Preventiva (MNTC790).
    @type  Function
    @author Fernando Macieira
    @since 26/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @ticket 3143 - Melhoria - Impressão de OS finalizada
/*/
User Function MNTC7901()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Add menu Preventiva (MNTC790)')

    //Parâmetros
    aRotina := PARAMIXB[1] // Array contendo as ações relacionadas

    aAdd(aRotina,{'Imprimir Retorno OS',{||MNT400IMP()},0,2}) 

Return aRotina
