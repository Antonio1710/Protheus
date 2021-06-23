#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "RWMAKE.CH"  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA015MNU �Autor  �William Costa       � Data �  26/04/2019 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de Entrada localizado no bot�o de acoes relacionadas ���
���          � no cadastro de enderecos esse botao vai gerar o saldo de   ���
���          � localizacao automaticamente                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAEST                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
@history Chamado 13552 - Leonardo P. Monteiro - 07/05/2021 - Comparativo entre o saldo em estoque (SB2) e saldos por endere�o (SBF).
*/

USER FUNCTION MTA015MNU()

	Local aArea	   := GetArea()
			
	aadd( aRotina, { "Criar Saldo Endere�o", "U_ADEST041P()", 0 , 0,0,NIL})
	aadd( aRotina, { "rel. Sld. EstxSld. End", "U_ADEST065R()", 0 , 0,0,NIL})

	RestArea(aArea)
	
RETURN(NIL)
