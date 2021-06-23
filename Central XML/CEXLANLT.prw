#INCLUDE "Protheus.ch"

/*/{Protheus.doc} CEXLANLT
@description 	PE Lancamento CT-e em Lote.
@author 		Fabrica de Software Fabritech
@version		1.0
@return			Nil
@type 			Function
/*/
User Function CEXLANLT()  
	Local cTitulo		:= "Alteracao de Vencimento de Titulos"
	Local dDtVencLot	:= StoD( "" )    
	Local aParamBox		:= {}   
	Local aRet 			:= {}   

	Aadd( aParamBox,{ 1, "Data de Vencimento:", dDtVencLot	,"","","","",0, .T.	} )
	
	//Variavel private aCtePriv herdada da Central XML afim de gravar informacoes para o PE CEXLANLT e 
	//ser utilizada em demais PEs.
	If ValType( aCtePriv ) == "A"
		
		If MsgYesNo( "Gostaria de Alterar a data de Vencimento dos títulos gerados para este Lote?" )
			If ParamBox( aParamBox, cTitulo, @aRet )
				Aadd( aCtePriv, aRet[ 1 ] )
			EndIf
		EndIf
		 
	EndIf

Return Nil
