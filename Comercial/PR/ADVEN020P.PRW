#include "rwmake.ch"
#include "topconn.ch"
/*/                                                 	
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ADVEN008P     ³ Autor ³ Mauricio - MDS TEC ³ Data ³  16/09/15  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de manutencao da tabela W1 do SX5 na filial 02           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADVEN020P()
cCadastro := "Manutencao das Regioes Comerciais"
aAutoCab    := {}
aAutoItens  := {}
PRIVATE aRotina := { { "Pesquisar" ,  "AxPesqui"  , 0 , 1},;  // "Pesquisar"
       				  { "Visualizar",   "C160Visual", 0 , 2},;  // "Visualizar"
					  { "Incluir",   "C160Inclui", 0 , 3},;  // "Incluir"
					  { "Alterar",   "C160Altera", 0 , 4},;  // "Alterar"
					  { "Excluir",   "C160Deleta", 0 , 5} }  // "Excluir"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de manutencao da tabela W1 do SX5 na filial 02 ')
              					  
DbSelectArea("SX5")           
DbSetOrder(1)
If  !DbSeek(xFilial("SX5")+"W2",.F.)
   //MsgAlert(xFilial("SX5"))
   MsgAlert("Voce deve estar na filial 02(Varzea) para dar manutenção nesta tabela!")
Else   
   c160altera("SX5",,3)
Endif
        
return()         