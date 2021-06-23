/*/{Protheus.doc} User Function CEXMGRCTE
  Ponto de Entrada da Central XML para corrigir a quantidade de cada item do CTE para 1. Estava sendo gravado zerado
  @type  User Function
  @author Abel Babini
  @since 04/05/2020
  @version 1
  @history Chamado 057474 - Abel Babini - 04/05/2020 - Corrigir quantidade do CTE na gravação do CTE na central XML conforme orientação da Fabritech
  /*/
User Function CEXMGRCTE()
  IF RECNFCTE->XML_TPCTE		== "N"
    RecLock( "RECNFCTEITENS", .f.)
    RECNFCTEITENS->XIT_QTE	:= 1
    Msunlock()
  ENDIF
Return Nil