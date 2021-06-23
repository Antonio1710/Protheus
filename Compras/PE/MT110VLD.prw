#INCLUDE "Topconn.ch"
#INCLUDE "Protheus.ch"
/*�������������������������������������������������������������������������������������������
���Programa    �MT110VLD�Ponto de Entrada que valida o registro na solicita��o de compras ���
�����������������������������������������������������������������������������������������͹��
���Autor       �01/08/12 Ana Helena                                                       ���
�����������������������������������������������������������������������������������������͹��
���Ponto de entrada executado ao clicar nos bot�es incluir / alterar / excluir / copiar da���
���solicitacao de compras. ExpN1: Cont�m o valor da opera��o selecionada:                 ���
���                                       3- Inclus�o, 4- Altera��o, 8- Copia, 6- Exclus�o���
�����������������������������������������������������������������������������������������͹��
�������������������������������������������������������������������������������������������*/
User Function MT110VLD()

Local ExpN1    := Paramixb[1]
Local ExpL1    := .T. 

If ExpN1 <> 3 .And. ExpN1 <> 8
	
	If (cEmpAnt == "01" .And. cFilAnt = "03") .Or. cEmpAnt == "07"

		cNumSC := SC1->C1_NUM
		
		dbselectArea("SC1")
		dbgotop(1)
		dbseek(xFilial("SC1")+cNumSC)
		While !Eof() .And. SC1->C1_NUM == cNumSC

			If Alltrim(SC1->C1_USER) != Alltrim(__CUSERID)  // Valida��o do Usuario para interromper a grava��o                                               
				If Alltrim(SC1->C1_CC) == "8001"
					ExpL1 := .F.  
				EndIf   
			Endif	
			dbSkip()
		End	                             
    
		If !ExpL1
			Alert("S� � permitido altera��o desta solicita��o pelo usu�rio que a incluiu")
		Endif		 
		
	Endif

Endif

Return ExpL1