#Include "Protheus.ch"  
#Include "Rwmake.ch" 

// ##########################################################################################
// Projeto: 
// Modulo : SIGAFIN
// Fonte  : F050BROW
// ---------+-------------------+--------------------------------------------+---------------
// Data     | Autor             | Descricao                                  | Chamado
// ---------+-------------------+--------------------------------------------+---------------
//          |                   | Bloqueia/Desbloqueia titulo para pagamento | 
// ---------+-------------------+--------------------------------------------+---------------
// ##########################################################################################
USER FUNCTION F050BROW()

Local _aArea	:= GetArea()

	IF alltrim(__CUSERID) $ GETMV("MV_#USUBLO")
		aAdd(aRotina,{"Bloquear/Solicitar Desbloqueio", "U_F050Bloq()", 0 , 4, 0, .F.})
		aAdd(aRotina,{"Altera Venc PA-SAG", "U_ADFIN065P()", 0 , 4, 0, .F.})
	ENDIF

	RestArea( _aArea )

RETURN()
