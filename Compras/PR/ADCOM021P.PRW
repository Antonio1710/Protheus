#Include "RwMake.ch"
#include "Protheus.ch"
#include "Topconn.ch"

// ##########################################################################################
// Projeto: Projeto WorkFlow
// Modulo : SIGACOM
// Fonte  : ADCOM021P
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
// 02/05/18 | Ricardo Lima      | Cadastro de Agendamento de Workflow        |
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
User Function ADCOM021P(l1Elem,lTipoRet)
	
	Private cTitulo  := "Dias da Semana"
	Private MvPar
	Private MvParDef := ""
	Private nTam	 := 0
	
	Private aSit:={}
	
	l1Elem := If (l1Elem = Nil , .F. , .T.)
	
	Default lTipoRet := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF lTipoRet
		MvPar:=Rtrim(&(Alltrim(ReadVar())))
		mvRet:=Alltrim(ReadVar())
		nTam := Len(&mvRet)
	EndIf
	
	aSit := {"1 - Domingo","2 - Segunda","3 - Terça","4 - Quarta","5 - Quinta","6 - Sexta","7 - Sabado"}
	MvParDef:="1234567"
	cTitulo :="Dias da Semana"
	
	IF lTipoRet
		IF f_Opcoes(@MvPar,cTitulo,aSit,MvParDef,12,49,l1Elem)
			&(Alltrim(ReadVar())) := mvpar			
		EndIf	
	EndIf

	aCpoRet := {mvpar}
	
Return(.T.)
