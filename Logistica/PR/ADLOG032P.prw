#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
//ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
//ฑฑบPrograma  ณADLOG032P บAutor  ณWILLIAM COSTA       บ Data ณ  21/02/2017 บฑฑ
//ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
//ฑฑบDesc.     ณ Importa็ใo de valores Acrescimo/Descrescimo por Data/Placa บฑฑ
//ฑฑบDesc.     ณ Utilizado para importacao de Frango Vivo                   บฑฑ
//ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
//ฑฑบUso       ณ SIGAFAT - CHAMADO 033397                                   บฑฑ
//ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
//฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿

USER FUNCTION ADLOG032P() //U_ADLOG032P()

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa็ใo de valores Acrescimo/Descrescimo por Data/Placa Utilizado para importacao de Frango Vivo')
	                                
	_cFile := cGetFile( "Lista Arquivos CSV|*.csv|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	IF ! EMPTY( _cFile )
	
	   IF ( MsgNoYes( "Confirma importacao do arquivo " + _cFile ) )
	
	      _aFile := Directory( _cFile )
	      
	      PROCESSA( { || ProcFile("Analisando arquivo!!!") } )
	     
	   END
	END

RETURN(NIL)

STATIC FUNCTION ProcFile()   

	LOCAL nPos1         := 0
	LOCAL nPos2         := 0
	LOCAL nPos3         := 0
	LOCAL nPos4         := 0
	LOCAL nPos5         := 0
	LOCAL nPos6         := 0
	LOCAL _cLF          := Chr( 10 )
	LOCAL _cTxt         := ''
	LOCAL _cChr         := ''
	LOCAL _nTam         := 0 
	
	PRIVATE cArq        := CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
	PRIVATE cPath       := GetTempPath() + cArq //Local de Gera็ใo do Arquivo
	PRIVATE nHdl        := NIL
	PRIVATE cVar        := '' 
	PRIVATE _cGuia      := ''       
	PRIVATE _cSeq       := 0
	PRIVATE	_lSegue     := .T.

	FT_FUse( _cFile ) 
	_nTam += FT_FlastRec()
	_nTam ++
	FT_FGoTop()
	PROCREGUA( _nTam )
	
	&&campos     12
	&&placa      12
	&&data       12
	&&GUIA       06
	&&codigo     12
	&&observacao 50
	&&valor      12
	
	_nLinha := 1
	WHILE ! ( FT_FEof() )
	
	      INCPROC( 'Aguarde, importando registros..'+cvaltochar(_nLinha))
	      _cTxt :=  FT_FReadLN()
	      
	      IF _nLinha <> 1   &&primeira linha de cabe็alho ้ preciso ser pulada            
	         
	         IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
	            
	         
	            // *********************** INICIO DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
	           	nPos1   := at(";",_cTxt)               			           // Data
	   	     	nPos2   := at(";",subs(_cTxt,nPos1+1))			           // Guia
			    nPos3   := at(";",subs(_cTxt,nPos1+nPos2+1))               // Placa
			    nPos4   := at(";",subs(_cTxt,nPos1+nPos2+nPos3+1))         // Codigo Acrescimo e Descrimo
			    nPos5   := at(";",subs(_cTxt,nPos1+nPos2+nPos3+nPos4+1))   // Observacao
				nPos6   := nPos1+nPos2+nPos3+nPos4+nPos5+1  // Valor
	            
	            _dData  := CTOD(Alltrim(Substr(_cTxt, 01,nPos1-1)))
	            _cGuia  := Alltrim(Substr(_cTxt,nPos1+1,nPos2-1))     
	            _cPlaca := Alltrim(Substr(_cTxt,nPos1+nPos2+1,nPos3-1))     
	            _cCod   := Alltrim(Substr(_cTxt,nPos1+nPos2+nPos3+1,nPos4-1))    
	            _cObs   := Alltrim(Substring(_cTxt,nPos1+nPos2+nPos3+nPos4+1,nPos5-1)) 
	            _cVal   := Alltrim(Substr(_cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+1,nPos6 - 1)) 
	            _nVal   := Val(StrTran(_cVal,",","."))
	            
	            // *********************** FINAL DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
	             
	            DbSelectArea("SZJ")
	            DbSetOrder(1)
	            If Dbseek(xFilial("SZJ")+_cCod)
	               _cTipo := SZJ->ZJ_TIPO
	               _cDesc := SZJ->ZJ_DESCRIC
	            Else
	               
	               cVar += "O codigo "+_cCod+" nใo foi encontrado na tabela de tipos de acresc./decresc. Registro placa-data-Guia "+_cPlaca+"-"+DTOC(_dData)+"-"+_cGuia + chr(13) + chr(10)
	               _nLinha ++   
	               FT_FSkip()
	               loop       &&30/10/13 - Mauricio - MDS TECNOLOGIA - a pedido do Sr. James retirado interrup็ใo da rotina e implementado tratamento para aviso apenas e continuidade em proximo registro
	            
	            Endif 
	             
	            If Select("Work") > 0
					Work->( dbCloseArea() )
				EndIf 
	            
	            //caso achar o registro na SZI, guardo o ultima sequencia : chamado: 043481 11/09/2018 - Fernando Sigoli
		        cQrySq := " SELECT MAX(ZI_SEQ) ZI_SEQ  FROM " + RetSqlName("SZI")+ "  WHERE D_E_L_E_T_ = '' AND  ZI_PLACA = '"+_cPlaca+"' AND ZI_DATALAN = '"+dtos(_dData)+"' AND ZI_GUIA = '"+_cGuia+"' "
	            tcQuery cQrySq new alias "Work"
	            
	            Work->( dbGoTop() )
	
 				If Val(Work->ZI_SEQ) > 0 
					_nSeq := Val(Work->ZI_SEQ)
				Else 
					_nSeq := 0	
				EndIf	
	            
	           	Work->( dbCloseArea() )
	           	
   			    DbSelectArea("ZV1")
	            DbSetOrder(5)
	            If dbseek(xFilial("ZV1")+_cPlaca+dtos(_dData)+_cGuia)
	            
	               _cGuia   := ZV1->ZV1_GUIAPE
	                  
	               DbSelectArea("SZI")
	               SZI->(dbGoTop())
	      		   DbSetOrder(9) 
	               IF dbSeek(xFilial("SZI")+ZV1->ZV1_RPLACA+DTOS(ZV1->ZV1_DATA)+ZV1->ZV1_GUIAPE+_cCod)  //chamado: 043481 11/09/2018 - Fernando Sigoli
	               	
	               	   _lSegue := .T.
	               		
	               	   While SZI->(!Eof()) .AND. SZI->ZI_FILIAL == xFilial("SZI") .AND. SZI->ZI_PLACA == ZV1->ZV1_RPLACA .AND. ; 
			              	  DTOS(SZI->ZI_DATALAN) == DTOS(ZV1->ZV1_DATA) .AND. SZI->ZI_GUIA == ZV1->ZV1_GUIAPE  .and. SZI->ZI_CODIGO == _cCod //chamado: 043481 11/09/2018 - Fernando Sigoli
			                
			         		If dtos(_dData) == DTOS(SZI->ZI_DATALAN) .and. round(_nVal,2) == SZI->ZI_VALOR //se o valor for diferente deixamos alterar
			            		_lSegue := .F.
			            	
			           		Endif
					        
			           SZI->(dbSkip())
			           Enddo
			           
			           //inicio
			           If !_lSegue
			             
			             cVar += "O Guia/Data/Placa/Codigo/Valor("+_cGuia+"/"+Dtoc(_dData)+"/"+_cPlaca+"/"+_cCod+"/"+alltrim(STR(_nVal))+") ja existe lan็ado." + chr(13) + chr(10)
			             _nLinha ++   
	                     FT_FSkip()
	                     loop		          
	                     
			           Endif
			           
			           	_nSeq += 1
						_cFile := GetSX8NUM("SZI","ZI_DOC")
				        Reclock("SZI",.T.)	
				        SZI->ZI_DOC  	 := _cFile
						SZI->ZI_SEQ  	 := STRZERO(_nSeq,2)
						SZI->ZI_DATALAN  := ZV1->ZV1_DATA   
						SZI->ZI_PLACA    := ZV1->ZV1_RPLACA
						SZI->ZI_FORNEC   := ZV1->ZV1_FORREC
						SZI->ZI_LOJA     := ZV1->ZV1_LOJREC
						SZI->ZI_NOMFOR   := POSICIONE("SA2",1,xFilial("SA2")+ZV1->ZV1_FORREC + ZV1->ZV1_LOJREC,"A2_NOME")
						SZI->ZI_GUIA	 := ZV1->ZV1_GUIAPE
						SZI->ZI_DATAROT  := ZV1->ZV1_DATA     
						SZI->ZI_CODIGO   := _cCod
				        SZI->ZI_TIPO     := _ctipo
				        SZI->ZI_DESCRIC  := _cDesc
				        SZI->ZI_OBS      := _cObs
				        SZI->ZI_VALOR    := _nVal  		                
						SZI->(MsUnlock())		    			
						ConfirmSX8()
			           
			           
			           //fim
			    	
				   Else  &&sem registros anteriores na tabela SZI
	               
	               		_cFile := GetSX8NUM("SZI","ZI_DOC")
	                  	Reclock("SZI",.T.)	
	                 	SZI->ZI_DOC  		:= _cFile
				      	SZI->ZI_SEQ  		:= IIF(_nSeq = 0,STRZERO(1,2),STRZERO(_nSeq+1,2))
			     	  	SZI->ZI_DATALAN 	:= ZV1->ZV1_DATA   
				      	SZI->ZI_PLACA   	:= ZV1->ZV1_RPLACA
			    	  	SZI->ZI_FORNEC  	:= ZV1->ZV1_FORREC
				      	SZI->ZI_LOJA    	:= ZV1->ZV1_LOJREC
				      	SZI->ZI_NOMFOR  	:= POSICIONE("SA2",1,xFilial("SA2")+ZV1->ZV1_FORREC + ZV1->ZV1_LOJREC,"A2_NOME")
				      	SZI->ZI_GUIA		:= ZV1->ZV1_GUIAPE
				      	SZI->ZI_DATAROT 	:= ZV1->ZV1_DATA     
			        	SZI->ZI_CODIGO  	:= _cCod
	                  	SZI->ZI_TIPO    	:= _ctipo
	                  	SZI->ZI_DESCRIC 	:= _cDesc
	                  	SZI->ZI_OBS     	:= _cObs
	                  	SZI->ZI_VALOR   	:= _nVal  		                
			          	SZI->(MsUnlock())		    			
				      	ConfirmSX8()
				      
	               Endif
	            
	            Else
	               
	               cVar += "Nใo encontrado Guia/Data/Placa("+_cGuia+"/"+Dtoc(_dData)+"/"+_cPlaca+") no controle de fretes" + chr(13) + chr(10)
	               _nLinha ++   
	               FT_FSkip()
	               loop
	                      
	            Endif  
	                                                        
	         Endif
	         
	      Endif   
	      _nLinha ++   
	      FT_FSkip()   
	
	Enddo     
	
	
	FT_FUse()
	nHdl	:= fCreate(cPath) //Cria Arquivo para grava็ใo das etiquetas
	Set Century OFF
    If fWrite(nHdl,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
    	If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
        	fClose(nHdl)
            Return
        Endif
    Endif
	fClose(nHdl) 
	shellExecute( "Open", "C:\Windows\System32\notepad.exe", cPath, "C:\", 1 )
	     
Return( NIL )