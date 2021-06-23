#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CRIAZZK  � Autor � Mauricio Silva     � Data �  06/04/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Espec�fico para popular a tabela ZZK                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Espec�fico A'DORO                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CRIAZZK()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Espec�fico para popular a tabela ZZK')

dbSelectArea("DA1")
dbSetOrder(3)
dbGoTop()

While !Eof()

   If DA1->DA1_CODTAB == "INT"
      _cProduto := DA1->DA1_CODPRO
      _cDescri  := Posicione("SB1",1,xFilial("SB1") + _cProduto, "B1_DESC")
      _cUnid    := Posicione("SB1",1,xFilial("SB1") + _cProduto, "B1_UM")         
      
      dbSelectArea("ZZK")
      Reclock("ZZK",.T.)
      ZZK->ZZK_PRODUT := _cProduto
      ZZK->ZZK_DESCRI := _cDescri
      ZZK->ZZK_UNIDAD := _cUnid
      MsUnlock()
   EndIf
   
   dbSelectArea("DA1")
   dbSkip()

EndDo            

ApMsgAlert(OemToAnsi("F I M"))

Return