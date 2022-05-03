#include "rwmake.ch"  

User Function AD0175()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Menu para Controle dos Fretes')

SetPrvt("CCADASTRO,AROTINA,")

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� AD0063       � Menu para Controle dos Fretes                           ���
���              �                                                         |��
���              � Especifico Ad'oro Alimenticia                           ���
��������������������������������������������������������������������������Ĵ��
��� Werner       � 28/08/03 � Uso Logistica                                ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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
              { "Lan�ar      "  ,'ExecBlock("AD0094")'      , 0 , 5},;
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

//������������������������������������������������������������������������Ŀ
//� Deleta o filtro utilizando a funcao FilBrowse                     	   �
//��������������������������������������������������������������������������
EndFilBrw("SZK",aIndSZK)


Return
