#include "protheus.ch"

/*/{Protheus.doc} User Function LP596CC
    Fun��o chamada nos LPs 596 e 588 (Compensa��o CR) para definir os centros de custos de acordo com o posicionamento
    @type  Function
    @author Fernando Macieira
    @since 25/04/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 71810 - Fernando Macieira - 25/04/2022 - CRIA��O DE LP COMPENSA��O DE ACORDOS PONTUAIS
/*/
User Function LP596CC(cEntidade)

    Local cCC         := ""
    Local cE5_DOCUMEN := AllTrim(SE5->E5_DOCUMEN)
    Local cTipo       := Subs(cE5_DOCUMEN,16,3)

    Default cEntidade := ""
    
    cCC := IF(LEFT(ALLTRIM(CTK->CTK_DEBITO),1)$"3,4",SE1->E1_CCD,"")

    If cTipo == "DSF"
        
        // Qdo est� posicionado na DSF o E5_DOCUMEN � o DSF e o E1_TIPO e E5_TIPO ser� a NF
        cCC := Iif(SA1->A1_EST=="SP","6110","6210")
    
    Else
        
        // Qdo est� posicionado na NF  o E5_DOCUMEN � o NF  e o E1_TIPO e E5_TIPO ser� a RA ou NCC
        If AllTrim(SE1->E1_TIPO) == "DSF"
            cCC := Iif(SA1->A1_EST=="SP","6110","6210")
        EndIf
    
    EndIf

Return cCC
