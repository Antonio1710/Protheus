#include "protheus.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTB102EXC �Autor  �Microsiga           � Data �  01/14/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada para tratar as movimentacoes dos registros���
�������������������������������������������������������������������������͹��
���Uso       � Adoro - SERVIDOR PRODUCAO                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CTB102EXC()

Local aParam	:= PARAMIXB
Local lRet		:= .T.
Local nRegTMP	:= TMP->(Recno())
Local lServPR := GetMv("MV_#SERVPR",,.F.)
Local cProces := Posicione("SX5",1,Space(2)+"_X","X5_CHAVE")

If lServPR
	dbSelectArea("TMP")
	TMP->( dbGoTop() )
	Do While TMP->( !Eof() )
		If cProces == "PROCES"
			lRet	:= .F.
			Aviso(	"Lan�amento Cont�bil",;
			"Este lancamento nao podera ser movimentado. Processamento SIG em andamento. Contate a Contabilidade.",;
			{"&Ok"},,;
			"Altera��o Inv�lida" )
			Exit
		EndIf
		TMP->( dbSkip() )
	EndDo
EndIf

Return lRet