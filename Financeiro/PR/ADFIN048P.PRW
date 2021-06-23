#Include "RwMake.ch"
#Include 'Protheus.ch'

// ##########################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN048P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 21/11/17 | Ricardo Lima      | Valida Aprovador de Cadastro de Fornecedor | 038606
// ---------+-------------------+--------------------------------------------+---------------
//          |                   | U_ADFIN048P( __cUserID , nOpc )            |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################

User Function ADFIN048P(cUsrCod , nOpc )

	Local lRet := .F.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida Aprovador de Cadastro de Fornecedor')

	DbSelectArea("ZC3")
	DbSetorder(1)
	if DbSeek( FwxFilial("ZC3") + cUsrCod  )
		while ZC3->( !EOF() ) 
		 IF ZC3->ZC3_CODUSU = cUsrCod
			if ZC3->ZC3_TABBLF = nOpc //"000002"
				lRet	:= .T.
			ENDIF
			ZC3->(DbSkip())
		 ENDIF
		 ZC3->(DbSkip())
		end
	endif

Return( lRet )