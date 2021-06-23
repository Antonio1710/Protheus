#Include "Totvs.ch"

/*/{Protheus.doc} CEXCONSC7
@description 	Ponto de entrada na conversao do fator do produto
@obs			Nao utilizar a conversao, devolver o a quantidade atual
@author 		Fabrica de Software Fabritech
@since 			02/03/2018
@version		1.0
@return			Nil
@type 			Function
/*/
User Function CEXCONSC7()
	Local nPosDoc	:= Ascan( aHeader, { |x| Alltrim( x[2] ) == "D1_QUANT" 	} )
	Local nPosXML	:= Ascan( aHeader, { |x| Alltrim( x[2] ) == "XIT_QTENFE"} )
	Local aParamIXB	:= PARAMIXB
	Local nRetQtd	:= 0
	
	//Compara as unidades de medida, caso sejam diferentes, forca a nao fazer a conversao
	//Caso sejam iguais, prevalece a quantidade da NF-e
	//If Alltrim( aParamIXB[ 01 ] ) <> Alltrim( aParamIXB[ 02 ] )
		nRetQtd	:= aCols[ N ][ nPosDoc ]
	//Else
		//nRetQtd	:= aCols[ N ][ nPosXML ]
	//EndIf
	
Return nRetQtd
