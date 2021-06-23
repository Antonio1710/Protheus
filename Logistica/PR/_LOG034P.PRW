#INCLUDE "PROTHEUS.CH"  
#INCLUDE "AP5MAIL.CH"     
#INCLUDE "rwmake.ch"  
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH' 

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณ_LOG034P  บAutor  ณWILLIAM COSTA       บ Data ณ  17/07/2017 บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDesc.     ณPontos de Entrada referente ao fonte MVC ADLOG034P          บฑฑ
//ฑฑบ          ณ                                                            บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ SIGAFAT                                                    บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

USER FUNCTION _LOG034P()   

	LOCAL aParam     := PARAMIXB
	LOCAL xRet       := .T.
	LOCAL oObj       := ''
	LOCAL cIdPonto   := ''
	LOCAL cIdModel   := ''
	LOCAL lIsGrid    := .F.
	LOCAL nLinha     := 0
	LOCAL nQtdLinhas := 0
	LOCAL cMsg       := '' 
	LOCAL _aNomCpo   := {}
	LOCAL _cAlter    := ''  
	
	IF aParam <> NIL
	      
	       oObj       := aParam[1]
	       cIdPonto   := aParam[2]
	       cIdModel   := aParam[3]
	       lIsGrid    := (LEN(aParam) > 3) 
	        
	       IF cIdPonto == 'MODELPOS' // Na valida็ใo total do modelo. 
	       
	       		IF oObj:NOPERATION == 4 // 'ALTERA'
	            	
	            	DbSelectArea("SX3")
					DbSetOrder(1)
					SX3->(DbSetOrder(1))
					SX3->(DbSeek('ZBV'))
					While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'ZBV'
						If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_CONTEXT <> "V"
							AADD(_aNomCpo,{SX3->X3_CAMPO,SX3->X3_TIPO})
						EndIf
						SX3->(DbSkip())
					Enddo
					
					dbSelectArea("ZBV")
					DbSetOrder(2)
					If dbseek(xFilial("ZBV")+M->ZBV_COD)
						For _nx := 1 to len(_aNomCpo)
							_mCampo := "M->"+_aNomCpo[_nx][1]
							_cCampo := "ZBV->"+_aNomCpo[_nx][1]
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
								   _mCpoGrv := "conteudo memo"    &&conteudo memo nใo vai ser possivel gravar conteudo por conta do tamanho.
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
								Replace ZBE_MODULO	    WITH "LOGISTICA"
								Replace ZBE_ROTINA	    WITH "ADLOG034P"
								Replace ZBE_PARAME	    WITH "CODIGO PROPRIETARIO: " + M->ZBV_COD
								ZBE->(MsUnlock())
																								
							Endif
						Next
						
						If !Empty(_cAlter)
						
							M->ZBV_XUSUAL	:= "USUARIO: "+UPPER(Alltrim(cUserName))+" DATA: "+DTOC(Date()) //grava o ultimo usuario na altera็ใo	
						
						EndIf
           			
           		
 	            		xRet := .T.
 	            	ENDIF //dbseek(xFilial("ZBV")+M->ZBV_COD)
			    ENDIF // oObj:NOPERATION == 4 // 'ALTERA'
	       ENDIF //cIdPonto == 'MODELPOS'
	ENDIF //aParam <> NIL       
      
RETURN(xRet)