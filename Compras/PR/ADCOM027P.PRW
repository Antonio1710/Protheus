#include "rwmake.ch"
#Include "Protheus.ch"

/*{Protheus.doc} User Function ADCOM027P
	Controle de alteração de campos no cadastro de fornecedor
	@type  Function
	@author Ricardo Lima
	@since 17/01/2019
	@version 01
	@history Chamado 056503 - WILLIAM COSTA - 18/03/2020 - Ajuste no Error Log  THREAD ERROR ([17860], Erisvaldo.Santos, VPPC215)   16/03/2020 16:20:05 variable does not exist LADRALTF on U_ADCM0271(ADCOM027P.PRW) 06/02/2020 17:05:57 line : 43
    @Ticket 18071 - 21/06/2022 - Antonio Domingos - Melhoria no cadastro de fornecedor
*/

USER FUNCTION ADCOM027P()
    Local cFld01 := Alltrim(SuperGetMv( "MV_#CM0271" , .F. , 'FISCAL|TI|GERFIS' , ) )
    Local cFld02 := Alltrim(SuperGetMv( "MV_#CM0272" , .F. , 'FINANCAS|TI' ,  ) )

    _lRetFld01 :=IF(FWSFALLUSERS({__cUserId},{"USR_DEPTO"})[1][3] $ cFld01,.T.,.F.)
    _lRetFld02 :=IF(FWSFALLUSERS({__cUserId},{"USR_DEPTO"})[1][3] $ cFld02,.T.,.F.)
    lADRAltF   := .T.
        A020Altera()
    lADRAltF   := .F.

RETURN

/*{Protheus.doc} User Function ADCM0271
	Controle de alteração de campos no cadastro de fornecedor
	@type  Function
	@author Ricardo Lima
	@since 17/01/2019
	@version 01

*/

USER FUNCTION ADCM0271()
    Local lRet   := .T.
    Local aArea  := GetArea()
    Local cFld03 := Alltrim(SuperGetMv( "MV_#CM0273" , .F. , '3|6' ,  ) )
    Local cFld04 := Alltrim(SuperGetMv( "MV_#CM0274" , .F. , '1|2|4|7|8' ,  ) )
    // *** INICIO WILLIAM COSTA 18/03/2020 - CHAMADO 056503 || OS 057942 || TECNOLOGIA || LUIZ || 8451 || ERRORLOG -ADCM0271
    
    _cFolder := Posicione("SX3",2,ReadVar(),"X3_FOLDER")
    
    IF IsInCallStack('MATA020') == .F.
        Public lADRAltF := .F.
    ENDIF
    // *** FINAL WILLIAM COSTA 18/03/2020 - CHAMADO 056503 || OS 057942 || TECNOLOGIA || LUIZ || 8451 || ERRORLOG -ADCM0271
    IF lADRAltF == .T.
        lRet := .T.
    ELSE
        IF _cFolder  $  cFld03
            lRet:=_lRetFld01
        ELSEIF _cFolder  $  cFld04
            lRet:=_lRetFld02 
        ELSE
            lRet := .T.    
        ENDIF
    ENDIF
    RestArea(aArea)
RETURN(lRet)
