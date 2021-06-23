#Include "Protheus.ch"

/*/{Protheus.doc} User Function MT120ALT
    Ponto para validar se continua ou nao a Rotina
    @type  Function
    @author Everson
    @since 04/10/2016
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @history ticket 14352   - Fernando Macieira - 25/05/2021 - Saldo Negativo
/*/
User Function MT120ALT()

	Local aArea	      := GetArea()
	Local lRet		  := .T.
	Local ExpN1       := Paramixb[1]
	Local cNumPC	  := ""   
	Local cBotaoApert := IIF(ExpN1 == 2,'VISUALIZAR', IIF(ExpN1 == 3,'INCLUIR', IIF(ExpN1 == 4,'ALTERAR', IIF(ExpN1 == 5,'EXCLUIR', ''))))

	// @history ticket 14352   - Fernando Macieira - 25/05/2021 - Saldo Negativo
	Local lUsrAut    := GetMV("MV_#USRLIG",,.f.) // Ativa controle de usuarios autorizados
    Local cUsrAut    := GetMV("MV_#USRPCF",,"000000") // Usuarios autorizados
    //

	// TI - fwnm - 22/01/2019 - permitir visualizacao pela rotina de posicao de projetos
	If AllTrim(FunName()) == "ADPMS005P" 
		Return lRet
	EndIf
	
	//Verifica se a operação é de alteração ou exclusão.
	IF ALTERA .Or. ExpN1 == 5
	
		cNumPC := SC7->C7_NUM
	    
		// verifica se o usuario que esta fazendo alteracao e o mesmo do pedido
		If Alltrim(SC7->C7_USER) != Alltrim(__CUSERID) .AND.;
		   FUNNAME()             <> 'FINC030'  // 042801 || FINANCAS || CAROLINA || 8353 || POSICAO FORNECEDOR ||WILLIAM COSTA ||27/07/2018
		
			MsgStop("Esta operação só é permitida para o usuário que incluiu o pedido de compra.","Função MT120ALT")
			
			dbSelectArea("ZBE")
			RecLock("ZBE",.T.)
				Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
				Replace ZBE_DATA 	   	WITH dDataBase
				Replace ZBE_HORA 	   	WITH TIME()
				Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
				Replace ZBE_LOG	        WITH ("MT120ALT-1 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " SC7->C7_USER : " + SC7->C7_USER +  " __CUSERID: " + Alltrim(__CUSERID) + " cBotaoApert "  + cBotaoApert)  
				Replace ZBE_MODULO	    WITH "COMPRAS"
				Replace ZBE_ROTINA	    WITH "MT120ALT" 
			MsUnlock()  
			
			lRet := .F.  
	 
		Endif	

	ENDIF
	
	IF FUNNAME() <> 'FINC030'  // 042801 || FINANCAS || CAROLINA || 8353 || POSICAO FORNECEDOR ||WILLIAM COSTA ||27/07/2018
	
		dbSelectArea("ZBE")
		RecLock("ZBE",.T.)
			Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
			Replace ZBE_DATA 	   	WITH dDataBase
			Replace ZBE_HORA 	   	WITH TIME()
			Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
			Replace ZBE_LOG	        WITH ("MT120ALT-2 " + " Filal : " + SC7->C7_FILIAL  + " Pedido de Compra : " + SC7->C7_NUM + " Campo C7_CONAPRO : "  + SC7->C7_CONAPRO + " SC7->C7_USER : " + SC7->C7_USER +  " __CUSERID: " + Alltrim(__CUSERID) + " cBotaoApert "  + cBotaoApert)  
			Replace ZBE_MODULO	    WITH "COMPRAS"
			Replace ZBE_ROTINA	    WITH "MT120ALT" 
		MsUnlock()
	  
	ENDIF
	
    // @ticket 14352   - Fernando Macieira - 24/05/2021 - Saldo Negativo
    // Consisto usuarios autorizados que podem alterar Fornecedor 
    If lUsrAut
        If !( cUsrAut $ RetCodUsr() )
            IF ALTERA .Or. ExpN1 == 5
                SD1->( dbSetOrder(22) ) // D1_FILIAL, D1_PEDIDO, D1_ITEMPC, R_E_C_N_O_, D_E_L_E_T_
                If SD1->( dbSeek(FWxFilial("SD1")+cNumPC) )
                    lRet := .f.
                    MessageBox("Alteração não permitida!" + Chr(13)+Chr(10) + "PC está amarrado a NF n. " + SD1->D1_DOC + "/" + SD1->D1_SERIE,"MT120ALT-01 (PC com movimentações)",48)
                EndIf
            EndIf
        EndIf
    EndIf
    //
    
    RestArea(aArea)

Return (lRet)
