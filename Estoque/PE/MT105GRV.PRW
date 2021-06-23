#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function MT105GRV
	LOCALIZAÇÃO : Function Ma105Grava() - Responsável pela atualização das Solicitações ao Almoxarifado.
	EM QUE PONTO : Este Ponto de Entrada e chamado apos a inclusao ou alteracao de dados no arquivo SCP.        
	Utilizacao: Grava os Campos:CP_XTIPO,CP_XLOCDES,CP_XPRODES
	@type  Function
	@author William Costa
	@since 08/08/2016
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history chamado 046621 - William      - 22/01/2018 - Incluído empresa 02 para informar o campo CP_XHORA
	@history chamado 051044 - Adriana      - 27/08/2019 - SAFEGG
	@history chamado 055188 - FWNM         - 17/02/2020 - OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA
	@history chamado T.I    - TIAGO STOCCO - 25/05/2020 - SOMENTE VALIDAR A INCLUSAO MANUAL DA SA, GERANDO ERRO QUANDO A SA VEM AUTOMATICA DO MNT DE ATIVOS
/*/

User Function MT105GRV()

	Local nOpcap   := PARAMIXB  
	Local nLocal   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_LOCAL" })  
	Local nItem    := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_ITEM" }) 
	Local nProduto := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_PRODUTO" })
	Local nXLocDes := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XLOCDES" })
	Local nXProDes := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XPRODES" })
	Local nXTipo   := aScan(aHeader, {|x| ALLTRIM(x[2]) == "CP_XTIPO" }) 
	Local aArea	   := GetArea()
	Local nCont    := 0
	
	IF Alltrim(FunName())== "MATA105" // CHAMADO T.I - ALTERADO POR TIAGO STOCCO PARA SOMENTE VALIDAR NA INCLUSAO MANUAL DA SA - 25/05/2020


		//Everson - 19/10/2017.Chamado 037698.
		If cEmpAnt == "01" .OR. ;
		cEmpAnt == "02" .OR. ; 	//William - 22/01/2018.Chamado 046621.
		cEmpAnt == "09"			//Alterado por Adriana chamado 051044 em 27/08/2019 SAFEGG
		
			RecLock("SCP")
				Replace SCP->CP_XHORA With cValToChar(Time())
			MsUnlock()
		
		EndIf
					
		IF ALLTRIM(ACOLS[n,nXTipo]) == 'N' // Normal
			
			FOR nCont:=1 TO LEN(acols)
			
				IF ACOLS[nCont,nItem] == SCP->CP_ITEM
				
					RecLock("SCP",.F.)
					
						SCP->CP_XTIPO   := 'N'
						SCP->CP_XPRODES := ACOLS[nCont,nXProDes]
						SCP->CP_XLOCDES := ACOLS[nCont,nXLocDes]
						
					SCP->( MsUnLock() )
				
				ENDIF 
			NEXT
			
		ElseIf ALLTRIM(ACOLS[n,nXTipo]) == 'T' // Chamado n. 055188 || OS 056599 || CONTROLADORIA || DANIELLE_MEIRA || 8459 || NOVA OPERACAO VENDA - FWNM - 18/02/2020
		
			IF __cUserID $ GETMV("MV_#USUTRA") // Garantir que so usuario no parametro pode gravar transferencia
			
				FOR nCont:=1 TO LEN(acols)
				
					IF ACOLS[nCont,nItem] == SCP->CP_ITEM
					
						RecLock("SCP",.F.)  	                  
						
							SCP->CP_XTIPO   := 'T' 
							SCP->CP_XPRODES := ACOLS[nCont,nXProDes]
							SCP->CP_XLOCDES := ACOLS[nCont,nXLocDes]
							
						SCP->( MsUnLock() )
					
					ENDIF
				NEXT	
			
			ENDIF
		
		ENDIF
	ENDIF
	RestArea(aArea)
	
Return(NIL) 