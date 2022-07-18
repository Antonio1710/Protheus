#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*{Protheus.doc} User Function MA020TDOK
	Ponto de Entrada no Tudo Ok do Fornecedor
	@type  Function
	@author Ricardo Lima
	@since 15/12/2017
	@version 01
	@history Chamado 046541 - Ricardo Lima     - 17/07/2019 - habilita filial para o pre-cadastro por parametro
	@history Chamado 049218 - FWNM             - 27/08/2019 - Novo status p/ recusa (A2_XPRECAD = 3)  
	@history Chamado 052327 - Adriana Oliveira - 07/10/2019 - Habilita Pre-cadastro Fornecedor p/ SAFEGG
	@history Chamado 052327 - Adriana Oliveira - 16/10/2019 - Ajuste emails Pre-Cadastro p/ SAFEGG
	@history Chamado 052636 - William Costa    - 25/11/2019 - Adicionado a empresa 07 para carregar corretamente o pré cadastro
	@history Chamado 18071  - Antonio Domingos - 05/07/2022 - Melhoria no cadastro de fornecedor.
*/

User Function MA020TDOK

	Local lRet	:=	.T.     
	Local cAssunto  := "CADASTRO DE FORNECEDOR ATIVADO - "+Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
	Local cMensagem := ""
	Local cEmail    := ""
	Local lAtuFis   := .F.
	Local cDsWfFis  := SuperGetMv( "MV_#EMLWF1" , .F. , '' ,  )+';'+SuperGetMv( "MV_#EMLWF2" , .F. , '' ,  )
	Local sAltFis   := "" 
	Local aHeader   :={}
	Local _aHeader2 := {}
	LOcal _aHeader3 := {}
	Local _lAchouSA2:= .F.
	Local lAtvCad   := .F.
	Local aArea 	:= GetArea()
	//Local sTabJson  := '{ '
	//Local sMemJson  := '{ '
	//Local lZclAapr := .F.
	Local lFilPreC := SuperGetMv( "MV_#PRECAD" , .F. , .F. ,  )
	Local h
	
	If Alltrim(cEmpAnt) $ "01/07/09" // Por Adriana Oliveira em 07/10/2019 - Chamado 052327 // William Costa 25/11/2019 chamado 052636  
		If Empty(M->A2_LOCAL) .and. M->A2_XTIPO $ "1|2"
			MsgInfo("Informar o Local do Integrado/Incubatorio","Atencao")
			lRet	:=	.F.						       
		EndIf                      
	Endif
	If lFilPreC // Ricardo Lima-17/07/2019-046541|habilita filial para o pre-cadastro por parametro
		IF ALLTRIM(PswRet()[1][12])$'FISCAL|TI'
	        // Sim - Sim
	        IF M->A2_XPR = '1' .and. M->A2_XDI = '1'
	            IF EMPTY(M->A2_LOCAL)
	                ApMsgInfo("Campo Almoxarifado não pode ser vazio.")
	                lRet := .F.
	            EndIf
				If M->A2_EST = 'SP'
	            IF EMPTY(M->A2_CODMUN)
	                ApMsgInfo("Campo Cod. Mun. GIA não pode ser vazio.")
	                lRet := .F.
					EndIf
	            EndIf
	            IF EMPTY(M->A2_TIPORUR)
	                ApMsgInfo("Campo Tp. Contr. Soc não pode ser vazio.")
	                lRet := .F.
	            EndIf
	        EndIf
	        // Sim - Não
	        IF M->A2_XPR = '1' .and. M->A2_XDI = '2'
	            IF EMPTY(M->A2_LOCAL)
	                ApMsgInfo("Campo Almoxarifado não pode ser vazio.")
	                lRet := .F.
	            EndIf
				If M->A2_EST = 'SP'
					IF EMPTY(M->A2_CODMUN)
						ApMsgInfo("Campo Cod. Mun. GIA não pode ser vazio.")
						lRet := .F.
					EndIf
				EndIf
	        EndIf
	    EndIf                     
		IF ALLTRIM(PswRet()[1][12])$'FINANCAS'
			IF EMPTY(M->A2_PAIS)
	            ApMsgInfo("Campo País não pode ser vazio.")
	            lRet := .F.
	        EndIf
		EndIf
	Endif
	
	If M->A2_XTIPO = "2"
		if Empty(M->A2_EMAIL)
			ApMsgInfo("O e-mail é Obrigatorio para Cadastro de Integrado","Atencao")
			lRet := .F.
		Elseif !IsEmail(M->A2_EMAIL)
			ApMsgInfo("Informe um e-mail Valido para Cadastro de Integrado","Atencao")
			lRet := .F.
		Endif
	EndIf
	
	IF !lRet
		Return( lRet )
	EndIf
	
	if lFilPreC // Ricardo Lima-17/07/2019-046541|habilita filial para o pre-cadastro por parametro
		//@history Chamado 18071  - Antonio Domingos - 05/07/2022 - Melhoria no cadastro de fornecedor
		//Otimizado para fazer a busca no SX3 apenas 1 vez.
		_aHeader2 := {}
		_aHeader3 := {}
		dbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SA2")
		While !Eof().And.(x3_arquivo=="SA2")
			If X3USO(x3_usado).And.x3_folder='2'.And.x3_context<>'V'
				Aadd(_aHeader2,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
			elseif X3USO(x3_usado).And.x3_folder='3'.And.x3_context<>'V'
				Aadd(_aHeader3,{ TRIM(x3_titulo), x3_campo, x3_picture, x3_tamanho, x3_decimal, "AllwaysTrue()", x3_usado, x3_tipo, x3_arquivo, x3_context } )
			Endif    
			dbSkip()
		End
	 If M->A2_MSBLQL = '1'
		If M->A2_MSBLQL = "1" .AND. SA2->A2_MSBLQL = "1"
			If ALLTRIM(PswRet()[1][12])$'FINANCAS|TI|GERFIS'
				sAltFis := ""
				lAtuFis   := .F.
				for h:=1 to LEN(_aHeader2) //x3_folder='2'
					IF &("M->"+_aHeader2[h][2]) <> &("SA2->"+_aHeader2[h][2])
						sAltFis += "Alterado Campo( "+_aHeader2[h][1]+" ) de: "+Alltrim(&("SA2->"+_aHeader2[h][2]))+" para: "+Alltrim(&("M->"+_aHeader2[h][2]))+chr(13)+chr(10)
						lAtuFis := .T.
					EndIf
	            next	
				If M->A2_XPRECAD = '1'
					RecLock("SA2",.F.)
						SA2->A2_XPRECAD := '2'
						lAtvCad := .T.
					MSUNLOCK()
				EndIf
				RecLock("CV8",.T.)
					CV8->CV8_FILIAL  := xFilial("CV8")
					CV8->CV8_MSG     := "CADASTRO DE FORNECEDOR ALTERADO"
					CV8->CV8_PROC    := alltrim(FUNNAME()) + M->A2_COD
					CV8->CV8_DET     := "CADASTRO DE FORNECEDOR ALTERADO PELO FINANCEIRO, "+chr(13)+chr(10)+ iif(lAtvCad , "Alterado Campo Pre-Cadastro para Não."+chr(13)+chr(10) ,"" ) +"Item(ns) Alterado(s): "+chr(13)+chr(10)+sAltFis
					CV8->CV8_USER    := SubStr(cUsuario,7,15)
					CV8->CV8_DATA    := DATE()
					CV8->CV8_HORA    := TIME()
					CV8->CV8_INFO    := '1'
				MSUNLOCK()
				cMensagem := U_MntMsc( M->A2_COD , M->A2_LOJA , M->A2_NOME , M->A2_CGC , M->A2_INSCR , M->A2_END , M->A2_BAIRRO , M->A2_MUN , M->A2_USERINC , M->A2_DTINC , "P" , "" )	
				u_F050EnvWF( "CADASTRO DE FORNECEDOR ALTERADO PELO FINANCEIRO - "+Alltrim(FWGrpName(cempant)) , cMensagem , cDsWfFis , '' )			
			EndIf
		Endif
	 Endif
	
	 if M->A2_MSBLQL <> '1'
		//Se Estou posicionando no mesmo registro, não é preciso pesquisar o fornecedor.
		//@history Chamado 18071  - Antonio Domingos - 05/07/2022 - Melhoria no cadastro de fornecedor
		If M->(A2_FILIAL + A2_COD + A2_LOJA) == SA2->(A2_FILIAL + A2_COD + A2_LOJA)
			_lAchouSA2:=.T.			
		else
			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + M->A2_COD + M->A2_LOJA )
			_lAchouSA2:=!SA2->(Eof())
		EndIf
		If _lAchouSA2
			if M->A2_MSBLQL = "2" .AND. SA2->A2_MSBLQL = "1"  // WORKFLOW DE DESBLOQUEIO DE FORNECEDOR
				RecLock("CV8",.T.)
					CV8->CV8_FILIAL  := xFilial("CV8")
					CV8->CV8_MSG     := "CADASTRO DE FORNECEDOR ATIVADO"
					CV8->CV8_PROC    := alltrim(FUNNAME()) + M->A2_COD
					CV8->CV8_DET     := "CADASTRO DE FORNECEDOR ATIVADO"
					CV8->CV8_USER    := SubStr(cUsuario,7,15)
					CV8->CV8_DATA    := DATE()
					CV8->CV8_HORA    := TIME()
					CV8->CV8_INFO    := '1'
				MSUNLOCK()
				
				// ENVIA WORKFLOW
				cMensagem := U_MntMsc( M->A2_COD , M->A2_LOJA , M->A2_NOME , M->A2_CGC , M->A2_INSCR , M->A2_END , M->A2_BAIRRO , M->A2_MUN , M->A2_USERINC , M->A2_DTINC , "A" , "" )
				
				PswOrder(2) // Ordem de nome
				If PswSeek( ALLTRIM(M->A2_USERINC) , .T. )
					aRetUser := PswRet(1)
					cEmail   := upper(alltrim(aRetUser[1,14]))
				ENDIF	 
				
				u_F050EnvWF( cAssunto , cMensagem , cEmail+';'+cDsWfFis , '' )
			ENDIF
			if ( cEmpAnt $ "01/02/07/09") .and. ALLTRIM(PswRet()[1][12])$'FISCAL|TI|GERFIS' // Por Adriana Oliveira em 07/10/2019 - Chamado 052327 // William Costa 25/11/2019 chamado 052636 
				// WORKFLOW DE ATUALIZAÇÃO FISCAL DE FORNECEDOR
				sAltFis := ""
				aHeader   :={}
				lAtuFis   := .F.
				for h:=1 to LEN(_aHeader3)
					IF &("M->"+_aHeader3[h][2]) <> &("SA2->"+_aHeader3[h][2])
						sAltFis += "Alterado Campo( "+_aHeader3[h][1]+" ) de: "+Alltrim(&("SA2->"+_aHeader3[h][2]))+" para: "+Alltrim(&("M->"+_aHeader3[h][2]))+chr(13)+chr(10)
						lAtuFis := .T.
					EndIf
	            next	
				if lAtuFis
					RecLock("CV8",.T.)
						CV8->CV8_FILIAL  := xFilial("CV8")
						CV8->CV8_MSG     := "ALTERAÇÃO FISCAL DE CADASTRO DE FORNECEDOR ATIVO"
						CV8->CV8_PROC    := alltrim(FUNNAME()) + M->A2_COD
						CV8->CV8_DET     := "ALTERAÇÃO FISCAL DE CADASTRO DE FORNECEDOR ATIVO,"+chr(13)+chr(10)+"Alterações realizadas: "+chr(13)+chr(10)+sAltFis
						CV8->CV8_USER    := SubStr(cUsuario,7,15)
						CV8->CV8_DATA    := DATE()
						CV8->CV8_HORA    := TIME()
						CV8->CV8_INFO    := '1'
					MSUNLOCK()
					cMensagem := U_MntMsc( M->A2_COD , M->A2_LOJA , M->A2_NOME , M->A2_CGC , M->A2_INSCR , M->A2_END , M->A2_BAIRRO , M->A2_MUN , M->A2_USERINC , M->A2_DTINC , "F" , "" )	
					cAssunto := "ALTERAÇÃO FISCAL DE CADASTRO DE FORNECEDOR ATIVO - "+Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
					u_F050EnvWF( cAssunto , cMensagem , cDsWfFis , '' )
				Endif	
			Endif
			if (Alltrim(cEmpAnt) $ "01/02/07/09") .and. Alltrim(PswRet()[1][12])$'FINANCAS|TI|GERFIS' // Por Adriana Oliveira em 07/10/2019 - Chamado 052327 // William Costa 25/11/2019 chamado 052636 
				// WORKFLOW DE ALTERAÇÃO FISCAL DE FORNECEDOR
				sAltFis := ""
				aHeader   :={}
				lAtuFis   := .F.
				for h:=1 to LEN(_aHeader2) //x3_folder = '2'
					IF &("M->"+_aHeader2[h][2]) <> &("SA2->"+_aHeader2[h][2])
						sAltFis += "Alterado Campo( "+_aHeader2[h][1]+" ) de: "+Alltrim(&("SA2->"+_aHeader2[h][2]))+" para: "+Alltrim(&("M->"+_aHeader2[h][2]))+chr(13)+chr(10)
						lAtuFis := .T.
					EndIf
	            next	
	
				if lAtuFis
					RecLock("CV8",.T.)
						CV8->CV8_FILIAL  := xFilial("CV8")
						CV8->CV8_MSG     := "ALTERAÇÃO FINANCEIRA DE CADASTRO DE FORNECEDOR ATIVO"
						CV8->CV8_PROC    := alltrim(FUNNAME()) + M->A2_COD
						CV8->CV8_DET     := "ALTERAÇÃO FINANCEIRA DE CADASTRO DE FORNECEDOR ATIVO,"+chr(13)+chr(10)+"Alterações realizadas: "+chr(13)+chr(10)+sAltFis
						CV8->CV8_USER    := SubStr(cUsuario,7,15)
						CV8->CV8_DATA    := DATE()
						CV8->CV8_HORA    := TIME()
						CV8->CV8_INFO    := '1'
					MSUNLOCK()
					cMensagem := U_MntMsc( M->A2_COD , M->A2_LOJA , M->A2_NOME , M->A2_CGC , M->A2_INSCR , M->A2_END , M->A2_BAIRRO , M->A2_MUN , M->A2_USERINC , M->A2_DTINC , "F" , "" )	
					cAssunto:= "ALTERAÇÃO FINANCEIRA DE CADASTRO DE FORNECEDOR ATIVO - "+Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
					u_F050EnvWF( cAssunto , cMensagem , cDsWfFis , '' )
				Endif	
			Endif
			// Ricardo Lima - 18/07/18
			If M->A2_XPRECAD = '1'
				RecLock("SA2",.F.)
					SA2->A2_XPRECAD := '2'
					lAtvCad := .T.
				MSUNLOCK()
			EndIf
		EndIf
	 ENDIF
	endif
	//@history Chamado 18071  - Antonio Domingos - 05/07/2022 - Melhoria no cadastro de fornecedor
	//Incluido RestArea 
	RestArea(aArea)

Return lRet
