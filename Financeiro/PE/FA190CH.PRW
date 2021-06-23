#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01

User Function FA190CH()        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("_CALI,_NORD,_NREC,_NUM,_BANCO,_AGENCIA")
SetPrvt("_CONTA,_PREFIXO,")

/*/                                                      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FA190CH  º Autor ³ Joaquim Assis      º Data ³Wed  07/07/99º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Ponto de Entrada na Juncao dos Cheques, Adiciona Prefixo   º±±
±±º          ³ no cheque Aglutinador. Segundo Sr.Fernando e Sr.Ricardo naoº±±
±±º          ³ ha posibilidade de Aglutinar Titulos de Outras Unidades.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Guarda Area do Siga                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAli := Alias()
_nOrd := IndexOrd()
_nRec := Recno()

dbSelectArea("SEF")                
_cAliSEF := Alias()
_nOrdSEF:= IndexOrd()
_nRecSEF := Recno()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis Utilizadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cFilial  := Space(02)
_cNum     := Space(15)
_cBanco   := Space(03)
_cAgencia := Space(05)
_cConta   := Space(10)
_cPrefixo := Space(03)

_cFilial  := xFilial("SEF")
_cNum     := cCheque190+Repl(" ",15-Len(cCheque190))     //SEF->EF_NUM
_cBanco   := cBanco190+Repl(" ",15-Len(cBanco190))      //SEF->EF_BANCO
_cAgencia := cAgencia190+Repl(" ",15-Len(cAgencia190))    //SEF->EF_AGENCIA
_cConta   := cConta190+Repl(" ",15-Len(cConta190))      //SEF->EF_CONTA

//------------------------------------------------------------------------------------
//MsgBox("Filial: ["+Alltrim(Str(Len(xFilial("SEF"))))+"]" ,"Atencao","INFO")
//MsgBox("Cheque: ["+Alltrim(Str(Len(_Num)))+"]" ,"Atencao","INFO")
//MsgBox("Banco: ["+Alltrim(Str(Len(_Banco)))+"]" ,"Atencao","INFO")
//MsgBox("Agencia: ["+Alltrim(Str(Len(_Agencia)))+"]" ,"Atencao","INFO")
//MsgBox("Conta Cor: ["+Alltrim(Str(Len(_Conta)))+"]" ,"Atencao","INFO")
//------------------------------------------------------------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEF")
// Corrigido conforme pedido do Rogerio Nutti da Microsiga
//dbSetOrder(5)
dbSetOrder(8)
//           2        15    3         5        10     1
If dbSeek(_cFilial+_cNum+_cBanco+_cAgencia+_cConta+"A")
   _Prefixo := SEF->EF_PREFIXO
   If dbSeek(_cFilial+_cNum+_cBanco+_cAgencia+_cConta+" ")
      RecLock("SEF",.F.)
      Replace EF_PREFIXO With _Prefixo
      MsUnLock()
   Else
      MsgBox("Nao Achou o Cheque Aglutinador","Atencao","INFO")
   EndIf
Else
   MsgBox("Nao Achou o Cheque Aglutinado Tipo A","Atencao","INFO")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna ambiente inicial           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(_cAliSEF)
dbSetOrder(_nOrdSEF)
dbGoTo(_nRecSEF)

dbSelectArea(_cAli)
dbSetOrder(_nOrd)
dbGoTo(_nRec)

Return 
