#include "rwmake.ch"
// Rotina desenvolvida por Gustavo em 23/09/03
User Function AD0076() // Rotina AD0076.PRW para exclusão da Cidade

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'exclusão da Cidade')

// 1 =  Busca o Cidade
// 2 =  Verifica Relacao com a Tabela de Toneladas
// 3 =  Se nao tiver relacao confirma a exclusão
// 4 =  Se confirmado Exclui
// 5 =  Retorno para Tela anterior

// Salva a situacao Atual
_sAlias := Alias()
_nOrder := IndexOrd()
_sRec   := Recno()


//Posiciona no Registro da Cidade
_cCodCid  := ZV8->ZV8_COD
_cConfirm := .T.


dbSelectArea("ZV8")// Cidades
dbsetorder(1)
If dbSeek (xFilial("ZV8")+ _cCodCid)
	RecLock("ZV8",.F.)
	// Verifica se Tem Relacionamento com a Tabela de Tonelagens
	dbSelectArea("ZV9")
	dbSetOrder(2)
	If dbSeek(xFilial("ZV9")+ _cCodCid)
		MsgBox("CIDADE ESTA RELACIONADA COM TABELA DE TONELAGENS !!! (EXCLUSAO NAO PERMITIDA)")
		_cConfirm := .F.
	Else
		// Confirma se Exclui ou nao a Cidade se nao tiver relacao com a Tabela de tomnelagens		If _cConfirm
		RecLock("ZV8",.F.)
		_cTexto := "CODIGO: "+_cCodCid +SPACE (2)+"ESTADO :"+ZV8_EST+SPACE (2)+"CIDADE: "+(SUBSTR(ZV8_CIDADE,1,20))
		If MsgBox(_cTexto," CONFIRMA EXCLUSAO ","YESNO")
			dbDelete()
		Endif
		
	Endif
Endif	
	
	
