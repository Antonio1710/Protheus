#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} User Function SPCOBREC
  Ponto de Entrada para preencher o campo F6_COBREC automaticamente na geração da GNRE Difal no Faturamento
  @type User Function
  @author Abel Babini
  @since 09/03/2020
  @version 1
  @history Chamado n.030408 - OS n.031094 - Abel Babini - 09/03/2020 - COD OBRIG GUIA DIFAL
  /*/

User Function SPCOBREC()
  
  /* 
  Paramixb[1] => Tipo GNRE
  Paramixb[2] => ESTADO da GNRE
  */

  Local cTipoImp := Paramixb[1] // Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
  Local cEstado  := Paramixb[2] // Estado da GNRE
  Local cCod 	 := ""          // Codigo a ser gravado no campo F6_COBREC

  If cTipoImp == "B"
    cCod := "003"
  EndIf

Return cCod