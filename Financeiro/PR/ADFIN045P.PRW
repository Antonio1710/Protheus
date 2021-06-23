#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

// ############################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : ADFIN045P
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 14/11/17 | Ricardo Lima      | Verifica se existe limite de credito para lancamento de PA,  | 038609
//          |                   | se somando o lancamento atual ultrapassa o limte, bloqueia   |
//          |                   | o lancamento da PA                                           |
// ---------+-------------------+--------------------------------------------------------------+---------------
//  15/03/18|Ricardo Lima       | Ajuste no retorno para demais rotinas                        |
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################

User Function ADFIN045P(nOpc)

Local nVlrLim	:= 0
Local cForn		:= IIF(nOpc='1',M->E2_FORNECE,M->A2_COD)
Local cLoj		:= IIF(nOpc='1',M->E2_LOJA,M->A2_LOJA) 
Local cQuery	:= ""
Local lRet		:= .T.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Verifica se existe limite de credito para lancamento de PA, se somando o lancamento atual ultrapassa o limte, bloqueia o lancamento da PA')

If M->E2_TIPO <> 'PA'
	Return( lRet )	
EndIf

IF Alltrim(FunName()) = 'FINA750' .OR. Alltrim(FunName()) = 'FINA050'  .OR. Alltrim(FunName()) =  'MATA020' // Ricardo Lima - 09/02/2018 "FINA750"

cQuery := " SELECT A2_COD, A2_LOJA, A2_XLIMCRD, " 
cQuery += " ISNULL( (SELECT SUM(E2_SALDO) FROM "+ RetSqlName("SE2") +" WHERE E2_FORNECE=A2.A2_COD AND E2_LOJA=A2.A2_LOJA AND E2_TIPO = 'PA' AND D_E_L_E_T_ = ' '),0) E2_SALDO "
cQuery += " FROM "+ RetSqlName("SA2") +" A2 "
cQuery += " WHERE A2_COD = '"+ cForn +"' AND A2_LOJA = '"+ cLoj +"' "
cQuery += " AND D_E_L_E_T_ = ' ' " 

	If Select("TMPSA2") > 0
		TMPSA2->(DbCloseArea())		
	EndIf
	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "TMPSA2"
	  	
	IF nOpc = '1'
	 IF M->E2_TIPO = 'PA'
	  IF TMPSA2->A2_XLIMCRD > 0
		IF ( M->E2_VALOR + TMPSA2->E2_SALDO ) > TMPSA2->A2_XLIMCRD			
			MsgBox('Somando essa PA o Limite de Credito do Fornecedor foi ultrapassado, O Lançamento será encaminhado para Aprovação, Limite Disponivel: R$' + Transform( ( TMPSA2->A2_XLIMCRD - TMPSA2->E2_SALDO ), X3Picture( "E2_SALDO" ) ) ,'Limite de Crédito para PA','Info')					
			lRet := .T.
			Return( lRet )	
		ENDIF
	  ELSE
	 	MsgBox('Limite de Credito do Fornecedor Não Cadastrado, O Lançamento será Encaminhado para Aprovação!' , 'Limite de Crédito para PA','Info')					
		lRet := .T.
		Return( lRet )
	  ENDIF
	 ENDIF	
	ELSE
		lRet := .T.
		IF TMPSA2->A2_XLIMCRD > 0
			Return( TMPSA2->A2_XLIMCRD - TMPSA2->E2_SALDO )
		ELSE
			Return( 0 )
		ENDIF
	ENDIF	
endif	

Return(lRet)
