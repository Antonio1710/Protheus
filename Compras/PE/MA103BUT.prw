#Include "Totvs.ch"

/*/{Protheus.doc} MA103BUT
@author 		Fabrica de Software Fabritech
@Obs			Copiar esse trecho para o fonte XMLMT103 (Funcao MA103BXX)
@Obs			Ele e utilizado para clientes que nao querem usar o ponto de entrada e fazem a chamada manualmente
@version		1.0
@return			Nil
@type 			Function
/*/
User Function MA103BUT( aInfo )
	Local lCstOrig	:= SuperGetMV( "XM_CSTXML", Nil, .F. )
	Local aAreaAT	:= GetArea()
	Local aButtons	:= {}
	Local nLinBkp	:= 0
	Local nX		:= 0
	Local nI		:= 0
	
	Local nProNFE	:= 0
	Local nProXML	:= 0
	Local nClasFi	:= 0
	Local nClaOri	:= 0
	
	If ExistBlock( "MX103BUT" )
	 	If ValType( axButtons := ExecBlock( "MX103BUT", .F., .F.,{aInfo} ) ) == "A"
			AEval( axButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	Endif
	
	If Type("lXmlMt103") <> "U" .And. !lVisDocG
		If lXmlMt103
			Aadd( aButtons, { "POSCLI",{ || U_CEXMTOCO() }, "Importar XML NF-e" } )
		Else			
			
			//Atualiza CFOP no Acols a Classificar
			If Type( "aColsBk" ) <> "U" .And. Type( "aHeaderBk" ) <> "U"
				
				nLinBkp	:= N
				
				For nX 	:= 1 To Len( aCols )

					nProNFE	:= Ascan( aHeader,   { |x| Alltrim( x[ 2 ] ) == "D1_COD"		} )
					nProXML	:= Ascan( aHeaderBk, { |x| Alltrim( x[ 2 ] ) == "D1_COD" 		} )
					nClasFi	:= Ascan( aHeader, 	 { |x| Alltrim( x[ 2 ] ) == "D1_CLASFIS"	} )
					nClaOri	:= Ascan( aHeaderBk, { |x| Alltrim( x[ 2 ] ) == "XIT_CSTXML"	} )
					N		:= nX

					If Len( aCols ) == Len( aColsBk )

						If nProNFE > 0 .And. nProXML > 0

							If ValType( aColsBk[ nX ] ) == "A" .And. Alltrim( aColsBk[ nX ][ nProXML ] ) == Alltrim( aCols[ nX ][ nProNFE ] )

								//Caso preserve a CST original, reatribui valor que foi alterado pelo gatilho da TES
								If lCstOrig

									If nClasFi > 0 .And. nClaOri > 0
										aCols[ nX ][ nClasFi ]	:= aColsBk[ nX ][ nClaOri ]
									EndIf

									MaFisLoad( "IT_CLASFIS", "", N )
									MaFisAlt( "IT_CLASFIS", aCols[ N ][ nClasFi ], N )
									MaFisToCols( aHeader, aCols, N, "MT100" )

								EndIf

							EndIf

						EndIf

					Else

						For nI := 1 To Len( aColsBk )
							If Alltrim( aColsBk[ nI ][ Ascan( aHeaderBk, { |x| Alltrim(x[2]) == "D1_COD" }) ] ) == Alltrim( aCols[nX][nProNFE] )

								//Caso preserve a CST original, reatribui valor que foi alterado pelo gatilho da TES
								If lCstOrig

									If nClasFi > 0 .And. nClaOri > 0
										aCols[ nX ][ nClasFi ]	:= aColsBk[ nI ][ nClaOri ]
									EndIf

									MaFisLoad( "IT_CLASFIS", "", N )
									MaFisAlt( "IT_CLASFIS", aCols[N][nClasFi], N )
									MaFisToCols( aHeader, aCols, N, "MT100" )

								EndIf

							EndIf
						Next nI

					EndIf

				Next nX

				//Atualiza UF para Inicio e Fim da Prestacao (CT-e)
				If IsInCallStack( "U_RECNFECTE" )
					If SF1->( FieldPos("F1_UFORITR") ) > 0
						MaFisRef( "NF_UFORIGEM"	, "MT100"	, SF1->F1_UFORITR	)
					EndIf
					If SF1->( FieldPos("F1_UFDESTR") ) > 0
						MaFisRef( "NF_UFDEST"	, "MT100"	, SF1->F1_UFDESTR	)
					EndIf
				EndIf

				N := nLinBkp
				
				//Da o Refresh
				If Type( "oGetDados:oBrowse" ) <> "U"
					oGetDados:oBrowse:Refresh()
				EndIf

			EndIf
		Endif
	Endif
	
	RestArea( aAreaAT )
	
Return aButtons
