#include "protheus.ch"
#include "rwmake.ch"

/*/{Protheus.doc} User Function F240TDOK
  O ponto de entrada F240TDOK é utilizado para validações complementares dos títulos selecionados na geração do borderô, será executado apenas se for confirmada esta geração.
  @type  Function
  @author Abel Babini
  @since 01/12/2020
  @history Ticket   4883 - Abel Babini - 01/12/2020 - Geração de borderôs automática
  /*/

User Function F240TDOK
    Local peAliasSE2 := paramixb[2]
    Local lRetorno  := .T.
    If .Not. Empty( paramixb[1] ) .AND. FWIsInCallStack("xAutBor")
        While !(peAliasSE2)->(Eof())
            If Empty( E2_Naturez )
                lRetorno := .f.
                Exit
            Else
                lRetorno := .t.
                dbSkip()
            EndIf
        End
    EndIf

    If FWIsInCallStack("xAutBor")
		IF nExecBor > 1
			lRetorno    := .F.
		ENDIF
    EndIf

Return lRetorno
