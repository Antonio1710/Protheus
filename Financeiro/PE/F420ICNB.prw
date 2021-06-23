#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F420ICNB
    Ponto de entrada para tratamento da variavel cIdCnab - Geração Arquivo Pagamentos
    @type  Function
    @author FWNM
    @since 04/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @chamado 059415 || OS 060907 || FINANCAS || WAGNER || 11940283101 || WS BRADESCO
/*/
User Function F420ICNB()
    
    Local cIdCnab  := ParamIXB[1]
    Local cQuery   := ""
    Local cNextCod := ""

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E2_IDCNAB, COUNT(1) TT_IDCNAB
    cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
    cQuery += " WHERE D_E_L_E_T_=''
    cQuery += " AND E2_IDCNAB='"+cIDCNAB+"'
    cQuery += " AND E2_IDCNAB<>''
    cQuery += " GROUP BY E2_IDCNAB
    cQuery += " HAVING COUNT(1) >= 2

    tcQuery cQuery New Alias "WorkIDCNAB"

    WorkIDCNAB->( dbGoTop() )
    If WorkIDCNAB->( !EOF() )

        // Encontrou título com o IDCNAB que será gravado no título atual
        logZBE("E2_IDCNAB n. " + cIdCnab + " já existe na base! Será alterado por este PE antes de gravar no E2_NUM = " + SE2->E2_NUM)

        If Select("WorkLAST") > 0
            WorkLAST->( dbCloseArea() )
        EndIf

        cQuery := " SELECT MAX(E2_IDCNAB) LAST_IDCNAB
        cQuery += " FROM " + RetSqlName("SE2") + " (NOLOCK)
        cQuery += " WHERE E2_IDCNAB<>''
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "WorkLAST"

        cNextCod := Soma1(AllTrim(WorkLAST->LAST_IDCNAB))

        cIdCnab := cNextCod // Recebe o próximo caso tenha encontrado algum idcnab em outro título

        logZBE("Novo E2_IDCNAB n. " + cNextCod + " foi gravado no título n. " + SE2->E2_NUM + " para evitar duplicidade")

        If Select("WorkLAST") > 0
            WorkLAST->( dbCloseArea() )
        EndIf

    EndIf

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

Return cIdCnab

/*/{Protheus.doc} Static Function LOGZBE
	Gera log ZBE
	@type  Static Function
	@author Everson
	@since 24/05/2019
	@version 01
/*/
Static Function logZBE(cMensagem)

	RecLock("ZBE", .T.)
		Replace ZBE_FILIAL 	   	With FWxFilial("ZBE")
		Replace ZBE_DATA 	   	With msDate()
		Replace ZBE_HORA 	   	With Time()
		Replace ZBE_USUARI	    With Upper(Alltrim(cUserName))
		Replace ZBE_LOG	        With cMensagem
		Replace ZBE_MODULO	    With "SIGAFIN"
		Replace ZBE_ROTINA	    With "F420ICNB" 
	ZBE->( msUnlock() )

Return
