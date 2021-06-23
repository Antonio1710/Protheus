#include 'protheus.ch'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �SPDFIS07  � Autor � ADRIANA OLIVEIRA      � Data � 20/03/18 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Ponto de entrada que permite a customiza��o do C�digo da    ���
���          �da Conta Cont�bil no registro H010 do SPED Fiscal.          ���
���          �MODELO PE PADRAO TOTVS-ATENCAO AO ALTERAR                   ���
�������������������������������������������������������������������������Ĵ��
���ALTERA��O �Adriana Oliveira-14/03/2019-047912, ajuste conforme         ���
���          �documentacao Portal Totvs                                   ���
���          �tdn.totvs.com/pages/releaseview.action?pageId=60771763      ���
���ALTERA��O �Adriana Oliveira-19/03/2019-047912, ajuste para outros      ���
���          �tipos de operacao                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SPDFIS07()

	Local cCodProduto := PARAMIXB[1] //Codigo do Produto
	Local cSituacao := PARAMIXB[2] // Situa��o do inventario
	Local cRetorno    := ""
	
	If cSituacao == '0'  //0- Item de propriedade do informante e em seu poder // outros tipos de operacao por Adriana em 19/03/19
	
	      cRetorno := SB1->B1_CONTA
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) = "383369" //    1- Item de propriedade do informante em posse de terceiros
	
	      cRetorno := "111580002"
	
	ElseIf cSituacao== '1' .and. Alltrim(cCodProduto) <> "383369" //    2- Item de propriedade de terceiros em posse do informante
	
	      cRetorno := "111580001"
	
	EndIf

Return cRetorno