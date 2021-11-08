#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
 
/*/
{Protheus.doc} User Function MT116TOK
	Este ponto de entrada pertence a rotina de digitação de conhecimento de frete, MATA116(). É executado na rotina de
    inclusão do conhecimento de frete, A116INCLUI(), quando a tela com o conhecimento e os itens são montados. 
	@type  Function
	@author Abel Babini  
	@since 18/06/2019
	@version 01
	@history  Ch.049508 - Abel Babini - 17/06/2019 - Valida Ped Compra CTE
	@history  Ch. 050177 - Abel Babini - 01/07/2019 - Ajuste na validação
	@history  Ch. 049468 - Abel Babini - 22/07/2019 - Valida Recusa Adoro
	@history  Ch. 050434 - Abel Babini - 30/07/2019 - Valida CTE x Produto 
	@history  Ch. 051082 - Abel Babini - 13/08/2019 - CTE X PED. COMP
	@history  Ch. 051294 - Abel Babini - 27/08/2019 - Incluido condição OR para excluir CTE sem precisar validar Pedido de Compra 
	@history  Ch. 052387 - Abel Babini - 08/10/2019 - Valida CTE x Pedido (Noemi)
	@history  tkt T.I    - Sigoli      - 05/11/2021 - Tratamento errolog  - type mismatch on +=  on U_VLDPCCTE(RECNFECTE.PRW) 16/07/2021 12:02:18 line : 3632
*/

USER FUNCTION MT116TOK()

	Local lRet          := .T.
	Local cGetPV 	:= Space( TamSx3("C7_NUM")[01] )
	Local cGetIT 	:= Space( TamSx3("C7_ITEM")[01] )
	Local oBtnCan	:= Nil
	Local oBtnOk	:= Nil
	Local oGetIT	:= Nil
	Local oGetPV	:= Nil
	Local oSayIT	:= Nil
	Local oSayPC	:= Nil
	Local oSelPed	:= Nil
	Local oDlgGPC	:= Nil
	Local nOpcX		:= 0
	Local cCodFor	:= Space( TamSx3("A2_COD")[01] )
	Local cLojFor	:= Space( TamSx3("A2_LOJA")[01] ) 	
	Local nValNF	:= 0
	Local nValPC	:= 0
	Local aXItPC	:= {}
	Local i         := 0

	Private cMensagem  := ''
	Private nCont      := 0
	Private nPosProd   := ASCAN(AHEADER, { |X| ALLTRIM(X[2]) == "D1_COD" })
	Private nPosTot    := ASCAN(AHEADER, { |X| ALLTRIM(X[2]) == "D1_TOTAL" })
	Private nPosPedido := ASCAN(AHEADER, { |X| ALLTRIM(X[2]) == "D1_PEDIDO" }) //Chamado: 034249 Fernando Sigoli 29/09/2017
	Private nPosItPed	:= ASCAN(AHEADER, { |X| ALLTRIM(X[2]) == "D1_ITEMPC" }) //Chamado: 034249 Fernando Sigoli 29/09/2017
	Private cNfOrig    := ''
	Private cSerieOrig := ''
	Private cForOrig   := ''
	Private cLojaOrig  := '' 
	Private i      	   := 0 //Chamado: 034249 Fernando Sigoli 29/09/2017

	If IsInCallStack("U_CENTNFEXM") .AND. INCLUI //Ch.051294 - 27/08/2019 - Abel Babini Filho - Incluido condição AND para excluir CTE sem precisar validar Pedido de Compra
		dbSelectArea('ZCW')
		dbSetOrder(2)
		If ZCW->(dbSeek(xFilial('ZCW')+RECNFCTE->XML_CHAVE))
			AVISO('Bloqueio de Classificação', 'Este CTe foi recusado e não pode ser classificado. Consulte o Depto. Fiscal!', {"Fechar"}, 1 )   
			Return .F.
		Endif
	Endif
	
	If IsInCallStack("U_CENTNFEXM") .AND. INCLUI //Ch.051294 - 27/08/2019 - Abel Babini Filho - Incluido condição OR para excluir CTE sem precisar validar Pedido de Compra
		cCodFor	:= Posicione("SA2",3,xFilial("SA2")+RECNFCTE->XML_EMIT,"A2_COD")
		cLojFor	:= Posicione("SA2",3,xFilial("SA2")+RECNFCTE->XML_EMIT,"A2_LOJA")	
	 
		cGetIT	:= "0001"
		 
		DEFINE MSDIALOG oDlgGPC TITLE "Selecionar Pedido de Compra" FROM 000, 000  TO 165, 310 COLORS 0, 16777215 PIXEL style 128
		oDlgGPC:lEscClose     := .F. //Nao permite sair ao se pressionar a tecla ESC.
	
		@ 007, 007 GROUP oSelPed TO 060, 147 PROMPT " Informe o Pedido de Compras " OF oDlgGPC COLOR 0, 16777215 PIXEL
		
		@ 022, 015 SAY oSayPC PROMPT "Pedido de Compra:"	SIZE 050, 007 OF oDlgGPC COLORS 0, 16777215 PIXEL
		@ 022, 080 SAY oSayIT PROMPT "Item:" 				SIZE 050, 007 OF oDlgGPC COLORS 0, 16777215 PIXEL
		
		@ 032, 015 MSGET oGetPV VAR cGetPV SIZE 060, 010 OF oDlgGPC COLORS 0, 16777215 PIXEL Valid !Empty(cGetPV) 
		@ 032, 080 MSGET oGetIT VAR cGetIT SIZE 060, 010 OF oDlgGPC COLORS 0, 16777215 PIXEL Valid !Empty(cGetIT) 
		
		DEFINE SBUTTON oBtnOk	FROM 068, 046 TYPE 01 OF oDlgGPC ENABLE Action( IIF( ValidPC( cGetPV, cGetIT, cCodFor, cLojFor ), ( nOpcX := 1, oDlgGPC:End() ), .F. ) )
		DEFINE SBUTTON oBtnCan 	FROM 068, 079 TYPE 02 OF oDlgGPC ENABLE Action( nOpcX := 2, oDlgGPC:End() )
	
		ACTIVATE MSDIALOG oDlgGPC CENTERED
	
		//Faz a gravacao do pedido de compras
		If nOpcX == 1
			If SC7->( DbSeek( xFilial("SC7") + cGetPV + cGetIT )) .AND.;
						Alltrim(SC7->C7_FORNECE) == Alltrim(cCodFor) .AND. ;
						Alltrim(SC7->C7_LOJA) == Alltrim(cLojFor) 

				nRecOri := SC7->(RecNo())
				aXItPC := {}
				While ! SC7->(eof()) .AND. ;
						SC7->C7_FILIAL = xFilial("SC7") .AND. ;
						SC7->C7_NUM == cGetPV .AND. ;
						Alltrim(SC7->C7_FORNECE) == Alltrim(cCodFor) .AND. ;
						Alltrim(SC7->C7_LOJA) == Alltrim(cLojFor)
					
					aAdd(aXItPC,SC7->C7_ITEM) //Ch.050177 - Abel Babini - Ajuste na validação - 01/07/2019
					RecLock( "SC7", .F. )
					SC7->C7_QUJE := 1
					MsunLock()
					
					SC7->(dbSkip())
				EndDo
				SC7->(dbGoTo(nRecOri))

				For i:=1 to Len(aCols)
					aCols[i][nPosPedido]	:= cGetPV
					aCols[i][nPosItPed]		:= IIF(i>Len(aXItPC),cGetIT,aXItPC[i])
				Next i		
			Else
				uMsgErr("Pedido não localizado ou inválido!")
				Return .F.
			EndIf
		
		Else
			uMsgErr("Não é possível continuar sem selecionar um pedido válido!")
			Return .F.
		EndIf	
	Endif

	//Quando passar pela central, nao validar o pedido de compra, uma vez que a informaçao do pedido na central é obrigatorio
	If IsInCallStack( "U_CEXMCONTR" ) .or. (IsInCallStack( "U_RECNFECTE" ) .AND. !INCLUI) //Ch.051294 - 27/08/2019 - Abel Babini Filho - Incluido condição OR para excluir CTE sem precisar validar Pedido de Compra
		Return lRet
	EndIf
	
	IF UPPER(ALLTRIM(FUNNAME())) == UPPER(ALLTRIM("IntNFEB")) 
	
		cNfOrig     := STRZERO(VAL(IIF(ALLTRIM(cPnfOri) == '',cDocOri,cPnfOri)),9)
		cSerieOrig  := IIF(ALLTRIM(cPseriOri)           == '',cSerieOri,cPseriOri) 
		cForOrig    := IIF(ALLTRIM(cPforneceOri)        == '',cFornecOri,cPforneceOri)
		cLojaOrig   := IIF(ALLTRIM(cPLojaOri)           == '',cLojaForOri,cPLojaOri)
		
		FOR nCont := 1 TO LEN(aCols)
		    
			SqlBuscaNotaOrig()
			While TRB->(!EOF())
			
					IF ALLTRIM(TRB->D1_COD) <> ALLTRIM(aCols[nCont,nPosProd])
					
						lRet := .F.  
			
						cMensagem := "MT116TOK-02"                                           + "<br>" + ;
						             "<b>Produto Diferente de Nota Original com Nota de Frete,"       + ;
						             " favor verificar </b>"                                 + "<br>" + ;
						             "Nota: "            + cDocFrete                         + "<br>" + ; 
						             "Serie: "           + cSerieFrete                       + "<br>" + ; 
						             "Fornecedor: "      + cForneceFrete                     + "<br>" + ; 
						             "Loja: "            + cLojaFrete                        + "<br>" + ; 
						             "Nota Orig: "       + cNfOrig                           + "<br>" + ; 
						             "Serie Orig: "      + cSerieOrig                        + "<br>" + ; 
						             "Fornecedor Orig: " + cFornecOrig                       + "<br>" + ; 
						             "Loja Orig: "       + cLojaOrig                         + "<br>" + ;
						             "Prod Orig: "       + ALLTRIM(TRB->D1_COD)              + "<br>" + ;
						             "Prod Frete: "      + ALLTRIM(aCols[nCont,nPosProd])    + "<br>" + ;
						             "<b>Nota não Importada !!! </b>"
			             
			             
		 				EmailNota(cMensagem)		             
		 				
		 				IF ALLTRIM(cMensFinal) == ''
			
							cMensFinal += 'Nota(s) Fiscal(is) Não Importadas: ' + cDocFrete
							
						ELSE
						
							cMensFinal += ', ' + cDocFrete
						
						ENDIF
		                  
		            ENDIF
		            
		            IF aCols[nCont,nPosTot] < 1
					
						lRet := .F.  
			
						cMensagem := "MT116TOK-03"                                            + "<br>" + ;
						             "<b>Valor Total da Nota de Frete menor que um real,"              + ;
						             " favor verificar </b>"                                  + "<br>" + ;
						             "Nota: "            + cDocFrete                          + "<br>" + ; 
						             "Serie: "           + cSerieFrete                        + "<br>" + ; 
						             "Fornecedor: "      + cForneceFrete                      + "<br>" + ; 
						             "Loja: "            + cLojaFrete                         + "<br>" + ; 
						             "Nota Orig: "       + cNfOrig                            + "<br>" + ; 
						             "Serie Orig: "      + cSerieOrig                         + "<br>" + ; 
						             "Fornecedor Orig: " + cFornecOrig                        + "<br>" + ; 
						             "Loja Orig: "       + cLojaOrig                          + "<br>" + ;
						             "Prod Frete: "      + ALLTRIM(aCols[nCont,nPosProd])     + "<br>" + ;
						             "Vl Total: "        + cValtoChar(aCols[nCont,nPosTot]) + "<br>" + ;
						             "<b>Nota não Importada !!! </b>"
			             
			             
		 				EmailNota(cMensagem)		             
		 				
		 				IF ALLTRIM(cMensFinal) == ''
			
							cMensFinal += 'Nota(s) Fiscal(is) Não Importadas: ' + cDocFrete
							
						ELSE
						
							cMensFinal += ', ' + cDocFrete
						
						ENDIF
		                  
		            ENDIF
		            
		            TRB->(dbSkip())
			ENDDO
			TRB->(dbCloseArea())
		NEXT
	
	Else //Chamado: 034249 Fernando Sigoli 29/09/2017
		
		For i := 1 to Len(aCols)
		
			If Empty(Alltrim(aCols[i,nPosPedido]))
			
				Alert("Atenção, pedido de compra não vinculado ao documento - CTE ")
			    lRet := .F.  
			    Exit
			
			EndIf
		
	    Next i
        
		If lRet 
		
			DbSelectArea("SC7")
			SC7->(dbgotop())
			SC7->(dbSetOrder(1)) 
			If DbSeek(xFilial("SC7") + Alltrim(aCols[1,nPosPedido]))
				While SC7->(!EOF()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == Alltrim(aCols[1,nPosPedido])
   					RecLock("SC7",.F.)
					SC7->C7_QUJE := 1
					MsunLock()  
   			 	SC7->(DbSkip())	
				EndDo
            Else
            	Alert("Atenção, pedido de compra não encontrado "+Alltrim(aCols[1,nPosPedido])+ " - CTE ")
		 		lRet := .F.
            EndIf
		
        EndIf 
        
   	EndIf
	
RETURN(lRet)


Static Function SqlBuscaNotaOrig() 

	Local cFil := xFilial("SD1")
                                                                         
	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT D1_FILIAL,
			       D1_DOC,
				   D1_SERIE,
				   D1_COD,
				   D1_TOTAL
			  FROM %Table:SD1% 
			 WHERE D1_FILIAL   = %EXP:cFil%
			   AND D1_DOC      = %EXP:cNfOrig%
			   AND D1_SERIE    = %EXP:cSerieOrig%
			   AND D1_FORNECE  = %EXP:cForOrig%
			   AND D1_LOJA     = %EXP:cLojaOrig%
			   AND D_E_L_E_T_ <> '*'
	EndSQl             
RETURN(NIL) 

STATIC FUNCTION EmailNota(cMensagem)		             

    Local cServer      := Alltrim(GetMv("MV_RELSERV"))  
    Local cAccount     := AllTrim(GetMv("MV_RELACNT"))
    Local cPassword    := AllTrim(GetMv("MV_RELPSW"))
    Local cFrom        := AllTrim(GetMv("MV_RELACNT"))
    Local cTo          := AllTrim(GetMv("MV_#EMAFIS"))
    Local lOk          := .T.  
    Local lAutOk       := .F. 
    Local lSmtpAuth    := GetMv("MV_RELAUTH",,.F.) 
    Local cSubject     := ""  
    Local cBody        := ""
    Local cAtach       := ""               
    Local _cStatEml    := ""
    Local _cPedido     := ""
    Local _cStatEml    := ""
    
	//** INICIO ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA ** \\
                            
    cBody        := RetHTML(cmensagem)
    lOk          := .T.  
    lAutOk       := .F. 
    Connect Smtp Server cServer Account cAccount Password cPassword Result lOk
	                        
	IF lAutOk == .F.
		IF ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
	    ELSE
	        lAutOk := .T.
	    ENDIF
	ENDIF

	IF lOk .And. lAutOk     
	   cSubject := "INTEGRACAO SAG x PROTHEUS FRETE "          
	   Send Mail From cFrom To cTo Subject cSubject Body cBody ATTACHMENT cAtach Result lOk
	ENDIF            
	
	IF lOk
	   Disconnect Smtp Server
	ENDIF
				                        
    //** FINAL ENVIO DE EMAIL CONFIRMANDO A GERACAO DO PEDIDO DE VENDA ** \\

RETURN(NIL)   


Static Function RetHTML(cmensagem)

	Local cRet       := "" 
	Local nContEmail := 0

	cRet := "<p <span style='"
	cRet += 'font-family:"Calibri"'
	cRet += "'><b>INTEGRACAO SAG X PROTHEUS............: </b>" 
	cRet += "<br>"                                                                                        
	cRet += "<b>STATUS.............: </b>"
	cRet += " INTEGRACAO DE FRETE COM ERRO"
	cRet += "<br>"
	cRet += "<br>"
	cRet += cmensagem
	cRet += "<br>"
	cRet += "<br><br>ATT, <br> TI <br><br> E-mail gerado por processo automatizado."
	cRet += "<br>"
	cRet += '</span>'
	cRet += '</body>'
	cRet += '</html>'
      
Return(cRet)  	                             



//INICIO Chamado 049508 - Abel Babini - 18/06/2019 - Validação do Pedido de Compra antes do Lançamento do CT-e
Static Function ValidPC( cPedido, cItemPC, cCodFor, cLojFor )
	Local lRetorno	:= .T.
	Local nValNF	:= 0
	Local nValPC	:= 0
	Local nDifPCNF	:= 0
	Local lPCxNF	:= .T.
	Local nVlTol	:= GETMV("MV_#TOLCTE",,0)
	Local aPrdPed	:= {} //Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
	Local aPrdCte	:= {} //Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
	Local lPrdDif	:= .F. //Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
	
	If !Empty( cPedido ) .And. !Empty( cItemPC )
		DbSelectarea("SC7")
		SC7->( DbSetorder( 1 ) )
		If !SC7->( DbSeek( xFilial("SC7") + cPedido + cItemPC ) ) .OR. ;
					! (Alltrim(SC7->C7_FORNECE) == Alltrim(cCodFor)) .OR. ;
					! (Alltrim(SC7->C7_LOJA) == Alltrim(cLojFor)) .OR.;
					! (Alltrim(SC7->C7_CONAPRO) == 'L')
			lRetorno := .F.
			uMsgErr("Pedido não localizado ou inválido!")
		Else	
				
			nRecOri := SC7->(RecNo())
			lPCxNF	:= .T.
			//nCont := 1 //Ch.050177 - Abel Babini - Ajuste na validação - 01/07/2019
			While ! SC7->(eof()) .AND. ;
					SC7->C7_FILIAL = xFilial("SC7") .AND. ;
					SC7->C7_NUM == cPedido .AND. ;
					Alltrim(SC7->C7_FORNECE) == Alltrim(cCodFor) .AND. ;
					Alltrim(SC7->C7_LOJA) == Alltrim(cLojFor) 
				
					nValPC += SC7->C7_TOTAL
				
				IF !(ASCAN(aPrdPed,SC7->C7_PRODUTO) > 0) //051082 || OS 052395 || FISCAL || ELIZABETE || 8424 || CTE X PED. COMP  ||ABEL BABINI || 13/08/2019
					AADD(aPrdPed,SC7->C7_PRODUTO)//INICIO Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
				ENDIF
				//nCont += 1 //Ch.050177 - Abel Babini - Ajuste na validação - 01/07/2019
				SC7->(dbSkip())
			Enddo
			SC7->(dbGoTo(nRecOri))

			//INICIO Ch.050177 - Abel Babini - Ajuste na validação - 01/07/2019
			For i:= 1 to Len(aCols)
				nValNF += aCols[i][nPosTot]
				IF !(ASCAN(aPrdCte,aCols[i][nPosProd]) > 0) //051082 || OS 052395 || FISCAL || ELIZABETE || 8424 || CTE X PED. COMP  ||ABEL BABINI || 13/08/2019
					AADD(aPrdCte,aCols[i][nPosProd])//INICIO Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
				ENDIF
			Next i
			IF !nValNF == nValPC
				lPCxNF := .F.
				nDifPCNF := nValNF - SC7->C7_TOTAL
			ENDIF
			//FIM Ch.050177 - Abel Babini - Ajuste na validação - 01/07/2019
			
			//INICIO Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
			ASORT(aPrdCte)
			ASORT(aPrdPed)
			lPrdDif := .F.
			If ! (Len(aPrdCte) == Len(aPrdPed)) //Ch. 052387 - Abel Babini - Valida CTE x Pedido (Noemi) - 08/10/2019
				lPrdDif := .T.
			Else
				For i:= 1 to Len(aPrdCte)
					If ! (Alltrim(aPrdCte[i]) == Alltrim(aPrdPed[i]))
						lPrdDif := .T.
						Exit
					Endif
				Next i
			Endif
			//FIM Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
			
			IF !lPCxNF .AND. ABS(nDifPCNF) > nVlTol //!(SC7->C7_TOTAL = nValNF)
				uMsgErr("Valor do Pedido ("+Alltrim(Str(nValPC))+") diverge do valor do CTE ("+Alltrim(Str(nValNF))+"). Não é possível continuar.")			
				lRetorno := .F.
			ELSEIF lPrdDif //INICIO Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
				uMsgErr("Os produtos do pedido divergem dos produtos da NF Original. Não é possível continuar.")			
				lRetorno := .F.
			ENDIF //FIM Ch. 050434 - Abel Babini - Valida CTE x Produto (Noemi) - 30/07/2019
		EndIf
	Else
		lRetorno := .F.
		uMsgErr("Pedido não informado!")
	EndIf
Return lRetorno


//Valida o Pedido de Compras digitado 
Static Function uMsgErr( cTxtErr )
	Local oDlgErr	:= Nil
	Local oBtnCan	:= Nil

	DEFINE MSDIALOG oDlgErr TITLE "Erro na seleção!" FROM 000, 000  TO 165, 310 COLORS 0, 16777215 PIXEL style 128
	oDlgErr:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.
	
	DEFINE SBUTTON oBtnCan 	FROM 068, 079 TYPE 02 OF oDlgErr ENABLE Action( oDlgErr:End() )
	
	@ 005, 010 SAY OemToAnsi(cTxtErr) SIZE 150, 025 OF oDlgErr COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlgErr CENTERED

Return
