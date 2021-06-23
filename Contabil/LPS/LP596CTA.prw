#include "protheus.ch"

/*/{Protheus.doc} User Function LP596CTA
    Função chamada nos LPs 596 e 588 (Compensação CR) para definir as contas contábeis de acordo com o posicionamento
    @type  Function
    @author FWNM
    @since 07/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 060263 || OS 061758 || CONTROLADORIA || CRISTIANE_MELO || 11986587658 || AJUSTE LP
    @history Chamado 368 - Adriana Oliveira- 24/08/2020 - Tratar deposito nao identificado
/*/
User Function LP596CTA()

    Local cCta          := ""
    Local cCtaRA        := "211510001"
    Local cCtaNCC       := "111210002"
    Local cCtaDepNId    := "111260001" // Chamado 368 - Adriana Oliveira- 24/08/2020
    Local cE5_DOCUMEN   := AllTrim(SE5->E5_DOCUMEN)
    Local cTipo         := Subs(cE5_DOCUMEN,16,3)
    Local cNaturez      := Alltrim(SE5->E5_NATUREZ) // Chamado 368 - Adriana Oliveira- 24/08/2020

    If cTipo == "RA"
        
        // Qdo está posicionado na RA  o E5_DOCUMEN é o RA e o E1_TIPO e E5_TIPO será a NF
        cCta := cCtaRA

    ElseIf cTipo == "NCC"
        
        // Qdo está posicionado na NCC o E5_DOCUMEN é o NCC e o E1_TIPO e E5_TIPO será a NF
        cCta := cCtaNCC

    // Chamado 368 - Adriana Oliveira- 24/08/2020
    ElseIf cNaturez == "10198" 

       cCta := cCtaDepNId
    //
    Else
        
        // Qdo está posicionado na NF  o E5_DOCUMEN é o NF  e o E1_TIPO e E5_TIPO será a RA ou NCC
        If AllTrim(SE1->E1_TIPO) == "RA"
            cCta := cCtaRA
        ElseIf AllTrim(SE1->E1_TIPO) == "NCC"
            cCta := cCtaNCC
        EndIf
    
    EndIf

Return cCta
