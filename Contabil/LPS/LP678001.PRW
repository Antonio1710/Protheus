#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function LP678001
    Função chamada no LP 678-001 no campo CT5_CCD da empresa RNX2
    @type  Function
    @author FWNM
    @since 11/06/2019
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 049761 
    @history chamado 057953 - FWNM - 20/05/2020 - OS 059435 || CONTROLADORIA || FRED_SANTOS || 11996426706 || LANC.PADRAO
/*/
User Function LP678001()

	Local cRet := ""

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	If AllTrim(SD2->D2_LOCAL) == "A624"
		cRet := "7134"
	
	ElseIf AllTrim(SD2->D2_LOCAL) == "D609"
		cRet := "7140"
	
	ElseIf AllTrim(SD2->D2_LOCAL) == "GF01"
		cRet := "7515"

	ElseIf AllTrim(SD2->D2_LOCAL) == "GF02"
		cRet := "7525"
		
	ElseIf AllTrim(SD2->D2_LOCAL) == "GF03"
		cRet := "7535"
		
	ElseIf AllTrim(SD2->D2_LOCAL) == "G961"
		cRet := "7543"

	ElseIf AllTrim(SD2->D2_LOCAL) == "MARL"
		cRet := "7551"
                     
	ElseIf AllTrim(SD2->D2_LOCAL) == "P0102"
		cRet := "7615"

	ElseIf AllTrim(SD2->D2_LOCAL) == "P0405"
		cRet := "7625"

	ElseIf AllTrim(SD2->D2_LOCAL) == "I019"
		cRet := "7660"
		
    // Chamado n. 057953 || OS 059435 || CONTROLADORIA || FRED_SANTOS || 11996426706 || LANC.PADRAO - FWNM - 20/05/2020
	ElseIf AllTrim(SD2->D2_LOCAL) == "R1201"
		cRet := "7675"

	ElseIf AllTrim(SD2->D2_LOCAL) == "R1212"
		cRet := "7670"
    //

	Else
		cRet := "6110"

    EndIf

Return cRet