#INCLUDE "PROTHEUS.CH"

//?---------?------------------?------B----------------------------------------?----?-----------?
//|PROGRAMA | MT140OK          |AUTOR | DANIEL PITTHAN SILVEIRA                |DATA|20/03/07   |
//?---------+------------------?------?----------------------------------------?----?-----------?
//|DESCRICAO| Ponto de entrada executado na validacao da pre-nota.                              |
//|         | Usado para consistir a Loja do pedido de compras com a Loja do fornecedor         |
//|         | na pre-nota                                                                       |
//|         |                                                                                   |
//?---------+----------------------?-----?------------------------------------------------------?
//|MODULO   | COMPRAS              |TIPO | [ ] - PROCESSAMENTO          [ ] - TRANSACAO         |
//|         |                      |     | [X] - PONTO DE ENTRADA       [ ] - VALIDACAO         |
//|         |                      |     | [ ] - GATILHO                [ ] - CONSULTA          |
//|         |                      |     | [ ] - RELATORIO                                      |
//?---------+--------------?-------?-----?----?-------------------------------------------------?
//|MANUT.   |DATA          | AUTOR            |DESCRICAO                                        |
//?---------+--------------+------------------+-------------------------------------------------?
//|CH TI    |09/05/2019    |Everson           | Everson 09/05/2019.Valida??o data de emiss?o.   |
//|CH TI    |10/05/2019    |Everson           | Everson 09/05/2019.Valida??o esp?cia documento. |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//?---------?--------------?------------------?-------------------------------------------------?

USER FUNCTION MT140TOK 

	//?????????????????????????????????????????????????????????????????????Ŀ
	//? Declara??o de vari?veis.                                            |
	//???????????????????????????????????????????????????????????????????????
	Local dDtLEmis	:= GetMV('MV_#DTEMIS') //Everson - 09/05/2019. Chamado TI.

	//+----------------------------------------------------------+
	//|DECLARACAO DE VARIAVEIS                                   |
	//+----------------------------------------------------------+
	//+----------------------------------+
	//|AMBIENTE                          |
	//+----------------------------------+      
	Private _aAreaSF1	:=SF1->(GetArea())		//SD1
	Private _aAreaSD1	:=SD1->(GetArea())		//SF1
	Private _aAreaSC7	:=SC7->(GetArea())		//SC7

	Private _cFilSF1	:=xFilial("SF1")
	Private _cFilSD1	:=xFilial("SD1")
	Private _cFilSC7	:=xFilial("SC7")

	DBSELECTAREA("SC7"); DBSETORDER(3)		//FILIAL+FORNECEDOR+LOJA+PEDIDO

	//+----------------------------------+
	//|DADOS                             |
	//+----------------------------------+
	Private _cPed		:=''		//Pedido de Compras
	Private _lRet		:=.T.		//retono

	//?????????????????????????????????ͻ
	//? PROGRAMA PRINCIPAL              ?
	//?????????????????????????????????ͼ

	//+----------------------------------+
	//|OBTENDO DADOS DO PEDIDO           |
	//+----------------------------------+
	_cPed	:=aCols[1][aScan	( aHeader, {|x| ALLTRIM(x[2])=="D1_PEDIDO"		} 	)]

	//+-----------------------------------+
	//|POSICIONANDO NO PEDIDO             |
	//+-----------------------------------+
	DBSELECTAREA("SC7")
	If DbSeek(_cFilSC7+cA100For+cLoja+_cPed,.T.)
		If SC7->C7_LOJA<>cLoja    
			MsgInfo("Loja do Fonecedor nao e igual ao do pedido.")
			_lRet:=.F.
		EndIf
	EndIf

	//?????????????????????????????????ͻ
	//? FIM                             ?
	//?????????????????????????????????ͼ
	
	//Everson - 09/05/2019. Chamado TI.
	If Len(Alltrim(DTOS(dDtLEmis))) > 0
		If DDEMISSAO <= dDtLEmis
			AVISO('Bloqueio de Data de Emiss?o', 'A data de emiss?o do documento ? inferior ao permitido para digita??o. Consulte o Depto. Fiscal!', {"Fechar"}, 1 )   
			_lRet := .F.			 
		Endif
	Endif
	//
	
	//Everson - 10/05/2019. Chamado TI.
	If Empty(Alltrim(cValToChar(CESPECIE)))
		AVISO('Bloqueio de Espec. Docum.', '? obrigat?rio informar a esp?cie do documento.', {"Fechar"}, 1 )   
		_lRet := .F.	
	
	EndIf
	//

	//+----------------------------------+
	//|RESTAURANDO O AMBIENTE            |
	//+----------------------------------+
	RestArea(_aAreaSF1)
	RestArea(_aAreaSD1)
	RestArea(_aAreaSC7)
	
RETURN (_lRet)