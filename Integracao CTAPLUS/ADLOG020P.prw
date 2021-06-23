#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ADLOG020P ºAutor  ³ WILLIAM COSTA      º Data ³  22/06/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Importacao CSV META Ravex por Veiculo                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAFAT                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

//BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LAYOUT DE IMPORTACAO     ³
//³                         ³
//³ARQUIVO CSV              ³
//³                         ³
//³CAMPOS:                  ³
//³PLACA                    ³
//³VALOR EM PORCENTAGEM META³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ENDDOC

User Function ADLOG020P()
    
	Private cFile
	Private aFile
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao CSV META Ravex por Veiculo')
	                                
	cFile := cGetFile( "Lista Arquivos CSV|*.CSV|Lista Arquivos CSV|*.CSV",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + cFile ) )
	
	      aFile := Directory( cFile )
	     
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	
	End

Return( NIL )

Static Function ProcFile()   

	Local cLF      := Chr(10)
	Local cTxt     := ''
	Local cChr     := ''
	Local nTam     := 0
	PRIVATE nLinha := 1
	PRIVATE cArq   := CriaTrab(,.F.)+".CSV" //Nome do Arquivo a Gerar
	PRIVATE cPath  := GetTempPath() + cArq //Local de Geração do Arquivo
	Private nHdl   := NIL 
	Private cVar   := '' 
	Private nPos1  := 0
   	Private nPos2  := 0
	Private cPlaca := ''
    Private cMeta  := ''
    Private nMeta  := 0
    
	FT_FUse(cFile) 
	nTam += FT_FlastRec()
	nTam ++
	FT_FGoTop()
	ProcRegua(nTam)
	
 	While ! (FT_FEof())
	
		IncProc('Aguarde, importando registros..')
		cTxt :=  FT_FReadLN()
		
	    // ************** INICIO DA ALTERACAO PARA CSV - WILLIAM COSTA ************** /
        IF nLinha > 1 
           	
	    	nPos1  := at(";",cTxt) // Placa
   	     	cPlaca := Alltrim(Substr(cTxt,1,nPos1-1)) 
            cMeta  := Alltrim(Substr(cTxt,nPos1+1,LEN(cTxt)))
            nMeta  := VAL(cMeta)
            
            dbSelectArea("ZV4")
            dbSetOrder(1) 
            IF (dbSeek(xFilial("ZV4")+cPlaca,.T.))
            
                Reclock("ZV4",.F.)     
	            
		            ZV4->ZV4_META := nMeta
		            
	              	
		        ZV4->(MsUnlock())		    			
		    
		    ELSE
		    
		    	cVar += "A Placa não foi encontrado na tabela de Veiculos = " + cPlaca + chr(13) + chr(10)    
			      		      		         		          		                 
            ENDIF
            ZV4->(dbCloseArea()) 
            
        ENDIF
	    // ************** FINAL DA ALTERACAO PARA CSV - WILLIAM COSTA ************** /
   		nLinha:= nLinha + 1
	    FT_FSkip()       
	ENDDO
	FT_FUse() 
	
	//cria um txt e abre ele com as informacoes erradas
	IF ALLTRIM(cVar) <> ''                            
	
		nHdl    := fCreate(cPath) //Cria Arquivo para gravação das etiquetas
		Set Century OFF
	    If fWrite(nHdl,cVar,Len(cVar)) != Len(cVar) //Gravacao do arquivo
	    	If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
	        	fClose(nHdl)
	            Return
	        Endif
	    Endif
		fClose(nHdl) 
		
		shellExecute( "Open", "C:\Windows\System32\notepad.exe", cPath, "C:\", 1 )
		
	ENDIF
	 
Return( NIL )