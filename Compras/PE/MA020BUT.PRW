#Include "RwMake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Topconn.ch"

/*{Protheus.doc} User Function MA020BUT
	Botao para Recusar Novo Fornecedor
	@type  Function
	@author Ricardo Lima
	@since 08/12/2017
	@version 01
	@history Chamado 049218 - FWNM             - 27/08/2019 - Novo status p/ recusa (A2_XPRECAD = 3)  
	@history Chamado 052327 - Adriana Oliveira - 07/10/2019 - Habilita Pre-cadastro Fornecedor p/ SAFEGG
	@history Chamado 052327 - Adriana Oliveira - 16/10/2019 - Ajuste emails Pre-Cadastro p/ SAFEGG
	@history Chamado 052636 - William Costa    - 25/11/2019 - Adicionado a empresa 07 para carregar corretamente o pré cadastro

*/	

User Function MA020BUT

	Local aButtons := {} 
	
	if  cEmpAnt $ "01/02/07/09" // Por Adriana Oliveira em 07/10/2019 - Chamado 052327 // William Costa 25/11/2019 chamado 052636 
		
	 	AAdd(aButtons,{ 'NOTE'     ,{| |  U_ADCOM012() }, 'Recusa Cadastro' , 'Recusa Cadastro' } )
	 	AAdd(aButtons,{ 'TABPRICE' ,{| |  U_ADCOMP12() }, 'Consulta Log'    , 'Consulta Log' } )
	
	endif

Return (aButtons)

/*{Protheus.doc} User Function ADCOMP12P
	Recusar Novo Fornecedor
	@type  Function
	@author Ricardo Lima
	@since 08/12/2017
	@version 01
*/	

User Function ADCOM012

	Local cMsgRc    := SPACE(200)
	Local cMensagem := ""
	Local cAssunto  := "Recusa de Fornecedor - "+Alltrim(FWGrpName(cempant)) // Por Adriana Oliveira em 16/10/2019 - Chamado 052327
	Local aRetUser := {}
	Local cEmail   := ""
	Local cQuery   := ""
	Local sMsgRej  := ""
	Local cDsWfFis  := SuperGetMv( "MV_#EMLWF1" , .F. , '' ,  )+';'+SuperGetMv( "MV_#EMLWF2" , .F. , '' ,  )
	
	if SA2->A2_MSBLQL <> '1'
		MsgBox('O Fornecedor não está Bloqueado!' ,'Prospect Fornecedor','Info')
		RETURN()
	ENDIF
	
	If MsgYesNo("Deseja Recusar o Cadastro de Fornecedor, Será enviado um Workflow solicitando a correção dos dados. ")
	
		@0,0 TO 110,300 DIALOG oDlg TITLE "Justificativa"
		@10,20 SAY "Digite uma Justificativa: "
		@20,20 MSGET cMsgRc picture "@!" SIZE 120,10 PIXEL OF oDlg Valid !Empty(cMsgRc)
			
		//@ 40,050 BUTTON "&Gravar" SIZE 33,14 PIXEL ACTION (nOpcaoTela := 1,oDlg:End())
		@ 40,108 BUTTON "&Confirma" SIZE 33,14 PIXEL ACTION oDlg:End()
		ACTIVATE DIALOG oDlg CENTER
	
		// Chamado n. 049218 || OS 050526 || FINANCAS || ANDREA || 8319 || CAD. FORNECEDOR - fwnm - 27/08/2019
		RecLock("SA2", .f.)
			SA2->A2_XPRECAD := "3" // Recusado
			SA2->A2_USERALT := CUSERNAME
			SA2->A2_DTALT   := DATE() 
		SA2->( msUnLock() ) 
		//
		
		RecLock("CV8",.T.)
	     CV8->CV8_FILIAL  := xFilial("CV8")
		 CV8->CV8_MSG     := "RECUSA DO CADASTRO DE FORNECEDOR"
		 CV8->CV8_PROC    := alltrim(FUNNAME()) + SA2->A2_COD
		 CV8->CV8_DET     := cMsgRc// "ALTERADO O FORNECEDOR: " + M->A2_COD  + ", REGISTRO ALTERADO PELA EMPRESA: " + cEmpAnt + ", FILIAL: " + cfilant
		 CV8->CV8_USER    := SubStr(cUsuario,7,15)
		 CV8->CV8_DATA    := DATE()
		 CV8->CV8_HORA    := TIME()
		 CV8->CV8_INFO    := '1'
		MSUNLOCK()
		
		// ENVIA WORKFLOW
		cQuery := " SELECT AC9_XPAREC "
		cQuery += " FROM "+RetSqlName("AC9")+" "
		cQuery += " WHERE AC9_CODENT = '"+SA2->A2_COD + SA2->A2_LOJA+"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		If Select("MA20B") > 0
	    	MA20B->(DbCloseArea())		
	    EndIf	
	    TcQuery cQuery New Alias "MA20B"
		sMsgRej := "Parecer da Rejeição: "+chr(13)+chr(10)
		WHILE MA20B->( !EOF() )
	    	sMsgRej += MA20B->AC9_XPAREC+","+chr(13)+chr(10)
	    	MA20B->( DbSkip() )
		END 
		cMensagem := U_MntMsc( SA2->A2_COD , SA2->A2_LOJA , SA2->A2_NOME , SA2->A2_CGC , SA2->A2_INSCR , SA2->A2_END , SA2->A2_BAIRRO , SA2->A2_MUN , SA2->A2_USERINC , SA2->A2_DTINC , "R" , sMsgRej+cMsgRc )
		
		PswOrder(2) // Ordem de nome
		If PswSeek( ALLTRIM(SA2->A2_USERINC) , .T. )
			aRetUser := PswRet(1)
			cEmail   := upper(alltrim(aRetUser[1,14]))
		ENDIF	 
		
		u_F050EnvWF( cAssunto , cMensagem , cEmail+';'+cDsWfFis , '' )
	ENDIF

return

/*{Protheus.doc} User Function ADCOMP12
	Recusar Novo Fornecedor
	@type  Function
	@author Ricardo Lima
	@since 08/12/2017
	@version 01
*/	

User Function ADCOMP12

	ProcLogIni( {},"MATA020" + M->A2_COD)
	ProcLogView()

RETURN