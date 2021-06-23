#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AJCODM   � Autor � Paulo - TDS        � Data �  23/05/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Ajusta o c�digo do municipio                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function AJCODM()

Local oDlg01
Local oFont1

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Ajusta o c�digo do municipio')

Define MsDialog oDlg01 From 00,00 To 145,370 Title OemToAnsi("Ajusta o c�digo do Municipio") Pixel
Define Font oFont1 Name "Arial" Size 0,-14 Bold
@005,005 To 055,180 of oDlg01 Pixel
@010,020 Say OemToAnsi("Ajusta o c�digo de todos os municipios") Font oFont1 of oDlg01 Pixel
@020,020 Say OemToAnsi("de todos os clientes cadastrados.")      Font oFont1 of oDlg01 Pixel
@060,115 BmpButton Type 1 Action(lRet := .T.,Close(oDlg01))
@060,150 BmpButton Type 2 Action(lRet := .F.,Close(oDlg01))
Activate Dialog oDlg01 Centered

If lRet
   If ApMsgYesNo(OemToAnsi("Confirma o ajuste dos municipios ?"),OemToAnsi("A T E N � � O"))
      Processa({|| AJUSTMN() },OemToAnsi("Ajusta o c�digo do Municipio"))
   EndIf
EndIf

Return(lRet) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    � AJUSTMUN � Autor � Paulo - TDS        � Data �  23/05/11   ���
�������������������������������������������������������������������������͹��
���Descricao � Fun��o que executa o ajuste do c�digo do municipio         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function AJUSTMN

Local _aArea := GetArea()
Local _cCodM := Space(05)

dbSelectArea("SA1")
ProcRegua(RecCount())
dbGoTop()

While !Eof()

   IncProc()
   
   If !Empty(SA1->A1_COD_MUN)
   
      _cCodM := Posicione("CC2",2,xFilial("CC2")+SA1->A1_MUN,"CC2_CODMUN")
      
      If SA1->A1_COD_MUN != _cCodM
         RecLock("SA1",.F.)
         SA1->A1_COD_MUN := _cCodM
         MsUnLock()
      EndIf   
   
   EndIf 
   
   dbSkip()

EndDo

RestArea(_aArea)

Return