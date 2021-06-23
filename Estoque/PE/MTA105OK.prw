#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

/*/{Protheus.doc} User Function MTA105OK
	Ao confirmar a solicitação ao almoxarifado. Pode ser utilizado para confirmar ou nao a gravacao da 
	Solicitacao ao Almoxarifado. LOCALIZAÇÃO: Ponto de entrada localizado na função 
	Utilizacao: Confirma se a CP_XTIPO esta igual a T ou N
	@type  Function
	@author William Costa
	@since 18/12/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 051044 - Adriana      - 27/08/2019 - SAFEGG
	@history chamado 055188 - FWNM         - 17/02/2020 - OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
/*/
USER FUNCTION MTA105OK()

	Local lRet     := .T.
	Local nLocal   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_LOCAL" })  
	Local nItem    := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_ITEM" }) 
	Local nProduto := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_PRODUTO" })
	Local nGrupo   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_GRUPO" })
	Local nCc      := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_CC" })
	Local nXLocDes := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XLOCDES" })
	Local nXProDes := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XPRODES" })
	Local nXTipo   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XTIPO" })
	Local nCont    := 0 
	Local aArea	   := GetArea()
	Local lNormal  := .F.
	Local lTransf  := .F.

	// Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 17/02/2020
	Local lManut    := AllTrim(gdFieldGet("CP_XTIPO",n))=="M" 
	Local cCCusto   := GetMV("MV_#MANUCC",,"5304")
	Local cLocMan   := GetMV("MV_#MANLO2",,"02")
	Local cUsrManut := GetMV("MV_#MANUSU",,"001428") 
	//

	IF CEMPANT == '01' ; // Regra somente para a Adoro - WILLIAM COSTA
		.OR. CEMPANT == "09" //Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG
	
		FOR nCont:=1 TO LEN(acols)
		
			u_GrLogZBE (Date(),TIME(),cUserName,"1 INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
					"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
					ComputerName(),LogUserName())
			
			IF aCols[nCont,Len(aHeader)+1] == .F. //conto apenas as linhas nao removidas

				// Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 17/02/2020
				If lManut 

					// consisto logins permitidos
					If !(__cUserID $ cUsrManut)
						lRet := .f.
						MsgStop("Solicitação de Armazém de Transferência de Manutenção não está autorizado, parâmetro MV_#MANUSU", "[MTA105OK-06] - Transferência de Manutenção - Login")
						Exit
					EndIf

					// consisto almoxarifado origem
					If lRet
						If !(AllTrim(gdFieldGet("CP_LOCAL",n)) $ cLocMan)
							lRet := .f.
							MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa estar contido no almoxarifado " + cLocMan, "[MTA105OK-04] - Transferência de Manutenção - Almoxarifado origem")
							Exit
						EndIf
					EndIf

					// consisto CCusto permitido
					If lRet
						If !(AllTrim(gdFieldGet("CP_CC",n)) $ cCCusto)
							lRet := .f.
							MsgStop("Solicitação de Armazém de Transferência de Manutenção precisa estar contido no CCusto " + cCCusto, "[MTA105OK-05] - Transferência de Manutenção - Centro Custo")
							Exit
						EndIf
					EndIf

					/*
					If lRet
						u_GrLogZBE (Date(),TIME(),cUserName,"7 INC SA DE TRANSF MANUTENCAO","ESTOQUE","MTA105OK",;
						"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
						ComputerName(),LogUserName())
		    	   
						ACOLS[nCont,nXTipo]   := 'M'
						ACOLS[nCont,nXProDes] := ACOLS[nCont,nProduto]
						ACOLS[nCont,nXLocDes] := '48'
					EndIf
					*/

				//
				Else

					IF ALLTRIM(ACOLS[nCont,nGrupo]) $ GETMV("MV_#GPTRAN") .AND. ;
					ALLTRIM(ACOLS[nCont,nCc])    $ GETMV("MV_#CCTRAN") .AND. ;
					__cUserId                    $ GETMV("MV_#USUTRA")
					
						u_GrLogZBE (Date(),TIME(),cUserName,"2 IF INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
							"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
							ComputerName(),LogUserName())
					
						//Variavel de Controla para saber se a Solicitação e de Transferencia
						IF lTransf  == .F.
							lTransf  := .T.
						ENDIF
					
					ELSE 
					
						//Variavel de Controla para saber se a Solicitação e Normal
						IF lNormal  == .F.
							lNormal  := .T.
						ENDIF
						
					ENDIF

				EndIf 
	
		    ELSE
		    	
		    	u_GrLogZBE (Date(),TIME(),cUserName,"3 ELSE INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
					"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
					ComputerName(),LogUserName())
		    	   
	    	ENDIF
	
		NEXT
		
		If !lManut // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 17/02/2020
		
			IF lTransf == .T. .AND. lNormal  == .T.
			
				MsgStop("OLÁ " + Alltrim(cUserName) + ", Solicitação de Armazém de Transferência não pode ter produtos que não pertencem ao grupo de produtos " + GETMV("MV_#GPTRAN") + ", por favor, fazer uma nova solicitação Tipo Normal para esses produtos.", "MTA105OK-1 - Solicitação de Armazém")
				lRet:= .F.
				
			ELSEIF lTransf == .F. .AND. lNormal  == .F.	
			
				MsgStop("OLÁ " + Alltrim(cUserName) + ", Solicitação de Armazém sem produtos, favor verificar", "MTA105OK-2 - Solicitação de Armazém")
				lRet:= .F.
				
			ELSEIF lTransf == .F. .AND. lNormal  == .T.	
			
				u_GrLogZBE (Date(),TIME(),cUserName,"4 ELSEIF INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
						"Numero: "+cA105Num+"Transf: "+cValtochar(lTransf)+" lNormal: " +cValtochar(lNormal),;
						ComputerName(),LogUserName())
			
				FOR nCont:=1 TO LEN(acols)
				
					ACOLS[nCont,nXTipo]   := 'N'
					ACOLS[nCont,nXProDes] := ''
					ACOLS[nCont,nXLocDes] := ''
					
				NEXT
				
			ELSE //lTransf == .T. .AND. lNormal == .F.
			
				FOR nCont:=1 TO LEN(acols)
				
					u_GrLogZBE (Date(),TIME(),cUserName,"5 INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
						"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
						ComputerName(),LogUserName())
				
					IF aCols[nCont,Len(aHeader)+1] == .F. //conto apenas as linhas nao removidas
					
						u_GrLogZBE (Date(),TIME(),cUserName,"6 INCLUSAO DE SOLICITACAO DE ARMAZEM ","ESTOQUE","MTA105OK",;
						"Numero: "+cA105Num+" Grupo: " +ALLTRIM(ACOLS[nCont,nGrupo])+ " Cc: " +ALLTRIM(ACOLS[nCont,nCc])+ " User: " +__cUserId+ " Acols Linha Removida: " +cvaltochar(aCols[nCont,Len(aHeader)+1]),;
						ComputerName(),LogUserName())
				
						IF ALLTRIM(ACOLS[nCont,nGrupo]) $ GETMV("MV_#GPTRAN") .AND. ;
						ALLTRIM(ACOLS[nCont,nCc])    $ GETMV("MV_#CCTRAN") .AND. ;
						__cUserId                    $ GETMV("MV_#USUTRA") 
						
						MsgInfo("OLÁ " + Alltrim(cUserName) + ", Solicitação de Armazém alterada para Transferência.", "MTA105OK-3 - Solicitação de Armazém")
						
						ACOLS[nCont,nXTipo]   := 'T'
						ACOLS[nCont,nXProDes] := ACOLS[nCont,nProduto]
						ACOLS[nCont,nXLocDes] := '03    '
						
						ENDIF
		
					ENDIF 
		
				NEXT
		
			ENDIF

		EndIf
	
	ENDIF

	RestArea(aArea)

RETURN(lRet)