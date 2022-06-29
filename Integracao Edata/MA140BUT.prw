#INCLUDE "rwmake.ch"
#include "Protheus.ch"

/*/{Protheus.doc} User Function MA140BUT
  (long_description)
  @type  Function
  @author Microsiga 
  @since 12/01/2013
  @version 01
  @history Everson, 29/06/2022, ticket 75444 - Adiciona função para informar placa subsitutiva.
  /*/
User Function MA140BUT()
  
  Local aBotao :={}

  AAdd(aBotao,{"BPMSRECI",{||U_SelNfDev()},"Nf.Dev","Nf.Dev"})
  AAdd(aBotao,{"BPMSRECI",{||U_SelDevT()},"Nf.DevTotal","Nf.DevTotal"})  
  AAdd(aBotao,{"BPMSRECI",{||plcSubt()},"Placa Substitutiva","Placa Substitutiva"})  
  
Return aBotao 
/*/{Protheus.doc} User Function plcSubt
  Placa subsitutiva.
  @type  Static Function
  @author Everson
  @since 29/06/2022
  @version 01
  /*/
Static Function plcSubt()

  //Variáveis.
  Local aArea	 := GetArea()
  Local nAux	 := 1

  If ! Pergunte("MA140BUT1", .T.)
    RestArea(aArea)
    Return Nil

  EndIf

  For nAux := 1 To Len(aCols)
    aCols[nAux][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_XPLACAS"		} 	)] := MV_PAR01

  Next nAux

  MsgInfo("Placa " + cValToChar(MV_PAR01) + " atribuída.","Função plcSubt(MA140but)")

  RestArea(aArea)

Return Nil
