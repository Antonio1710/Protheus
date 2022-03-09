#include "PROTHEUS.CH"
#include "rwmake.ch"  
#include "topconn.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADFVC    º Autor ³ Mauricio-MDS TEC   º Data ³  26/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para cadastro de motoristas                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Adoro - Solicitação Sr. James                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*/{Protheus.doc} User Function CADFVC
	Tela para cadastro de motoristas.
	@author Mauricio-MDS TEC - Adoro - Solicitação Sr. James
	@since 26/06/13
	@version 01
	@history ticket 69517 - Leonardo P. Monteiro - 09/03/2022 - Cadastro de motorista Bolivianos. Validação na exclusão de motoristas.
/*/

User Function CADFVC() 

	Local aRotAdic :={} 
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro de motoristas')
	     
	aadd(aRotAdic,{ "* LOGS","u_FVCLOG()", 0 , 6 })
	 
	AXCADASTRO("ZVC","Cadastro de Motoristas ","U_CADFVA()","U_COKMOTO()",aRotAdic,)
	
Return()

User function CADFVA()
	Local lRet 		:= .T.
	Local cQuery 	:= ""

	cQuery := " SELECT COUNT(*) CONTADOR "
	cQuery += " FROM "+ retsqlname("ZV4") +" ZV4 "
	cQuery += " WHERE D_E_L_E_T_='' AND ZV4_FILIAL='"+ xFilial("ZV4") +"' AND "
	
	if !Empty(M->ZVC_CPF)
		cQuery += "   (ZV4_CPF  = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF1 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF2 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF3 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF4 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF5 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF6 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF7 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF8 = '"+ alltrim(ZVC->ZVC_CPF) +"' "
		cQuery += " OR ZV4_CPF9 = '"+ alltrim(ZVC->ZVC_CPF) +"') "
	else
		cQuery += "   (ZV4_PASPO  = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO1 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO2 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO3 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO4 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO5 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO6 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO7 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO8 = '"+ alltrim(ZVC->ZVC_PASPOR) +"' "
		cQuery += " OR ZV4_PASPO9 = '"+ alltrim(ZVC->ZVC_PASPOR) +"') "
	endif

	Tcquery cQuery ALIAS "QZV4" NEW

	if QZV4->CONTADOR > 0
		lRet := .F.
		MsgStop("Esse motorista está vinculado a um veículo, por isso, não poderá ser deletado.", "Cadastro em uso")
	endif

	QZV4->(DBCLOSEAREA())

return lRet

//rotina para gravar o log de alteração
User Function COKMOTO()    

	Local _aNomCpo 	:= {}
	Local _cAlter  	:= ''
	Local _nx		:= 0
	Local lRet		:= .T.

	U_ADINF009P('CADFVC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Tela para cadastro de motoristas')
	
	//rotina para aterar 	
	if INCLUI
		cQuery := " SELECT COUNT(*) CONTADOR "
		cQuery += " FROM "+ retsqlname("ZVC") +" ZVC "
		cQuery += " WHERE D_E_L_E_T_='' AND ZVC_FILIAL='"+ xFilial("ZVC") +"' AND "
		
		if !Empty(M->ZVC_CPF)
			cQuery += "  ZVC_CPF  = '"+ alltrim(M->ZVC_CPF) +"' "
		else
			cQuery += "  ZVC_PASPOR  = '"+ alltrim(M->ZVC_PASPOR) +"' "
		endif

		Tcquery cQuery ALIAS "QZVC" NEW

		if QZVC->CONTADOR > 0
			lRet := .F.
			MsgStop("Já existe um motorista cadastrado com esse CPF.", "Cadastro em uso")
		endif

		QZVC->(DBCLOSEAREA())

	ElseIf ALTERA
		
		DbSelectArea("SX3")
		DbSetOrder(1)
		SX3->(DbSetOrder(1))
		SX3->(DbSeek('ZVC'))
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'ZVC'
			If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
				AADD(_aNomCpo,{SX3->X3_CAMPO,SX3->X3_TIPO})
			EndIf
			SX3->(DbSkip())
		Enddo
		
		dbSelectArea("ZVC")
		DbSetOrder(1)
		If dbseek(xFilial("ZVC")+M->ZVC_CPF)
			For _nx := 1 to len(_aNomCpo)
				_mCampo := "M->"+_aNomCpo[_nx][1]
				_cCampo := "ZVC->"+_aNomCpo[_nx][1]
				IF &_mCampo <> &_cCampo  &&Sendo diferentes campo foi alterado
					//MsgInfo("Campo "+_cCampo+" foi alterado de "+&_cCampo+" para "+&_mCampo+" ")
					_mCpoGrv := ""
					_cCpoGrv := ""
					If _aNomCpo[_nx][2] == "C"
					   _mCpoGrv := &_mCampo
					   _cCpoGrv	:= &_cCampo					
					Elseif _aNomCpo[_nx][2] == "N"
					   _mCpoGrv := Alltrim(STR(&_mCampo))
					   _cCpoGrv	:= Alltrim(STR(&_cCampo))						
					Elseif _aNomCpo[_nx][2] == "D"
					   _mCpoGrv := DTOC(&_mCampo)
					   _cCpoGrv	:= DTOC(&_cCampo)
					Else
					   _mCpoGrv := "conteudo memo"    &&conteudo memo não vai ser possivel gravar conteudo por conta do tamanho.
				       _cCpoGrv := "Conteudo memo"
					Endif
				
					_cAlter := "Campo "+Alltrim(_cCampo)+" de "+Alltrim(_cCpoGrv)+" para "+alltrim(_mCpoGrv)+" "
								
					dbSelectArea("ZBE")
					RecLock("ZBE",.T.)
					Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
					Replace ZBE_DATA 	   	WITH Date()
					Replace ZBE_HORA 	   	WITH TIME()
					Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
					Replace ZBE_LOG	        WITH _cAlter
					Replace ZBE_MODULO	    WITH "ZVC-MOTORISTA"
					Replace ZBE_ROTINA	    WITH "CADFVC"
					Replace ZBE_PARAME	    WITH "CODIGO MOTORISTA: " + M->ZVC_CPF
					ZBE->(MsUnlock())
																					
				Endif
			Next
			
			If !Empty(_cAlter)
			
				M->ZVC_XUSUAL	:= "USUARIO: "+UPPER(Alltrim(cUserName))+" DATA: "+DTOC(Date()) //grava o ultimo usuario na alteração	
			
			EndIf
			
		Endif
		
	Endif
	
Return lRet  
  
//Apresenta Historico/Log com todas as acoes tomadas
//chamado 029467 02/07/2017 - Fernando Sigoli
User Function FVCLOG()

	Local aArea		:= GetArea()
	Local oDlg
	Local Query     := ""
	Local nx 		:= 0
	Local aSize    	:= MsAdvSize()
	Local aPosObj  	:= {}
	Local aObjects 	:= {}
	Local aInfo		:= {}
	Local aCpos		:= {}
	Local nOpcao	:= 0
	Local aListBox	:= {}
	Local oTik		:= LoadBitMap(GetResources(), 'LBTIK')
	Local oNo		:= LoadBitMap(GetResources(), 'LBNO' )
	Local oMarca	:= LoadBitMap(GetResources(), 's4wb018n.png')
	Local cCampos 	:= ''
	
	Private aTela	[0][0]
	Private aGets	[0]
	
	//Tamanho da tela
	aObjects := {}
	aAdd( aObjects, { 100,  20, .t., .f. } )
	aAdd( aObjects, { 100,  80, .t., .t. } )
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	Query := " SELECT ZBE_DATA,ZBE_HORA,ZBE_USUARI,ZBE_LOG,ZBE_PARAME FROM "+retsqlname("ZBE")+" WHERE ZBE_ROTINA = 'CADFVC' and ZBE_PARAME LIKE '%"+ZVC->ZVC_CPF+"%' ORDER BY ZBE_DATA DESC, ZBE_HORA DESC "
	TCQUERY Query new alias "LOG1"    
	
	// Adiciona elementos ao Array da ListBox
	LOG1->(dbgotop())
	While !EOF()  
		aAdd( aListBox,{ LOG1->ZBE_USUARI, LOG1->ZBE_DATA, LOG1->ZBE_HORA, LOG1->ZBE_LOG,  })
	DbSkip()
	End  
	
	DbCloseArea("LOG1")
	   
	If Empty( aListBox )
	
		Alert( 'Nenhuma ocorrencia de Log para este Motorista' )
	
	Else
	
		
		DEFINE MSDIALOG oDlg TITLE "Histórico/Log" FROM aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
		
		@ 010,10 Say 'Motorista: '+Alltrim(ZVC->ZVC_MOTORI) SIZE 200,15 OF oDlg PIXEL
		
		@ aPosObj[2,1],aPosObj[2,2] ListBox oListBox Fields HEADER "Usuario", "Data", "Hora", "LOG/Alteracao";
		Size aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1] Of oDlg Pixel ColSizes 50,50,50,70,100
		
		oListBox:SetArray(aListBox)
		
		oListBox:bLine := {|| {	aListBox[oListBox:nAT,01], DTOC(STOD(aListBox[oListBox:nAT,02]))  ,aListBox[oListBox:nAT,03], aListBox[oListBox:nAT,04]}}
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcao:=1, If( Obrigatorio( aGets, aTela) ,oDlg:End(),Nil)},{||nOpcao:=0,oDlg:End()},.F.,)
	
	Endif
	
	RestArea( aArea )

Return Nil 
