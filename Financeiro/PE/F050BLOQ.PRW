#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} User Function F050BLOQ
    Programa que bloqueia ou desbloqueia o titulo do contas a pagar e tambem bloqueia a nota de entrada atrelada ao titulo for do tipo NF
    @type  Function
    @author William Costa
    @since 30/03/2015
    @version version
    @history chamado 042937 - Ricardo Lima  - 03/08/2018 - Envio para central de aprovação o bloqueio manual de contas a pagar
	@history Chamado 058216 - FWNM          - 15/05/2020 - OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR
	@history Chamado 058197 - WILLIAM COSTA - 27/05/2020 - Adicionado nova tabela na ZC7 para envio de titulos bloqueados
	@history Chamado 058691 - WILLIAM COSTA - 03/06/2020 - Identificado que titulos para bloqueio e desbloqueio, precisa ser criados com o campo ZC7_NIVEL = '02' para ir para os aprovadores corretos, os niveis interferem nas visualizações de titulos para aprovação dentro da central
	
/*/
User Function F050BLOQ() 

	// 03/08/18 | Ricardo Lima
	Local cmaildest := ""
    Local cAssunto  := "Central de Aprovação"
    Local cMensagem := ""
	Local cTpDivf   := "000011"
	Local lZC7Exist := .T.

    // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 18/05/2020
	Local lUsrAut   := .F.
    Local cUsrAut   := GetMV("MV_#CARJOK",,"000000") 
    //

	PRIVATE cFil       := ''
	PRIVATE cSerie     := ''
	PRIVATE cDoc       := ''
	PRIVATE cFornece   := ''
	PRIVATE cLoja      := ''
	Private lEnvWFCA   := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )

	IF SE2->E2_Saldo = 0
	   ApMsgInfo(OEMTOANSI("Título já Baixado"), "OK")
	   RETURN
	ENDIF

	If RetCodUsr() $ cUsrAut
		lUsrAut := .T.
    Else
        msgAlert("Seu login não autorizado a utilizar este recurso!","Central Aprovação - F050BLOQU")
        Return
	EndIf

    // Chamado n. 058216 || OS 059676 || FINANCAS || LUIZ || 8451 || CONTAS APAGAR - FWNM - 18/05/2020
	RecLock("ZBE",.T.)
		Replace ZBE_FILIAL 	   	WITH FWxFilial("ZBE")
		Replace ZBE_DATA 	   	WITH msDate()
		Replace ZBE_HORA 	   	WITH Time()
		Replace ZBE_USUARI	    WITH RetCodUsr()
		Replace ZBE_LOG	        WITH "Central Aprovacao - Bloqueio/Desbloqueio - Titulo " + SE2->E2_NUM + " E2_RJ = " + SE2->E2_RJ + " E2_XDIVERG = " + SE2->E2_XDIVERG + " Logins autorizados = " + AllTrim(cUsrAut)
		Replace ZBE_MODULO	    WITH "FINANCEIRO"
		Replace ZBE_ROTINA	    WITH "F050BLOQU"
	ZBE->( msUnlock() )

    // 03/08/18 | Ricardo Lima
	If SE2->E2_RJ='X'
		
        MsgInfo("O Desbloqueio foi Desativado, Nesse Momento a Aprovação será Enviada para a Central de Aprovação.","Central de Aprovação - Desbloqueio")
		dbSelectArea("ZC7")
		dbSetOrder( 2 )  // ZC7_FILIAL+ZC7_CLIFOR+ZC7_LOJA+ZC7_PREFIX+ZC7_NUM+ZC7_PARCEL+ZC7_TIPO
		
        If dbSeek( FwxFilial("ZC7") + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO )
		
        	WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=FwxFilial("ZC7") .AND. ZC7->ZC7_CLIFOR=SE2->E2_FORNECE .AND. ZC7->ZC7_LOJA=SE2->E2_LOJA .AND. ZC7->ZC7_PREFIX=SE2->E2_PREFIXO .AND. ZC7->ZC7_NUM=SE2->E2_NUM .AND. ZC7->ZC7_PARCEL=SE2->E2_PARCELA .AND. ZC7->ZC7_TIPO=SE2->E2_TIPO
		
        		IF EMPTY(ZC7->ZC7_USRAPR)
					lZC7Exist := .F.
				EndIf	
		
        		DbSkip()
			END	

			if lZC7Exist
				
                // Ricardo Lima|03/08/18 - envia para Central de Aprovação
				DbSelectArea("SX5")
				DbSetOrder(1)
				DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
				// gera registro para aprovacao		
				RecLock("ZC7",.T.)
					ZC7->ZC7_FILIAL := FwxFilial("SE2")
					ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
					ZC7->ZC7_NUM   	:= SE2->E2_NUM
					ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
					ZC7->ZC7_TIPO   := SE2->E2_TIPO
					ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
					ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
					ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
					ZC7->ZC7_TPBLQ 	:= cTpDivf
					ZC7->ZC7_DSCBLQ	:= ALLTRIM(SX5->X5_DESCRI) + " - " + "BLOQUEADO DEPT.FINANCEIRO"
					ZC7->ZC7_RECPAG := "P"	 
					ZC7->ZC7_USRALT := __cUserID						 		
					ZC7->ZC7_NIVEL  := '02'
				MSUnlock()

				// Envio de Pendencia Para o Aprovador não Ausente
				c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
				c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
				c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
				c2Query += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
				c2Query += " ORDER BY ZCF_NIVEL "
		
        		If Select("TMPZC3") > 0
					TMPZC3->(DbCloseArea())
				EndIf
		
        		TcQuery c2Query New Alias "TMPZC3"
		
        		IF !EMPTY(TMPZC3->ZC3_CODUSU)
					cmaildest := AllTrim(UsrRetMail( TMPZC3->ZC3_CODUSU ))
				ENDIF
		
        		cMensagem := u_WGFA050FIN( FwxFilial("SE2") , SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_VALOR , Alltrim(SX5->X5_DESCRI) , 'F' )
		
        		IF !EMPTY(cmaildest)
		
        			If lEnvWFCA
		
        				U_F50En2WF( cmaildest , '' , cAssunto , cMensagem , '' )
		
        			EndIf
		
        		Endif
		
        	Endif	
		
        ELSE
			// Ricardo Lima|03/08/18 - envia para Central de Aprovação
			DbSelectArea("SX5")
			DbSetOrder(1)
			DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
			// gera registro para aprovacao		
			RecLock("ZC7",.T.)
				ZC7->ZC7_FILIAL := FwxFilial("SE2")
				ZC7->ZC7_PREFIX	:= SE2->E2_PREFIXO
				ZC7->ZC7_NUM   	:= SE2->E2_NUM
				ZC7->ZC7_PARCEL	:= SE2->E2_PARCELA
				ZC7->ZC7_TIPO   := SE2->E2_TIPO
				ZC7->ZC7_CLIFOR	:= SE2->E2_FORNECE
				ZC7->ZC7_LOJA  	:= SE2->E2_LOJA
				ZC7->ZC7_VLRBLQ	:= SE2->E2_VALOR
				ZC7->ZC7_TPBLQ 	:= cTpDivf
				ZC7->ZC7_DSCBLQ	:= ALLTRIM(SX5->X5_DESCRI) + " - " + "BLOQUEADO DEPT.FINANCEIRO"
				ZC7->ZC7_RECPAG := "P"	 
				ZC7->ZC7_USRALT := __cUserID						 		
				ZC7->ZC7_NIVEL  := '02'
			MSUnlock()
			// Envio de Pendencia Para o Aprovador não Ausente
			c2Query := " SELECT ZC3_CODUSU, ZC3_NOMUSU, ZCF_NIVEL, ZCF_CODIGO, ZC3_APRATV "
			c2Query += " FROM "+RetSqlName("ZC3")+" ZC3 "
			c2Query += " INNER JOIN "+RetSqlName("ZCF")+" ZCF ON ZC3_CODUSU=ZCF_APROVA AND ZCF.D_E_L_E_T_ = ' ' "
			c2Query += " WHERE ZCF_CODIGO = '"+cTpDivf+"' AND ZC3_APRATV <> '1' AND ZC3.D_E_L_E_T_ = ' ' "
			c2Query += " ORDER BY ZCF_NIVEL "
			If Select("TMPZC3") > 0
				TMPZC3->(DbCloseArea())
			EndIf
			TcQuery c2Query New Alias "TMPZC3"
			IF !EMPTY(TMPZC3->ZC3_CODUSU)
				cmaildest := AllTrim(UsrRetMail( TMPZC3->ZC3_CODUSU ))
			ENDIF
			cMensagem := u_WGFA050FIN( FwxFilial("SE2") , SE2->E2_PREFIXO , SE2->E2_NUM , SE2->E2_PARCELA , SE2->E2_FORNECE , SE2->E2_LOJA , SE2->E2_VALOR , Alltrim(SX5->X5_DESCRI) , 'F' )
			IF !EMPTY(cmaildest)
				If lEnvWFCA
					U_F50En2WF( cmaildest , '' , cAssunto , cMensagem , '' )
				EndIf
			Endif
		EndIf
	
    ELSE
	
    	IF !ApMsgYesNo('Deseja Bloquear o Titulo para Movimentações?')
	
    		RETURN
	
    	ELSE
	
    		RecLock("SE2",.F.)
				SE2->E2_RJ      := 'X'
				SE2->E2_HIST    := 'BLOQUEADO DEPT.FINANCEIRO'
				SE2->E2_DATALIB := CtoD('')
				SE2->E2_XDIVERG := 'S'
			MsUnlock()
			
			IF SE2->E2_TIPO = 'NF'
				cFil     := SE2->E2_FILIAL
				cSerie   := SE2->E2_PREFIXO
				cDoc     := SE2->E2_NUM
				cFornece := SE2->E2_FORNECE
				cLoja    := SE2->E2_LOJA
				SqlF050Bloq() 
			
				While TRB->(!EOF())
					DBSELECTAREA("SF1")
					DbSetOrder(1)
					IF DBSEEK(cFil+cDoc+cSerie+cFornece+cLoja,.T.)          
						RecLock("SF1",.F.)
							SF1->F1_XANTSTA = SF1->F1_STATUS
							SF1->F1_STATUS = 'B'
						MsUnlock()  	
					ENDIF    
					SF1->(dbCloseArea())		
					TRB->(dbSkip())
				ENDDO
				TRB->(dbCloseArea())
				cFil     := ''
				cSerie   := ''
				cDoc     := ''
				cFornece := ''
				cLoja    := ''
			ENDIF
		ENDIF
	Endif
		
RETURN(NIL)

STATIC FUNCTION SqlF050Bloq()  

	BeginSQL Alias "TRB"
		%NoPARSER% 
			SELECT F1_FILIAL,F1_DOC,F1_FORNECE,F1_LOJA,F1_TIPO,F1_STATUS
			FROM %Table:SF1%
			WHERE F1_FILIAL   = %exp:cFil%
			   AND F1_SERIE    = %exp:cSerie%
			   AND F1_DOC      = %exp:cDoc%
			   AND F1_FORNECE  = %exp:cFornece%
			   AND F1_LOJA     = %exp:cLoja%
			   AND D_E_L_E_T_ <> '*'
	EndSQl             

RETURN(NIL)