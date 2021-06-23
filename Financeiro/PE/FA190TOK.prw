#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA190TOK() � Autor � HCCONSYS          � Data �  18/02/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Ponto de Entrada utilizado na Geracao de Cheques (FINA190) ���
���          � Nao permite que sejam utilizados cheques de mesmo numero   ���
���          � para mesma banco/agencia/conta independ. da Filial   		  ���
�������������������������������������������������������������������������͹��
���Uso       � MP8		                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function FA190TOK()

Local aArea		:= GetArea()
Local lRet		:= .T.       
Local cQuery	:= ""
Local nRegs		:= 0   

&& Verificar se ja existe cheque com numero informado, nao importando a Filial.
cQuery := "SELECT EF_BANCO,EF_AGENCIA,EF_CONTA,EF_NUM,EF_FILIAL "
cQuery += "FROM " + RETSQLNAME("SEF") + "  "
cQuery += "WHERE D_E_L_E_T_ = ' ' "
cQuery += "AND EF_BANCO 	= '" + cBanco190 		+ "'  "
cQuery += "AND EF_AGENCIA 	= '" + cAgencia19  	+ "'  "
cQuery += "AND EF_CONTA 	= '" + cConta190 		+ "'  "
cQuery += "AND EF_NUM 		= '" + cCheque190		+ "'  "

TcQuery cQuery New Alias "TSEF"

Count to nRegs

TSEF->(dbGoTop())

If nRegs > 0 
	
	MsgInfo("N�mero de cheque j� informado para a Filial " + TSEF->EF_FILIAL + ". Verifique!" )
	lRet	:= .F. 	
Endif

TSEF->(dbCloseArea())      

RestArea(aArea)

Return(lRet)
          
