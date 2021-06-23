#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M050TOK  º Autor ³ MAURICIO - MDS TEC º Data ³  23/06/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se e grava log de campos alterados                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ADORO                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function M050TOK()
Local _aArea 	:= GetArea()
Local _aNomCpo 	:= {}
Local _cAlter   := ""

If ALTERA
	
	DbSelectArea("SX3")
	DbSetOrder(1)
	SX3->(DbSetOrder(1))
	SX3->(DbSeek('SA4'))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'SA4'
		If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
			AADD(_aNomCpo,{SX3->X3_CAMPO,SX3->X3_TIPO})
		EndIf
		SX3->(DbSkip())
	Enddo
	
	dbSelectArea("SA4")
	DbSetOrder(1)
	If dbseek(xFilial("SA4")+M->A4_COD)
		For _nx := 1 to len(_aNomCpo)
			_mCampo := "M->"+_aNomCpo[_nx][1]
			_cCampo := "SA4->"+_aNomCpo[_nx][1]
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
				
				//MsgInfo("Campo "+_cCampo+" foi alterado de "+_cCpoGrv+" para "+_mCpoGrv+" ")
				_cAlter := "Campo "+Alltrim(_cCampo)+" de "+Alltrim(_cCpoGrv)+" para "+Alltrim(_mCpoGrv)+" "
								
				dbSelectArea("ZBE")
				RecLock("ZBE",.T.)
				Replace ZBE_FILIAL 	   	WITH xFilial("ZBE")
				Replace ZBE_DATA 	   	WITH Date()
				Replace ZBE_HORA 	   	WITH TIME()
				Replace ZBE_USUARI	    WITH UPPER(Alltrim(cUserName))
				Replace ZBE_LOG	        WITH _cAlter
				Replace ZBE_MODULO	    WITH "SA4"
				Replace ZBE_ROTINA	    WITH "M050TOK"
				Replace ZBE_PARAME	    WITH "CODIGO TRANSPORTADORA: " + M->A4_COD
				ZBE->(MsUnlock())
																				
			Endif
		Next
		
		If !Empty(_cAlter)
			
			M->A4_XINTEG  := "A"
			M->A4_XUSUALT := "USUARIO: "+UPPER(Alltrim(cUserName))+" DATA: "+DTOC(Date())
			
		EndIf
		
		
	Endif
	
Endif

RestArea(_aArea)
Return(.T.)