#include "rwmake.ch"   
#include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} User Function FA070TIT
	Central Aprovação
	@type  Function
	@author Ricardo Lima
	@since 14/11/2017
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@chamado 038609
    @history Chamado 051017 - FWNM         - 09/09/2019 - Estorno e cancelamento na mesma data baixa
	@history Chamado 053347 - FWNM         - 29/11/2019 - 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL
/*/
User Function FA070TIT

	Local _lRet := .T.
	Local nVlrMaxd := 0
	Local cTpDivf  := "000004"
	local sDscBlq  := ""
	Local cAssunto  := "Central de Aprovação"
	Local cMensagem := ""  
	Local c2Query   := ""
	Local cmaildest := ""
	Local lEnvWFCA  := SuperGetMv( "MV_#FA5ENV" , .F. , .T. ,  )
	Local dDataFin := GetMV("MV_DATAFIN") 	// Chamado n. 051017 - Desenvolver tratativa no estorno e cancelamento na mesma data da baixa - FWNM - 09/09/2019
	
	//if cEmpAnt = '01' .or. cEmpAnt = '02' // Chamado n. 053347 || OS 054719 || FINANCAS || EDUARDO || 8352 || IMPLANTAR CENTRAL - FWNM - 02/12/2019 
	cAssunto := cAssunto + " - " + AllTrim(SM0->M0_NOME)

	    IF SE1->E1_XDIVERG = "S"
	        MsgInfo("Titulo Com divergencia, Necessário Aprovação!", "Informacao")      
	        _lRet := .F.
	    ENDIF
	    
	    DbSelectArea("SX5")
		DbSetOrder(1)
		DbSeek( FwxFilial("SX5") + 'Z9' + cTpDivf )
		sDscBlq := Alltrim(SX5->X5_DESCRI)
	
	    dbSelectArea("SA1")
	    dbSetorder(1)
	    dbSeek( FWxFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA )
	    IF !EMPTY(SA1->A1_DESC) .AND. nDescont > 0
	        nVlrMaxd := nValRec * (SA1->A1_DESC/100)
	        
	        DbSelectArea("ZC7")
			DbSetOrder(2)
			IF DbSeek( FwxFilial("ZC7") + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
	            WHILE ZC7->(!EOF()) .AND. ZC7->ZC7_FILIAL=FwxFilial("ZC7") .AND. ZC7->ZC7_CLIFOR=SE1->E1_CLIENTE .AND. ZC7->ZC7_LOJA=SE1->E1_LOJA .AND. ZC7->ZC7_PREFIX=SE1->E1_PREFIXO .AND. ZC7->ZC7_NUM=SE1->E1_NUM .AND. ZC7->ZC7_PARCEL=SE1->E1_PARCELA .AND. ZC7->ZC7_TIPO=SE1->E1_TIPO
	                IF !EMPTY(ZC7->ZC7_USRAPR) .AND. ZC7->ZC7_CNABDE == nDescont .AND. ZC7->ZC7_RECPAG = 'R'
	                    Return(.T.)
	                ENDIF
	            DbSkip()
		        END
	        ENDIF
	
	        if (nTotAbLiq + nDescont) > nVlrMaxd
	            MsgInfo("Soma de Abatimento mais Desconto Informado é maior que Desconto Permitido, Titulo será enviado para Aprovação!", "Informacao")      
	            RecLock("SE1",.F.)
	                SE1->E1_XDIVERG := 'S'
	            MSUnlock()
	            //Return(.F.)
	            _lRet := .F.
	                DbSelectArea("ZC7")
					DbSetOrder(2)
					IF DbSeek( FwxFilial("ZC7") + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
						IF EMPTY(ZC7_USRAPR)
							RecLock("ZC7",.F.)
								ZC7->ZC7_CNABDE := nDescont								 		
							MSUnlock()
						ELSE
							RecLock("ZC7",.T.)
	                            ZC7->ZC7_FILIAL := FwxFilial("SE1")
	                            ZC7->ZC7_PREFIX := SE1->E1_PREFIXO
	                            ZC7->ZC7_NUM    := SE1->E1_NUM
	                            ZC7->ZC7_PARCEL := SE1->E1_PARCELA
	                            ZC7->ZC7_TIPO   := SE1->E1_TIPO
	                            ZC7->ZC7_CLIFOR := SE1->E1_CLIENTE
	                            ZC7->ZC7_LOJA   := SE1->E1_LOJA
	                            ZC7->ZC7_CNABDE := nDescont
	                            ZC7->ZC7_TPBLQ  := cTpDivf
	                            ZC7->ZC7_DSCBLQ := sDscBlq += ", Desconto"		
	                            ZC7->ZC7_RECPAG := "R"		 
								ZC7->ZC7_USRALT := __cUserID		
							MSUnlock()
						ENDIF
					ELSE		
					 RecLock("ZC7",.T.)
						ZC7->ZC7_FILIAL := FwxFilial("SE1")
						ZC7->ZC7_PREFIX	:= SE1->E1_PREFIXO
						ZC7->ZC7_NUM   	:= SE1->E1_NUM
						ZC7->ZC7_PARCEL	:= SE1->E1_PARCELA
						ZC7->ZC7_TIPO   := SE1->E1_TIPO
						ZC7->ZC7_CLIFOR	:= SE1->E1_CLIENTE
						ZC7->ZC7_LOJA  	:= SE1->E1_LOJA
						ZC7->ZC7_CNABDE := nDescont
						ZC7->ZC7_TPBLQ 	:= cTpDivf
						ZC7->ZC7_DSCBLQ	:= sDscBlq += ", Desconto"		
						ZC7->ZC7_RECPAG := "R"		
						ZC7->ZC7_USRALT := __cUserID 		
					 MSUnlock()
					ENDIF
	            IF SE1->E1_XDIVERG = 'S'
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
		 		// RICARDO LIMA - 13/02/18
	                if !Empty(cmaildest)
		 		        cMensagem := u_WGFA050FIN( FwxFilial("SE1") , SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , SE1->E1_CLIENTE , SE1->E1_LOJA , SE1->E1_VALOR , sDscBlq , 'C' )
		 		        If lEnvWFCA
							u_F050EnvWF( cAssunto , cMensagem , cmaildest , '' )
						EndIf 
	                endif
			    ENDIF    
	        endif
	
	    ENDIF
	//endif

	// Chamado n. TI - Desenvolver tratativa no estorno e cancelamento na mesma data da baixa
	If dDataBase < dDataFin
		_lRet := .f.
		Aviso("FA070TIT-01", "Baixa não permitida! Financeiro bloqueado nesta data. Ajuste a database ou contate o departamento financeiro...",{"OK"},, "MV_DATAFIN: " + DtoC(dDataFin))
	EndIf
	//

Return(_lRet)