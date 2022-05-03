#include "rwmake.ch"  

User Function AD0175()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu para Controle dos Fretes')

SetPrvt("CCADASTRO,AROTINA,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ AD0063       ³ Menu para Controle dos Fretes                           ³±±
±±³              ³                                                         |±±
±±³              ³ Especifico Ad'oro Alimenticia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Werner       ³ 28/08/03 ³ Uso Logistica                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
@history Everson, 03/05/2022, Chamado 72313. Tratamento do filtro do browse.
/*/

// Parametro do Filtro
_nFiltFV := Getmv("MV_FRETFV")


dbSelectArea("SZK")
dbSetOrder(08)
dbGoTop()

CCadastro := "Controle de Frete  "
aRotina := { { "Pesquisar   "  ,"AxPesqui"                 , 0 , 1},;
              { "Visualizar  "  ,"axVisual"                 , 0 , 2},;
              { "Incluir     "  ,"axInclui"                 , 0 , 3},;
              { "Alterar     "  ,"axAltera"                 , 0 , 4},;
              { "Lançar      "  ,'ExecBlock("AD0094")'      , 0 , 5},;
              { "Consulta    "  ,'ExecBlock("AD0071")'      , 0 , 6}}


// +-----------------------------------+
// | Cria Filtro para o mBrowse        |
// +-----------------------------------+
Private aIndSZK   := {}
Private bFiltraBrw := {|| Nil}                          
cCondicao  := "ZK_FILIAL = '" + FWxFilial("SZK") + "' .AND. ZK_TIPFRT = 'FV'"//xFilial("SZK") + Alltrim(_nFiltFV) 
bFiltraBrw := {|| FilBrowse("SZK",@aIndSZK,@cCondicao)}
Eval(bFiltraBrw)
           

mBrowse( 6, 1,22,75,"SZK")

dbSelectArea("SZK")
dbSetOrder(08)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SZK",aIndSZK)


Return
