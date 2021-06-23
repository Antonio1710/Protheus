#include "rwmake.ch" 
#include "topconn.ch"  

User Function CORPESO(_cPedido)

local cQuery := ""
LOCAL _nTotalPedi := 0
LOCAL _nTotalCx   := 0
LOCAL _nTotalKg   := 0
LOCAL _nTotalBr   := 0

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

cQuery := "SELECT C5_FILIAL, C5_NUM "
cQuery += "FROM "+RetSqlName("SC5")+ " "
cQuery += "WHERE D_E_L_E_T_ <> '*' "
//cQuery += "AND C5_PESOL = 0 "
//cQuery += "AND C5_PBRUTO = 0 "
//cQuery += "AND C5_DTENTR BETWEEN '20121107' AND '20121107' "
cQuery += "AND C5_NOTA = '' "
cQuery += "AND C5_FILIAL = '06' "
//cQuery += "AND C5_NUM = '354929' "
cQuery += "AND C5_NUM = '" + _cPedido + "'"
cQuery += "ORDER BY C5_NUM"
If _cPedido == ""
	Return
Else
	MSGALERT("PEDIDO Nº:" + CHR(13) + _cPedido)
Endif
                           
TCQUERY cQuery new alias "TRB01"

DBSELECTAREA("TRB01")
DBGOTOP()
WHILE !TRB01->(EOF())
	_nTotalCx := 0
	_nTotalKg := 0
	_nTotalBr := 0
	
	DBSELECTAREA("SC6")
	DBSETORDER(1)	
	//IF DBSEEK(XFILIAL("SC6")+TRB01->C5_NUM)
	IF DBSEEK(TRB01->C5_FILIAL + TRB01->C5_NUM)
		While !Eof() .and. SC6->C6_NUM == TRB01->C5_NUM
		
			//_nTotalPedi := _nTotalPedi + SC6->C6_VALOR
			_nTotalCx   := _nTotalCx   + SC6->C6_UNSVEN   // Soma qtd caixas (2a. UM)
			//_nTotalCx   := _nTotalCx   + SC9->C9_QTDLIB2   // Soma qtd caixas (2a. UM)
//			_nTotalKg   := _nTotalKg   + SC6->C6_QTDVEN   // Soma qtd peso   <1a. UM)
			_nTotalKg   := _nTotalKg   + iif(SC6->C6_SEGUM="BS",0,SC6->C6_QTDVEN)   // Soma qtd peso   <1a. UM) //alterado por Adriana, se bolsa nao soma 1a unidade como peso
			//_nTotalKg   := _nTotalKg   + SC9->C9_QTDLIB   // Soma qtd peso   <1a. UM)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Cadastro de Tara                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DBSELECTAREA("SB1")
			DBSETORDER(1)
			
			IF DBSEEK(XFILIAL("SB1")+SC6->C6_PRODUTO)
				dbSelectArea("SZC")
				dbSetOrder(1)
				IF dbSeek( xFilial("SZC") + SB1->B1_SEGUM )
					_nTotalBr   := _nTotalBr + (SC6->C6_UNSVEN * SZC->ZC_TARA) // PESO BRUTO
				ELSE
					_nTotalBr   := _nTotalBr + (SC6->C6_UNSVEN  * 1) // PESO BRUTO
				ENDIF
		
			ENDIF
			
			dbSelectArea("SC6")
			dbSkip()
			
		ENDDO
	ENDIF
	
	DBSELECTAREA("TRB01")
		
	dbselectarea("SC5")
	dbsetorder(1)
	//If dbseek(xFilial("SC5")+TRB01->C5_NUM)
	If dbseek(TRB01->C5_FILIAL + TRB01->C5_NUM)
		RecLock("SC5",.F.)
		&&Mauricio 26/04/10 - incluido tratamento para peso duplicado fiiais 03/04/05.
		Replace SC5->C5_PBRUTO  With _nTotalBr + Iif(!(XFILIAL("SC5")$'03/04/05'),_nTotalKg, 0)   //incluida condicao em 24/06/2008 pois em SC estava duplicando o peso 
		Replace SC5->C5_PESOL   With _nTotalKg
		Replace SC5->C5_VOLUME1 With _nTotalCx
		MsUnlock()
	EndIf
	
	TRB01->(DBSKIP())
	
ENDDO
TRB01->(DBCLOSEAREA())
MSGALERT("RODOU ACERTO!!!")

RETURN