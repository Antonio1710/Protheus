#Include "RwMake.ch"
#include "Protheus.ch"
#include "Topconn.ch"

// ##############################################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGAFAT
// Fonte  : ADVEN091P
// ---------+-------------------+-----------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                       | Chamado
// ---------+-------------------+-----------------------------------------------------------------+---------------
// 09/05/18 | Ricardo Lima      | Valida permissão do vendedor na tela de pedido de vendas        |
// ---------+-------------------+-----------------------------------------------------------------+---------------
// ###############################################################################################################
User Function ADVEN091P(l1Elem,lTipoRet)
	
	Private cTitulo  := ""
	Private MvPar
	Private MvParDef := ""
	Private nTam	   := 0
	
	Private aSit:={}
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	
	Default lTipoRet := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida permissão do vendedor na tela de pedido de vendas')
	
	IF lTipoRet
		MvPar:=Rtrim(&(Alltrim(ReadVar())))
		mvRet:=Alltrim(ReadVar())
		nTam := Len(&mvRet)
	EndIf
	
	aSit := {"1 - Incluir","2 - Alterar","3 - Copiar","4 - Excluir"}
	MvParDef:="1234"
	cTitulo :="Acessos Negados ao Vendedor"
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)
			&(Alltrim(ReadVar())) := mvpar			
		EndIf	
	EndIf

	aCpoRet := {mvpar}
	
Return(.T.)

