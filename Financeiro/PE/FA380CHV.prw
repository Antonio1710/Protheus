
#Include "RWMAKE.CH"
/*/{Protheus.doc} User Function FA380CHV
   P.E. para alteracao da ordenacao da tela de reconciliacao bancaria - Financeiro.
   @type  Function
   @author Ana Helena  
   @since 19/11/2010
   @version 01
   @history Everson, 18/06/2020, Chamado 058996. Adicionadas ordenações por filial, títulos a pagar/receber, histórico e valor.
   /*/
User Function FA380CHV()

   //Variáveis.                          
   Local cAlias := Alias()
   Local nOrdem := IndexOrd()
   Local nRecno := Recno()
   Local cRet   := ""
   Local oDlgFil:= Nil

   //
   aRadio := {"Filial+Data disponibilidade", "Filial+Valor", "Filial+Prefixo+Numero", "Pagar/Receber","Filial+Histórico"}
   nRadio := 1

   //
   @00,00 To 180,230 Dialog oDlgFil Title "Ordenação"
      @001,035 Say "Informe a ordenação"
      @010,010 Radio aRadio Var nRadio
      @070,045 BmpButton TYPE 1 Action Close(oDlgFil)
      @008,005 To 65,110
   Activate Dialog oDlgFil Centered

   //
   If nRadio == 1 //Por data da disposição.
      cRet :="E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"

   ElseIf nRadio == 2 //Por valor.
      cRet := "E5_FILIAL+STR(E5_VALOR, 16, 2)+E5_TIPO" 

   ElseIf nRadio == 3 //Por filial.
      cRet := "E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ"

   ElseIf nRadio == 4 //Por título a pagar/receber.
      cRet := "E5_RECPAG"

   ElseIf nRadio == 5 //Por histórico.
      cRet := "E5_FILIAL+E5_HISTOR"

   EndIf

   //
   If ValType(oDlgFil) == "O"
      FreeObj(oDlgFil)
      oDlgFil := Nil 

   EndIf

   //
   DbSelectArea(cAlias)
   DbSetOrder(nOrdem)                              
   DbGoTo(nRecno)

Return cRet