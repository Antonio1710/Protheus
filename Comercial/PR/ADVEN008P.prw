#include "rwmake.ch"
#include "topconn.ch"
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Funcao    � ADVEN008P     � Autor � Mauricio - MDS TEC � Data �  16/09/15  ��
����������������������������������������������������������������������������Ĵ��
���Descricao � Tela de manutencao da tabela W1 do SX5 na filial 02           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/

User Function ADVEN008P()
cCadastro := "Cadastro de totalizadores"
aAutoCab    := {}
aAutoItens  := {}
PRIVATE aRotina := { { "" ,  "AxPesqui"  , 0 , 1},;  // "Pesquisar"
       				  { "",   "C160Visual", 0 , 2},;  // "Visualizar"
					  { "",   "C160Inclui", 0 , 3},;  // "Incluir"
					  { "",   "C160Altera", 0 , 4},;  // "Alterar"
					  { "",   "C160Deleta", 0 , 5} }  // "Excluir"

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela de manutencao da tabela W1 do SX5 na filial 02')
              					  
DbSelectArea("SX5")           
DbSetOrder(1)
If  !DbSeek(xFilial("SX5")+"W1",.F.)
   //MsgAlert(xFilial("SX5"))
   MsgAlert("Voce deve estar na filial 02(Varzea) para dar manuten��o nesta tabela!")
Else   
   c160altera("SX5",,3)
Endif
        
return()         