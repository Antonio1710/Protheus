#include "rwmake.ch"  

User Function AD0066()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu para controle de Frete por Cidade e por Preco Tonelada.')

SetPrvt("CCADASTRO,AROTINA,")

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� AD0066.PRW   � Menu para controle de Frete por Cidade e por Prec       ���
���              � Tonelada.                                               |��
���              � Uso Logistica                                           ���
��������������������������������������������������������������������������Ĵ��
��� Gustavo      � 04/09/03 �                                              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
// Controle de Frete por Cidade

// Tabela de Fretes por Cidade

dbSelectArea("ZV8")
dbSetOrder(01) // Indice codigo



//��������������������������������������Ŀ
//� Verifica as perguntas                �
//����������������������������������������

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
