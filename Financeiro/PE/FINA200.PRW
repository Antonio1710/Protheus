#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01

User Function FINA200()        // incluido pelo assistente de conversao do AP5 IDE em 14/05/01 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("NVALREC,NDESPES,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa º FINA200  º Autor º Rogerio Nutti      º Data º  25/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o º Ponto de Entrada para manipular variaveis no retorno do    º±±
±±º          º Banco Itau 341, Ag 0350, Conta 59690-4.                    º±±
±±º          º Tratamento das despesas de cobranca de boletos (R$ 1,19)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º Espec¡fico Ad'oro                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

If nDespes > 0
   //Alltrim(mv_par06) == "341"  .and.;
   //Alltrim(mv_par07) == "0350" .and.;
   //Alltrim(mv_par08) == "59690-4"
   nValRec := nValRec + nDespes
// nDespes := 0
Endif

If MV_PAR06 == '399'

      dBaixa := DDATABASE
      
Endif

//MsgBox( SE1->E1_NUM ,"E1_NUM" ,"ALERT")
//MsgBox( "nDesPes "     +Str(nDesPes,20,2)     ,"nDesPes"     ,"ALERT")
//MsgBox( "nDescont "    +Str(nDescont,20,2)    ,"nDescont"    ,"ALERT")
//MsgBox( "nOutrDesp "   +Str(nOutrDesp,20,2)   ,"nOutrDesp"   ,"ALERT")
//MsgBox( "nTotAbat "    +Str(nTotAbat,20,2)    ,"nTotAbat"    ,"ALERT")
//MsgBox( "nValRec "     +Str(nValRec,20,2)     ,"nValRec"     ,"ALERT")
//MsgBox( "nJuros "      +Str(nJuros,20,2)      ,"nJuros"      ,"ALERT")
//MsgBox( "nMulta "      +Str(nMulta,20,2)      ,"nMulta"      ,"ALERT")
//MsgBox( "nTotaGer "    +Str(nTotaGer,20,2)    ,"nTotaGer"    ,"ALERT")
//MsgBox( "nValEstrang " +Str(nValEstrang,20,2) ,"nValEstrang" ,"ALERT")

Return
