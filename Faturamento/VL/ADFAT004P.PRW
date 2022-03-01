#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADFAT004P º Autor ³ Mauricio - MDS TEC º Data ³  02/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campo C6_QTDVEN e C5_TIPO para permitir ou nao a alteº±±
±±º          ³ racao da quantidade no pedido de venda                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Ticket  TI    - Leonardo P. Monteiro - 26/02/2022 - Inclusão de conouts no fonte. 
/*/

User Function ADFAT004P(_cTipo)
   Local _lVal    := .T.
   Local _y       := 1
   Local nQtd	   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "C6_QTDVEN" })
   Local lSfInt	:= (IsInCallStack('U_RESTEXECUTE') .OR. IsInCallStack('RESTEXECUTE'))

   Conout( DToC(Date()) + " " + Time() + " ADFAT004P >>> INICIO PE" )

   //U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida campo C6_QTDVEN e C5_TIPO para permitir ou nao a alteracao da quantidade no pedido de venda')

   If _cTipo == "B"
   
      If len(aCols) > 0     &&havendo qualquer item ja digitado, deletado ou não, não pode se utilizar do tipo pedido B por conta da alteração da quantidade
         For _y := 1 to len(aCols)
            If (aCols[_y,nQtd] <> 0)  &&ha quantidade digitada             
               _lVal := .F.
            Endif
         Next _y       
      Endif
      
      If !_lVal .and. !lSfInt
         MsgInfo("Pedido com quantidade ja digitada não pode utilizar tipo de pedido igual a B(utiliza fornecedor).","Atenção")
      Endif
      
   Endif

   Conout( DToC(Date()) + " " + Time() + " ADFAT004P >>> FINAL PE" )

Return(_lVal)


User Function VLDC6QTD(_CodUsr)

   Local _lVal := .F.

   Conout( DToC(Date()) + " " + Time() + " VLDC6QTD >>> INICIO PE" )

   //U_ADINF009P('ADFAT004P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Valida campo C6_QTDVEN e C5_TIPO para permitir ou nao a alteracao da quantidade no pedido de venda')

   If (AllTrim(cModulo)="EEC".Or.Upper(Alltrim(FunName()))$"LEXMLSC/MATA310".Or.M->C5_TIPO<>"N")
      _lVal := .T.
   Endif     

   If (_CodUsr $ GETMV("MV_#USUBON"))
      _lVal := .T.
   Endif

   If (_CodUsr $ GETMV("MV_#USUQTD"))
      _lVal := .T.
   Endif

   Conout( DToC(Date()) + " " + Time() + " VLDC6QTD >>> FINAL PE" )

Return(_lVal)
