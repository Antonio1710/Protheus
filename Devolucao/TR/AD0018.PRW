#include "rwmake.ch"  

User Function AD0018  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

SetPrvt("CCADASTRO,AROTINA,")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ AD0018.PRX   ³ Manutencao no cadastro de Devolucoes de Produtos        ³±±
±±³              ³                                                         ³±±
±±³              ³ Especifico Ad'oro Alimenticia                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Ricardo B.   ³ 03/12/02 ³                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Public aRotina := {}

// Parametro do Filtro                   
_nFiltDev := Getmv("MV_FILDEV")

//_nFiltDev := " ZD_DEVTOT = 'T' .OR. ZD_DEVTOT = 'P' "


dbSelectArea("SZD")
dbSetOrder(1)
dbGoTop()

CCadastro := "Devolucoes "
aRotina := {  { "Pesquisar"    ,"AxPesqui"           	, 0 , 1},;
              { "Consultar"	   ,'Execblock("AD0168")' 	, 0 , 2},;
              { "Incluir"      ,'U_AD0019("I")'	, 0 , 3},;              
              { "Alterar"      ,'U_AD0019("A")'	, 0 , 4},;
              { "Visualizar"   ,'U_AD0019("V")'	, 0 , 5},;              
              { "Excluir"      ,'U_AD0019("E")'	, 0 , 6}}                            


//{ "Incluir"     	,'Execblock("AD0011")'	, 0 , 3},;

// +-----------------------------------+
// | Cria Filtro para o mBrowse        |
// +-----------------------------------+

Private aIndSZD    := {}
Private bFiltraBrw := {|| Nil}
cCondicao  := " ZD_FILIAL = '" + xFilial("SZD") + "' .AND. " + _nFiltDev 
bFiltraBrw := {|| FilBrowse("SZD",@aIndSZD,@cCondicao)}
Eval(bFiltraBrw)


mBrowse( 6, 1,22,75,"SZD")
dbSelectArea("SZD")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SZD",aIndSZD)


Return
