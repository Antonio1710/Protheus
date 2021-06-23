#INCLUDE "rwmake.ch"

/*/{Protheus.doc} User Function M106FIL
    PONTO DE ENTRADA PARA FILTAR APROVAÇÃO DE SOLICITACAO DE REQUISICAO AO ALMOXARIFADO 
    @type  Function
    @author WERNER DOS SANTOS
    @since 15/01/2005
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function M106FIL()   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cSuper    := SubStr(cUsuario,7,15)
Private _cUsuario  := ''
Private _cCondicao := ''
Private _cString 	 := 'SZY'
Private _aCCs      := {} // Centros de Custos do Usuario
Private _aConds    := {} // Condicoes de filtragem [usuario][CCs]
Private _cCCs      := ''

dbSelectArea("SZY")
dbSetOrder(2) // Filial + Supervisor + Usuario + CCusto
If dbSeek( xFilial('SZY') + _cSuper )
	Do While !Eof() .and. SZY->ZY_FILIAL = xFilial("SZY") .and. SZY->ZY_SUPER = _cSuper
	   _aCCS := {}
	   _cCCs := ''
	   _cUsuario := SZY->ZY_USUA
	   Do While !Eof() .and. SZY->ZY_FILIAL = xFilial("SZY") .and. SZY->ZY_SUPER = _cSuper ;
	      .and. SZY->ZY_USUA = _cUsuario
	      _nPos := aScan( _aCCs, SZY->ZY_CUSTO )
	      If _nPos = 0
		      aadd( _aCCs, SZY->ZY_CUSTO )
			EndIf
			dbSkip()
	   EndDo
	   If !Empty(_aCCS)
		   _cCCs := ''
		   For i=1 To Len(_aCCs)
		     _cCCs += AllTrim( _aCCs[i] ) + '/'
		   Next
		   _cCCs := SubStr( _cCCs, 1, Len(_cCCs)-1 )
		   aadd( _aConds, {_cUsuario, _cCCs} )
		EndIf
	EndDo
	If !Empty(_aConds)
	   _cCondicao := '('
		For i:=1 To Len(_aConds)
		   _cCondicao += 'CP_SOLICIT = "' + _aConds[i][1] + '" .and. Trim(CP_CC) $ "' + _aConds[i][2] + '") .or. ('
		Next
		_cCondicao := SubStr(_cCondicao,1,Len(_cCondicao)-7) + ' .and. CP_STATUS = " "'
	EndIf
EndIf

If Empty(_cCondicao)
	_cCondicao += 'CP_STATUS=" "'
EndIf

Return(_cCondicao)