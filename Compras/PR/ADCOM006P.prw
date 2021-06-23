#INCLUDE "PROTHEUS.CH"                   
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  ADCOM006P  �Autor  �FERNANDO SIGOLI     � Data �01/02/2017   ���
�������������������������������������������������������������������������͹��
���Desc.     �Pre�o inicial na rotina atualiza conta��o                   ���
�������������������������������������������������������������������������͹��
���Uso       �Chamado 030494.                                             ���
�������������������������������������������������������������������������ͼ��
���Alteracao �Adriana chamado 051044 em 27/08/2019 - SAFEGG               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function ADCOM006P()    

Local aArea		:= GetArea()
Local SC8AREA	:= SC8->(GetArea())
Local nPreco	:= 0
 
Local nPosProd := aScan(aHeader,{|x|Alltrim(x[2])=="C8_PRODUTO"})
Local nPosItem := aScan(aHeader,{|x|Alltrim(x[2])=="C8_ITEM"}) 
Local nPosNpro := aScan(aHeader,{|x|Alltrim(x[2])=="C8_NUMPRO"})  
Local nPosIGRD := aScan(aHeader,{|x|Alltrim(x[2])=="C8_ITEMGRD"}) 
Local nPosPrec := aScan(aHeader,{|x|Alltrim(x[2])=="C8_XPRCCOT"})

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
                  
dbSelectArea("SC8")
dbSetOrder(10) //atualiza��o protheus 12 WILLIAM COSTA 28/12/2017 CHAMADO 036032

If dbseek(xFilial("SC8") + cA150Num + cA150Forn+ cA150Loj + aCols[n][nPosProd] + aCols[n][nPosItem] + aCols[n][nPosNpro] + aCols[n][nPosIGRD])
	If SC8->C8_XPRCCOT <= 0  
		nPreco := M->C8_PRECO
	Else
		nPreco:= aCols[n][nPosPrec]	
	EndIf	
Else
	nPreco := M->C8_PRECO    //&& n�o encontrou a soiita��o
Endif

RestArea(aArea)
RestArea(SC8AREA)

Return nPreco       


//---------------------------------------------------------------------|
//ponto de entrada para tratamento de novo participante no cota��o     |
//---------------------------------------------------------------------|
User function MT150LIN()  

Local aArea		  := GetArea()
Local nPospreco   := aScan(aHeader,{|x|Alltrim(x[2])=="C8_PRECO"})
Local nPosprcini  := aScan(aHeader,{|x|Alltrim(x[2])=="C8_XPRCCOT"})

U_ADINF009P('ADCOM006P' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

if cEmpAnt $ '01/ 09 ' // RICARDO LIMA - 17/01/18 - verifica somente para empresa 01, pois o campos C8_XPRCCOT so existe la.  //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG   
	If aCols[len(aCols)][nPospreco] <= 0
			aCols[len(aCols)][nPosprcini] := 0
	EndIf
ENDIF
RestArea(aArea)

Return( .T. )