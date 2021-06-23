#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

USER FUNCTION MA261LIN()

	Local lRet        := .T.
	Local nPosCodOri  := aScan(aHeader, {|x| AllTrim(Upper(x[1]))=='PROD.ORIG.'}) // esse Scan esta diferente pois ele pega a primeira posicao do AHEADER o correto e a segunda se fez necessario pois na transferencia multiplas existe dois campos com o nome D3_COD pois eu preciso do produto de Origem
	Local nPosCodDest := aScan(aHeader, {|x| AllTrim(Upper(x[1]))=='PROD.DESTINO'}) // esse Scan esta diferente pois ele pega a primeira posicao do AHEADER o correto e a segunda se fez necessario pois na transferencia multiplas existe dois campos com o nome D3_COD pois eu preciso do produto de Destino
	Local nLinha      := PARAMIXB[1]  // numero da linha do aCols
	
	IF !EMPTY(aCols[nLinha][nPosCodDest]) // se codigo destino for diferente de vazio entra no if
	
		IF aCols[nLinha][nPosCodOri] <> aCols[nLinha][nPosCodDest] // se codigos de produtos forem diferentes entra no if
		
			IF __cUserId $ GETMV("MV_#USUTR2",,'001428/001908')
				
				lRet := .T.
			
			ELSE
			
				lRet := .F.
				
				MsgAlert("OLÁ " + Alltrim(cUserName) + ", VOCÊ NÃO TEM PERMISSÃO PARA GERAR TRANSFERÊNCIAS COM PRODUTOS DIFERENTES", "MA261LIN-01")
				
			ENDIF
		
		ENDIF
	
	ENDIF

RETURN(lRet)
	
