#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CadReg    � Autor � Sandra Ribeiro     � Data �  31/03/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Tela para cadastro das Regioes                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Ad'oro                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CadMun()

Private cCadastro := "Cadastro de Municipios"
Private aRotina   := { {"Pesquisar" ,"AxPesqui",0,1} ,;
             		   {"Visualizar","AxVisual",0,2} ,;
             		   {"Incluir"   ,"AxInclui",0,3} ,;
             		   {"Alterar"   ,"AxAltera",0,4} ,;
             		   {"Excluir"   ,"AxDeleta",0,5} }

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro das Regioes')
					   
dbSelectArea("CC2")
dbSetOrder(1)

mBrowse( 6,1,22,75,"CC2")

Return