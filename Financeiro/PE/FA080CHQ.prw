#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA080CHQ  � Autor � HCCONSYS           � Data �  12/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada utilizado na Baixa de Titulos Pagar       ���
���          � Nao permite que sejam utilizados cheques de mesmo numero   ���
���          � para mesma banco/agencia/conta independ. da Filial   		  ���
�������������������������������������������������������������������������͹��
���Uso       � MP8		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA080CHQ()
Local aArea		:= GetArea()
Local lRet		:= .T.       
Local cQuery	:= ""
Local nRegs		:= 0 

&& Verificar se ja existe cheque com numero informado, nao importando a Filial.
cQuery := "SELECT EF_BANCO,EF_AGENCIA,EF_CONTA,EF_NUM,EF_FILIAL "
cQuery += "FROM " + RETSQLNAME("SEF") + "  "
cQuery += "WHERE D_E_L_E_T_ = ' ' "
cQuery += "AND EF_BANCO 	= '" + cBanco	 		+ "'  "
cQuery += "AND EF_AGENCIA 	= '" + cAgencia	 	+ "'  "
cQuery += "AND EF_CONTA 	= '" + cConta	 		+ "'  "
cQuery += "AND EF_NUM 		= '" + cCheque			+ "'  "

TcQuery cQuery New Alias "TSEF"

Count to nRegs

TSEF->(dbGoTop())

If nRegs > 0 
	
	MsgInfo("Numero de cheque ja informado para a Filial " + TSEF->EF_FILIAL + ". Verifique!" )
	lRet	:= .F. 	
Endif

TSEF->(dbCloseArea())      

RestArea(aArea)

Return(lRet)