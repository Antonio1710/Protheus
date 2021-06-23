#include "rwmake.ch"

User Function AD0073()

// Atualizacao do Frete Arquivo (SZK010), Execblock executado dentro
// da funcao AD0043 (Retorno de Viagem)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtuFrete ³ Autor ³ Werner / Gustavo      ³ Data ³ 23/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizar Valor do Frete  Quando for retorno de Viagem     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Ad'oro Alimenticia                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/
/*/
// Parametros  Guia , Data, Placa , KmRetorno
// Parmetros    _nGuia , _dDatGuia ,  _cPlac ,_kmEnt
//34

// Ambiente Inicial

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Atualizar Valor do Frete  Quando for retorno de Viagem')

_cAlias := Alias() ; _nOrder := IndexOrd() ; _nRecno := Recno()

_cCodFor   :=  space(6)
_cLojFor   :=  space(2)
_cNomFor   :=  space(30)
_cTabPrec  :=  space(2)
_TipTabela :=  space(2)
// Dados do Frete posicionado
_nGuia    := SZK->ZK_GUIA
_dDatEntr := M->ZK_DTENTR
_cPlac    := SZK->ZK_PLACA
//	Tabela de Frete
_TipTabela:= M->ZK_TABELA
// Km Paga
_kmPag    := M->ZK_KMENT - M->ZK_KMSAI
// _kmPag    := M->ZK_KMPAG
// Calculo do Valor Frete
_Vlvei    := 0
_Vlentre  := 0
_Nentre   := M->ZK_ENTREGA - M->ZK_ENTRDEV
_Bandeir  := 0
_vValFret  := 0
// Verifico se a placa de referencia e igual a placa paga 
dbSelectArea("SZG")
dbSetOrder(1)
If dbSeek (xFilial("SZG")+_TipTabela)
	dbSelectArea("ZVB")
    dbSetOrder(1)
	If dbSeek (xFilial("ZVB")+_TipTabela) 
	   While _TipTabela = ZVB->ZVB_CODTAB
	        If (_dDatEntr >= ZVB->ZVB_DATINI ).AND. (_dDatEntr <= ZVB->ZVB_DATFIM ) 		        
    		        _Vlvei    := ZVB->ZVB_PRECO
                	_Vlentre  := ZVB->ZVB_VLENTR
                	_Bandeir  := ZVB->ZVB_BANDEI                 	
	        End If
	        Dbskip()
	   End Do
	Else
	   Alert("Não existe preço cadastrado para este tipo de frete.")
	End If
	
	// Se calcula frete ou nao
	If SZG->ZG_CALFRET = 'S'
		_vValFret  := (_kmPag * _Vlvei) + (_Vlentre * _Nentre ) + _Bandeir 
		If _vValFret <= 0
		   	ALERT("Verifique o cadastro de frete para esta data de entrega, pois nao possui preço cadastrado para esta data")
		End If   	
//_cTexto := " Valor "+str(_vValFret,12,2)+" Kmpag "+str(_kmPag,6)+" Vlr Vei  "+str(_Vlvei,8,2)+" Ent * Vlr "+str((_Vlentre * _Nentre ),8,2)+" Ban. "+ str(_Bandeir,8,2) 		
//MSGBOX(_cTexto)		
	Else
		_vValFret  := 0
	Endif
Endif



// Zerar Variaveis
_Vlvei    := 0
_Vlentre  := 0
_Nentre   := 0
_Bandeir  := 0


dbCloseArea("SZK")
dbCloseArea("SZG")
dbCloseArea("ZV4")

// Restaura ambiente Inicial
dbSelectArea(_cAlias) ; dbSetOrder(_nOrder) ;dbGoto(_nRecno)

// Retorna o Valor do Frete

Return _vValFret

