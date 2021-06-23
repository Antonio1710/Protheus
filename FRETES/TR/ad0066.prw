#include "rwmake.ch"  

User Function AD0066()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu para controle de Frete por Cidade e por Preco Tonelada.')

SetPrvt("CCADASTRO,AROTINA,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ AD0066.PRW   ³ Menu para controle de Frete por Cidade e por Prec       ³±±
±±³              ³ Tonelada.                                               |±±
±±³              ³ Uso Logistica                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Gustavo      ³ 04/09/03 ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Controle de Frete por Cidade

// Tabela de Fretes por Cidade

dbSelectArea("ZV8")
dbSetOrder(01) // Indice codigo



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// cPerg   := "AD0065"
// Pergunte(cPerg,.t.)



//dbGoTop()



CCadastro := "Controle de Frete por Cidade"
aRotina := { { "Pesquisar     "  ,"AxPesqui"             , 0 , 1},;
              { "Visualizar    "  ,"axVisual"            , 0 , 2},;
              { "Incluir       "  ,"axInclui"            , 0 , 3},;
              { "Alterar       "  ,"axAltera"            , 0 , 4},;
              { "Excluir       "  ,'ExecBlock("AD0076")' , 0 , 5},;
              { "Preco p/ Ton. "  ,'ExecBlock("AD0067")' , 0 , 6} }
           // { "Imprimir      "  ,'ExecBlock("FRT_Imprimir")' , 0 , 7} }


mBrowse( 6, 1,22,75,"ZV8") 

Return
