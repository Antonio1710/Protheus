#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ADLOG027P �Autor  � WILLIAM COSTA      � Data �  22/06/2016 ���
�������������������������������������������������������������������������͹��
���Descricao �Importacao CSV Rateio de Oleo por Veiculo                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAFAT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
*/ 

//BEGINDOC
//�������������������������Ŀ
//�LAYOUT DE IMPORTACAO     �
//�                         �
//�ARQUIVO CSV              �
//�                         �
//�CAMPOS:                  �
//�PLACA                    �
//�RATEIO DE LITROS S10     �
//�RATEIO DE LITROS S500    �
//���������������������������
//ENDDOC

User Function ADLOG027P()
    
	Private cFile
	Private aFile
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao CSV Rateio de Oleo por Veiculo')
	                                
	cFile := cGetFile( "Lista Arquivos CSV|*.CSV|Lista Arquivos CSV|*.CSV",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + cFile ) )
	
	      aFile := Directory( cFile )
	     
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	
	End

Return( NIL )

Static Function ProcFile()   

	Local cLF        := Chr(10)
	Local cTxt       := ''
	Local cChr       := ''
	Local nTam       := 0
	PRIVATE nLinha   := 1
	PRIVATE cArq     := CriaTrab(,.F.)+".CSV" //Nome do Arquivo a Gerar
	PRIVATE cPath    := GetTempPath() + cArq //Local de Gera��o do Arquivo
	Private nHdl     := NIL 
	Private cVar     := '' 
	Private nPos1    := 0
   	Private nPos2    := 0
   	Private nPos3    := 0
	Private cPlaca   := ''
    Private cRatS10  := ''
    Private nRatS10  := ''
    Private cRatS500 := ''
    Private nRatS500 := 0
    
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
           	
	    	nPos1    := at(";",cTxt)                 // Placa
	    	nPos2    := at(";",Substr(cTxt,nPos1+1)) // Rateio S10
   	     	cPlaca   := Alltrim(Substr(cTxt,1,nPos1-1)) 
   	     	cRatS10  := StrTran(Alltrim(Substr(cTxt,nPos1+1,nPos2-1)) , ',', '.')
   	     	cRatS500 := StrTran(Alltrim(Substr(cTxt,nPos1+nPos2+1,LEN(cTxt))) , ',', '.')
            nRatS10  := VAL(cRatS10)
            nRatS500 := VAL(cRatS500)
              
            dbSelectArea("ZV4")
            dbSetOrder(1) 
            IF (dbSeek(xFilial("ZV4")+cPlaca,.T.))
            
                Reclock("ZV4",.F.)     
	            
		            ZV4->ZV4_RAS10  := nRatS10
		            ZV4->ZV4_RAS500 := nRatS500
		           
		        ZV4->(MsUnlock())		    			
		    
		    ELSE
		    
		    	cVar += "A Placa n�o foi encontrado na tabela de Veiculos = " + cPlaca + chr(13) + chr(10)    
			      		      		         		          		                 
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
	
		nHdl    := fCreate(cPath) //Cria Arquivo para grava��o das etiquetas
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