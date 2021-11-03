#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function F150ICNB
    Ponto de entrada para tratamento da variavel cIdCnab - Geração Arquivo Cobrança
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
    @history ticket TI  - FWNM - 10/09/2021 - Melhoria IDCNAB após golive CLOUD
/*/
User Function F150ICNB()
    
    Local cIdCnab  := ParamIXB[1]
    Local cQuery   := ""
    Local cNextCod := ""
    Local aArea    := SE1->( GetArea() )
    Local nOrdCNAB := 19

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

    cQuery := " SELECT E1_IDCNAB, COUNT(1) TT_IDCNAB
    cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
    cQuery += " WHERE D_E_L_E_T_=''
    cQuery += " AND E1_IDCNAB='"+cIDCNAB+"'
    cQuery += " AND E1_IDCNAB<>''
    cQuery += " GROUP BY E1_IDCNAB
    cQuery += " HAVING COUNT(1) >= 2

    tcQuery cQuery New Alias "WorkIDCNAB"

    WorkIDCNAB->( dbGoTop() )
    If WorkIDCNAB->( !EOF() )

        // Encontrou título com o IDCNAB que será gravado no título atual
        logZBE("E1_IDCNAB n. " + cIdCnab + " já existe na base! Será alterado por este PE antes de gravar no E1_NUM = " + SE1->E1_NUM)

        If Select("WorkLAST") > 0
            WorkLAST->( dbCloseArea() )
        EndIf

        cQuery := " SELECT MAX(E1_IDCNAB) LAST_IDCNAB
        cQuery += " FROM " + RetSqlName("SE1") + " (NOLOCK)
        cQuery += " WHERE E1_IDCNAB<>''
        cQuery += " AND D_E_L_E_T_=''

        tcQuery cQuery New Alias "WorkLAST"

        cNextCod := Soma1(AllTrim(WorkLAST->LAST_IDCNAB))

        cIdCnab := cNextCod // Recebe o próximo caso tenha encontrado algum idcnab em outro título

        DbSelectArea("SE1")
        ConfirmSX8()

        logZBE("Novo E1_IDCNAB n. " + cNextCod + " foi gravado no título n. " + SE1->E1_NUM + " para evitar duplicidade")

        If Select("WorkLAST") > 0
            WorkLAST->( dbCloseArea() )
        EndIf

    EndIf

    If Select("WorkIDCNAB") > 0
        WorkIDCNAB->( dbCloseArea() )
    EndIf

    // @history ticket TI  - FWNM - 10/09/2021 - Melhoria IDCNAB após golive CLOUD
    Do While .t.

	    SE1->( dbSetOrder(19) ) // E1_IDCNAB, R_E_C_N_O_, D_E_L_E_T_
		If SE1->( dbSeek(cIdCnab) )
            cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,nOrdCNAB)
            ConfirmSX8()
            Loop
        Else
            Exit
        EndIf

    EndDo
    
    dbSelectArea("SE1")
    ConfirmSX8()
    //

    RestArea( aArea )

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
		Replace ZBE_ROTINA	    With "F150ICNB" 
	ZBE->( msUnlock() )

Return
