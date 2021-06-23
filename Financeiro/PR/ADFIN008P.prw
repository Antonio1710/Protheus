#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADFIN008PบAutor  ณWILLIAM COSTA       บ Data ณ  08/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa็ใo de troca de fornecedores para titulos RJ        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AD'oro - Solicitado Sr. REGINALDO                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADFIN008P()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa็ใo de troca de fornecedores para titulos RJ')
	                                
	_cFile := cGetFile( "Lista Arquivos CSV|*.csv|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( _cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + _cFile ) )
	
	      _aFile := Directory( _cFile )
	      
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	
	End

Return( NIL )

Static Function ProcFile()   

	Local nPos1   := 0
	Local nPos2   := 0
	Local nPos3   := 0
	Local cRecno  := ''
	Local nRecno  := 0
	Local cFornec := ''
	Local cLoja   := ''
	Local cHistor := ''
	Local _cLF    := Chr( 10 )
	Local _cTxt   := ''
	Local _cChr   := ''
	Local _nTam   := 0
	PRIVATE cArq  := CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
	PRIVATE cPath := GetTempPath() + cArq //Local de Gera็ใo do Arquivo
	Private nHdl  
	Private cVar  := ''   
	
	FT_FUse( _cFile ) 
	_nTam += FT_FlastRec()
	_nTam ++
	FT_FGoTop()
	ProcRegua( _nTam )
	
	// Campo 1 := R_E_C_N_O_ DA TABELA SE2
	// Campo 2 := E2_FORNECE
	// Campo 3 := E2_LOJA
	// Campo 4 := E2_HIST
	
	_nLinha := 1
	While ! ( FT_FEof() )
	
    	IncProc( 'Aguarde, importando registros..' )
      	_cTxt :=  FT_FReadLN()
      
      	IF _nLinha <> 1   //primeira linha de cabe็alho ้ preciso ser pulada            
        	IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
            
	        	nPos1   := at(";",_cTxt)               			                
	   	     	nPos2   := at(";",subs(_cTxt,nPos1+1))			                
			    nPos3   := at(";",subs(_cTxt,nPos1+nPos2+1))                   
			    
			    cRecno  := Alltrim(Substr(_cTxt, 01,nPos1-1))
			    nRecno  := VAL(cRecno)
				cFornec := STRZERO(VAL(Substr(_cTxt,nPos1+1,nPos2-1)),6)     
				cLoja   := STRZERO(VAL(Substr(_cTxt,nPos1+nPos2+1,nPos3-1)),2)     
				cHistor := Alltrim(Substr(_cTxt,nPos1+nPos2+nPos3+1,LEN(_cTxt)))
				
				SqlBuscaZAF(cRecno)
			    
			    While TRB->(!EOF())
			    
			    	DBSELECTAREA( "SE2" )
						SE2->( DBGOTO( nRecno ) )
						
						IF SE2->( RECNO() ) == nRecno
						
							Reclock("SE2",.F.)	
								SE2->E2_FORNECE := cFornec
							    SE2->E2_LOJA    := cLoja
						     	SE2->E2_NOMFOR  := POSICIONE("SA2",1,xFilial("SA2")+cFornec + cLoja,"A2_NREDUZ")
						     	SE2->E2_HIST    := cHistor    
							SE2->(MsUnlock())		    			
						
						ENDIF
			    	SE2->(dbCloseArea())
			    	
			    	DBSELECTAREA( "ZAF" )
						ZAF->(DBGOTO(TRB->ZAF_RECNO))
						
						IF ZAF->(RECNO()) == TRB->ZAF_RECNO
						
							Reclock("ZAF",.F.)
							
								ZAF->ZAF_CESSIO := cFornec
							    ZAF->ZAF_LOJACE := cLoja
						     	
							ZAF->(MsUnlock())		    			
						
						ENDIF
			    	ZAF->(dbCloseArea())
			    	
				    /*	    
				    dbSelectArea("SZI")
		            dbSetOrder(4) 
		            IF dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+SZK->ZK_ROTEIRO)
		              
		            	Reclock("SZI",.T.)	
			                SZI->ZI_DOC     := _cFile
						    SZI->ZI_SEQ     := STRZERO(_nSeq,2)
					     	SZI->ZI_DATALAN := SZK->ZK_DTENTR    
						    SZI->ZI_PLACA   := SZK->ZK_PLACAPG
					    	SZI->ZI_FORNEC  := SZK->ZK_FORNEC
						    SZI->ZI_LOJA    := SZK->ZK_LOJA
						    SZI->ZI_NOMFOR  := SZK->ZK_NOMFOR
				      		SZI->ZI_ROTEIRO := SZK->ZK_ROTEIRO  
				      		SZI->ZI_GUIA    := SZK->ZK_GUIA 
				      		SZI->ZI_DATAROT := SZK->ZK_DTENTR    
			          		SZI->ZI_CODIGO  := _cCod
		                  	SZI->ZI_TIPO    := _ctipo
		                  	SZI->ZI_DESCRIC := _cDesc
		                  	SZI->ZI_OBS     := _cObs
		                	SZI->ZI_VALOR   := _nVal  		                
			          	SZI->(MsUnlock())		    			
				    	
				    ENDIF*/
				            
		        	TRB->(dbSkip())
				ENDDO //fecha enddo do TRB
				TRB->(dbCloseArea())
			ENDIF //FECHA IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
        ENDIF // FECHA IF DE LINHA <> DE 1
        _nLinha := _nLinha + 1
        FT_FSkip()   
	ENDDO //FECHA WHILE
	
	FT_FUse()
Return( NIL )     


Static Function SqlBuscaZAF(cRecno)

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT %Table:SE2%.R_E_C_N_O_ AS SE2_RECNO, 
			       %Table:ZAF%.R_E_C_N_O_ AS ZAF_RECNO,
				   E2_FORNECE,
				   E2_LOJA,
				   E2_NOMFOR,
				   E2_HIST,
				   ZAF_FORNEC,
				   ZAF_LOJA,
				   ZAF_CESSIO,
				   ZAF_LOJACE
			  FROM %Table:SE2%,%Table:ZAF%
			 WHERE %Table:SE2%.R_E_C_N_O_  = %EXP:cRecno%
			   AND ZAF_FILIAL         = E2_FILIAL
			   AND ZAF_PREFIX         = E2_PREFIXO
			   AND ZAF_NUMERO         = E2_NUM
			   AND ZAF_PARCEL         = E2_PARCELA
			   AND %Table:SE2%.D_E_L_E_T_ <> '*'
			   AND %Table:ZAF%.D_E_L_E_T_ <> '*'
			   
    EndSQl             
RETURN(NIL) 

