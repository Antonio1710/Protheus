#include "rwmake.ch"  
User Function metasup()  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa para cadastro de Supervisores')

SetPrvt("CCADASTRO,AROTINA,")
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ metasup.prx  ³ Menu para egetuar manuten‡äes no cadastro de metas super³±±
±±³              ³ O Advanced Protheus nao contempla esta op‡aä             ±±
±±³              ³ Especifico Ad'oro Alimenticia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Marcos Bido  ³ 10/10/02 ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

dbSelectArea("SZL")
dbSetOrder(01)
CCadastro := "Metas de Vendas Supervisores    "
aRotina := {  { "Pesquisar"     ,"AxPesqui"            , 0 , 1},;
              { "Visualizar"    ,"axVisual"            , 0 , 2},;
              { "Incluir   "    ,"axInclui"            , 0 , 3},;
              { "Alterar   "    ,"axAltera"            , 0 , 4},;
              { "Excluir   "    ,"axDeleta"            , 0 , 5},;
   	          { "Metas Preço"   ,'ExecBlock("AD0149")' , 0 , 6},;
  	          { "Metas Volume"  ,'ExecBlock("AD0148")' , 0 , 7}}


mBrowse( 6, 1,22,75,"SZL")


Return
