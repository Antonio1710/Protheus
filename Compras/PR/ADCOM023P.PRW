#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
// ############################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADCOM023P
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 02/08/18 | Ricardo Lima      | Aplica Bloqueio de titulo a Pagar, quando o pedido de compras| 042937
//          |                   | usar a condição de pagameto "ICM"                            |
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################
User Function ADCOM023P( FWxFilialSF1 , F1DOC, F1SERIE, F1FORNECE, F1LOJA, F1TIPO )

    Local lPgICM    := .F.
    Local lRet      := .T.
    Local CVAR  := GETAREA()     

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

    DbSelectArea("SF1")
	DbSetOrder(1)
	if DbSeek( FWxFilialSF1 + F1DOC + F1SERIE + F1FORNECE + F1LOJA + F1TIPO )
		IF SF1->F1_COND = "ICM"
		    lPgICM := .T.
            RecLock("SF1",.F.)
                SF1->F1_XANTSTA = SF1->F1_STATUS
                SF1->F1_STATUS = 'B'
            MsUnlock()  	
		ENDIF			
	endif

    IF lPgICM 	 	
    	lRet := .F.
    	// Bloqueia o titulo
        DbSelectArea("SE2")
        DbSetOrder(6)
        if DbSeek( FWxFilialSF1 + F1FORNECE + F1LOJA + F1SERIE + F1DOC )
            While SE2->(!EOF()) .AND. SE2->E2_FILIAL=FWxFilialSF1 .AND. SE2->E2_NUM=F1DOC .AND. SE2->E2_PREFIXO=F1SERIE .AND. SE2->E2_FORNECE=F1FORNECE .AND. SE2->E2_LOJA=F1LOJA .AND. SE2->E2_TIPO=F1TIPO
                RecLock("SE2",.F.)
                    SE2->E2_XDIVERG := 'S'
                    SE2->E2_RJ      := 'X'
                MsUnlock()
            SE2->(DBSKIP())
            END 
        Endif
    ENDIF

RESTAREA(CVAR)
Return(lRet)
