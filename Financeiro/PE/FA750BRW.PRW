#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

// ############################################################################################################
// Projeto: Projeto Financas
// Modulo : SIGAFIN
// Fonte  : FA750BRW
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 12/07/18 | Ricardo Lima      |                                                              | 
// ---------+-------------------+--------------------------------------------------------------+---------------
// 27/08/19 | FWNM              | Chamada funcao u_AltTitRH                                    | 050958 
// ---------+-------------------+--------------------------------------------------------------+---------------
// 30/08/19 | WILLIAM COSTA     | Chamada T.I Adicionado para poder altera a P.A tambem        | T.I
// ---------+-------------------+--------------------------------------------------------------+---------------

// ############################################################################################################

User Function FA750BRW

Local aRet := {}
     
    aAdd(aRet, { 'Consulta Aprovação' , "U_ADFIN061P(SE2->E2_FILIAL , SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO)" , 0 , 1 }) 
    
    IF alltrim(__CUSERID) $ GETMV("MV_#USUBLO")
        aAdd(aRet, { 'Bloquear/Solicitar Desbloqueio' , "U_F050Bloq()" , 0 , 1 }) 
        aAdd(aRet, { 'Altera Venc PA-SAG' , "U_ADFIN065P()" , 0 , 1 }) 
	ENDIF
	
	// Chamado n. 050958 - Tela para alteracao de campos controlados (SISPAG)
    aAdd( aRet, { "Altera Títulos RH e PA" , "u_AltCodBar()" , 0 , 8 } ) // CHAMADO T.I 30/08/2019

Return aRet 
