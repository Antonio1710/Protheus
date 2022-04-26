#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IMPACDC  บAutor  ณMauricio - MDS TEC  บ Data ณ  14/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa็ใo de valores Acrescimo/Descrescimo por Data/Placa บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AD'oro - Solicitado Sr. JAMES                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IMPACDC()
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa็ใo de valores Acrescimo/Descrescimo por Data/Placa')
	                                
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
	Local nPos4   := 0
	Local nPos5   := 0
	Local nPos6   := 0
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
	
	&&campos     12
	&&placa      12
	&&data       12
	&&Roteiro    12
	&&codigo     12
	&&observacao 50
	&&valor      12
	
	_nLinha := 1
	While ! ( FT_FEof() )
	
	      IncProc( 'Aguarde, importando registros..' )
	      _cTxt :=  FT_FReadLN()
	      
	      IF _nLinha <> 1   &&primeira linha de cabe็alho ้ preciso ser pulada            
	         IF LEN(_cTxt) <> 0 .AND. ALLTRIM(SUBSTR(_cTxt,1,1)) <> ';'  
	            
	         
	            // *********************** INICIO DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
	           	nPos1   := at(";",_cTxt)               			                // Data
	   	     	nPos2   := at(";",subs(_cTxt,nPos1+1))			                // Roteiro
			    nPos3   := at(";",subs(_cTxt,nPos1+nPos2+1))                   // Placa
			    nPos4   := at(";",subs(_cTxt,nPos1+nPos2+nPos3+1))             // Codigo Acrescimo e Descrimo
			    nPos5   := at(";",subs(_cTxt,nPos1+nPos2+nPos3+nPos4+1))       // Observacao
				nPos6   := nPos1+nPos2+nPos3+nPos4+nPos5+1  // Valor
	            _dData  := CTOD(Alltrim(Substr(_cTxt, 01,nPos1-1)))
	            _cRot   := Alltrim(Substr(_cTxt,nPos1+1,nPos2-1))     
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
	               //MsgInfo("O codigo "+_cCod+" nใo foi encontrado na tabela de tipos de acresc./decresc. Registro placa-data-Roteiro "+_cPlaca+"-"+DTOC(_dData)+"-"+_cRot,"Aten็ใo")
	               cVar += "O codigo "+_cCod+" nใo foi encontrado na tabela de tipos de acresc./decresc. Registro placa-data-Roteiro "+_cPlaca+"-"+DTOC(_dData)+"-"+_cRot + chr(13) + chr(10)
	               _nLinha ++   
	               FT_FSkip()
	               loop       &&30/10/13 - Mauricio - MDS TECNOLOGIA - a pedido do Sr. James retirado interrup็ใo da rotina e implementado tratamento para aviso apenas e continuidade em proximo registro
	               //return()  &&rotina interrompida por causa de erro
	            Endif 
	            
	            // *** INICIO VALIDACAO WILL chamado 027710 - Nใo importar mais oleo, agora e controlado pelo CTAPLUS *** //
	            
	            IF ALLTRIM(_cCod) == '55' .OR. ALLTRIM(_cCod) == '58'
	            
	            	cVar += "O Roteiro/Data/Placa/Codigo/Valor("+_cRot+"/"+Dtoc(_dData)+"/"+_cPlaca+"/"+_cCod+"/"+alltrim(STR(_nVal))+") Codigo 55 ou 58 nใo serแ mais importado por essa Rotina, Utilizar o Fechamento de Oleo CTAPLUS (ADLOG016P)." + chr(13) + chr(10)
	            	_nLinha ++   
	                FT_FSkip()
	            	LOOP
	            	
	            ENDIF	
	            
	            // *** FINAL VALIDACAO WILL chamado 027710 - Nใo importar mais oleo, agora e controlado pelo CTAPLUS *** //
	            
	            &&novo tratamento conforme entendimento em 16/10/13 passando pela tabela SZK            
	            DbSelectArea("SZK")
	            DbSetOrder(9)
	            If dbseek(xFilial("SZK")+_cPlaca+dtos(_dData)+_cRot)
	               _cPLACAPG := SZK->ZK_PLACAPG 
	               _dDTENTR  := SZK->ZK_DTENTR  
	               _cROTEIRO := SZK->ZK_ROTEIRO 
	               _cTPFRETE := SZK->ZK_TPFRETE 
	               _cGuia    := SZK->ZK_GUIA 
	                      
	               &&Mauricio - MDS Tecnologia - 18/12/13 - Conforme solicitado por Sr. James retirado exigencia de guia em fun็ใo faturamento EDATA.
	               /*
	               If Empty(_cGuia)
		              MSGBOX(" ROTEIRO SEM GUIA DE PESAGEM, LANวAR EM OUTRO ROTEIRO ")
		              _nLinha ++   
	                  FT_FSkip()
	                  loop       &&30/10/13 - Mauricio - MDS TECNOLOGIA - a pedido do Sr. James retirado interrup็ใo da rotina e implementado tratamento para aviso apenas e continuidade em proximo registro
		              //Return()
	               Endif
	               */                              
	               &&Mauricio - 18/10/13 - conforme verificado com James, sempre sera incluido uma acrescimo/descrescimo e nใo mais alterar
	               &&algum ja incluido. Rotina s๓ tratara inclusใo.
	               dbSelectArea("SZI")
	               dbSetOrder(4) 
	               IF dbSeek(xFilial("SZI")+SZK->ZK_PLACAPG+DTOS(SZK->ZK_DTENTR)+SZK->ZK_ROTEIRO)
		              _cSeq := ""
		              _lSegue := .T.
		              	              	              	             	              	              
	                  While SZI->(!Eof()) .and. SZI->ZI_FILIAL  ==  xFilial("SZI") .and.;
			                SZI->ZI_PLACA  ==  SZK->ZK_PLACAPG .and.;
			                DTOS(SZI->ZI_DATALAN) == DTOS(SZK->ZK_DTENTR) .and.;
			                SZI->ZI_ROTEIRO = SZK->ZK_ROTEIRO
			                
			                &&Mauricio - 30/10/13 - Sr. James solicitou validar se ja existe placa/data/roteiro/codigo/valor ja lan็ado. Em havendo pula
		                    &&lan็amento. Sendo o valor diferente aceita o lan็amento.
			                If _cCod == SZI->ZI_CODIGO .And. _nVal == SZI->ZI_VALOR
			                   _lSegue := .F.		                		                
			                Endif
			
			                _nSeq := Val(SZI->ZI_SEQ)
			                   		                
			                SZI->(dbSkip())
			          Enddo
			            
			          If !_lSegue
			             //MsgInfo("O Roteiro/Data/Placa/Codigo/Valor("+_cRot+"/"+Dtoc(_dData)+"/"+_cPlaca+"/"+_cCod+"/"+alltrim(STR(_nVal))+") ja existe lan็ado.","Aten็ใo")		          		          
			             cVar += "O Roteiro/Data/Placa/Codigo/Valor("+_cRot+"/"+Dtoc(_dData)+"/"+_cPlaca+"/"+_cCod+"/"+alltrim(STR(_nVal))+") ja existe lan็ado." + chr(13) + chr(10)
			             _nLinha ++   
	                     FT_FSkip()
	                     loop		          
			          Endif
			          
			          _nSeq += 1
			          _cFile := GetSX8NUM("SZI","ZI_DOC")
	                  Reclock("SZI",.T.)	
					  SZI->ZI_FILIAL := FWxFilial("SZI")
	                  SZI->ZI_DOC  := _cFile
				      SZI->ZI_SEQ  := STRZERO(_nSeq,2)
			     	  SZI->ZI_DATALAN  := SZK->ZK_DTENTR    
				      SZI->ZI_PLACA    := SZK->ZK_PLACAPG
			    	  SZI->ZI_FORNEC   := SZK->ZK_FORNEC
				      SZI->ZI_LOJA     := SZK->ZK_LOJA
				      SZI->ZI_NOMFOR   := SZK->ZK_NOMFOR
				      SZI->ZI_ROTEIRO  := SZK->ZK_ROTEIRO  
				      SZI->ZI_GUIA     := SZK->ZK_GUIA 
				      SZI->ZI_DATAROT  := SZK->ZK_DTENTR    
			          SZI->ZI_CODIGO   := _cCod
	                  SZI->ZI_TIPO     := _ctipo
	                  SZI->ZI_DESCRIC  := _cDesc
	                  SZI->ZI_OBS      := _cObs
	                  SZI->ZI_VALOR    := _nVal  		                
			          SZI->(MsUnlock())		    			
				      ConfirmSX8()
				      		          		          		                 
	               Else        &&sem registros anteriores na tabela SZI
	               
	                  _cFile := GetSX8NUM("SZI","ZI_DOC")
	                  Reclock("SZI",.T.)	
					  SZI->ZI_FILIAL := FWxFilial("SZI")
	                  SZI->ZI_DOC  := _cFile
				      SZI->ZI_SEQ  := STRZERO(1,2)
			     	  SZI->ZI_DATALAN  := SZK->ZK_DTENTR    
				      SZI->ZI_PLACA    := SZK->ZK_PLACAPG
			    	  SZI->ZI_FORNEC   := SZK->ZK_FORNEC
				      SZI->ZI_LOJA     := SZK->ZK_LOJA
				      SZI->ZI_NOMFOR   := SZK->ZK_NOMFOR
				      SZI->ZI_ROTEIRO  := SZK->ZK_ROTEIRO  
				      SZI->ZI_GUIA     := SZK->ZK_GUIA 
				      SZI->ZI_DATAROT  := SZK->ZK_DTENTR    
			          SZI->ZI_CODIGO   := _cCod
	                  SZI->ZI_TIPO     := _ctipo
	                  SZI->ZI_DESCRIC  := _cDesc
	                  SZI->ZI_OBS      := _cObs
	                  SZI->ZI_VALOR    := _nVal  		                
			          SZI->(MsUnlock())		    			
				      ConfirmSX8()
				      
	               Endif               
	            Else
	               
	               //MsgInfo("Nใo encontrado Roteiro/Data/Placa("+_cRot+"/"+Dtoc(_dData)+"/"+_cPlaca+") no controle de fretes","Aten็ใo")
	               cVar += "Nใo encontrado Roteiro/Data/Placa("+_cRot+"/"+Dtoc(_dData)+"/"+_cPlaca+") no controle de fretes" + chr(13) + chr(10)
	               _nLinha ++   
	               FT_FSkip()
	               loop       &&30/10/13 - Mauricio - MDS TECNOLOGIA - a pedido do Sr. James retirado interrup็ใo da rotina e implementado tratamento para aviso apenas e continuidade em proximo registro
	               //Return()               
	            Endif                                              
	         Endif
	      Endif   
	      _nLinha ++   
	      FT_FSkip()   
	
	Enddo     
	
	FT_FUse()
	
	// *********************** INICIO DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
	//cria um txt e abre ele com as informacoes erradas
	nHdl    := fCreate(cPath) //Cria Arquivo para grava็ใo das etiquetas
	Set Century OFF
    If fWrite(nHdl,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
    	If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
        	fClose(nHdl)
            Return
        Endif
    Endif
	fClose(nHdl) 
	
	shellExecute( "Open", "C:\Windows\System32\notepad.exe", cPath, "C:\", 1 )
	
	// *********************** FINAL DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
         
Return( NIL )
