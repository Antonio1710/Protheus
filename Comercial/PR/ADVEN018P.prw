#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FILEIO.CH"      
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADVEN018P บAutor  ณWILLIAM COSTA       บ Data ณ  04/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IMPORTACAO DE TXT DE CEPs PARRA A TABELA CC2 DO PROTHEUS   บฑฑ
ฑฑบ          ณ IMPORTACAO DE COD DE IBGE                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AD'oro - Solicitado Sr. VAGNER CORREIA                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADVEN018P()
    
	Private cFile
	Private aFile
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'IMPORTACAO DE TXT DE CEPs PARRA A TABELA CC2 DO PROTHEUS IMPORTACAO DE COD DE IBGE')
	                                
	cFile := cGetFile( "Lista Arquivos TXT|*.TXT|Lista Arquivos TXT|*.txt",OemToAnsi("Abrir arquivo..."),,,.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
	
	If ! Empty( cFile )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + cFile ) )
	
	      aFile := Directory( cFile )
	     
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	
	End

Return( NIL )

Static Function ProcFile()   

	Local cLF          := Chr( 10 )
	Local cTxt         := ''
	Local cChr         := ''
	Local nTam         := 0
	PRIVATE cUF        := ''
	PRIVATE cCidade    := ''
	PRIVATE cBairro    := ''
	PRIVATE cCEP       := ''
	PRIVATE cNomeLog   := ''
	PRIVATE cIBGE      := ''
	PRIVATE nLinha     := 1
	PRIVATE cArq       := CriaTrab(,.F.)+".TXT" //Nome do Arquivo a Gerar
	PRIVATE cPath      := GetTempPath() + cArq //Local de Gera็ใo do Arquivo
	Private nHdl       
	Private cVar       := ''   
	
	FT_FUse( cFile ) 
	nTam += FT_FlastRec()
	nTam ++
	FT_FGoTop()
	ProcRegua( nTam )
	
	&&campos     12
	&&placa      12
	&&data       12
	&&Roteiro    12
	&&codigo     12
	&&observacao 50
	&&valor      12
	
		While ! ( FT_FEof() )
	
		IncProc( 'Aguarde, importando registros..' )
		cTxt :=  FT_FReadLN()
	      
	    IF cTxt <> '#' 
     
            // ****************WESLEY****** INICIO DA ALTERACAO PARA CSV CHAMADO N 023226 - WILLIAM COSTA ************** /
           	IF nLinha > 1 
           	
			    cUF      := UPPER(Alltrim(Substr(cTxt,4,2)))     
	            cCidade  := UPPER(NOACENTO2(Alltrim(Substr(cTxt,020,072))))     
	            cCEP     := Alltrim(Substr(cTxt,92,8))
	            cIBGE    := Alltrim(Substr(cTxt,157,5))
	               
	            dbSelectArea("CC2")
	            dbSetOrder(1) 
	            IF !(dbSeek(xFilial("CC2")+cUF+cIBGE,.T.))
	            
	                        
		            Reclock("CC2",.T.)
		              	
			            CC2->CC2_EST    := UPPER(cUF)    
					    CC2->CC2_CODMUN := UPPER(cIBGE) 
					    CC2->CC2_MUN    := UPPER(cCidade) 
					    CC2->CC2_XREGIA := UPPER(cUF) + '01'
				    
			        CC2->(MsUnlock())		    			
				      		      		         		          		                 
	            ENDIF               
	        ENDIF
	    EndIF
   		
   		nLinha ++   
	    FT_FSkip()       
	ENDDO
	FT_FUse()
	

	fClose(nHdl) 
Return( NIL )                              

STATIC FUNCTION NoAcento2(cString)
	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
	Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
	Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
	Local cCrase := "เ่์๒๙"+"ภศฬาู" 
	Local cTio   := "ใ๕รี"
	Local cCecid := "็ว"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf		
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf		
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	
	If cMaior$ cString 
		cString := strTran( cString, cMaior, "" ) 
	EndIf
	If cMenor$ cString 
		cString := strTran( cString, cMenor, "" )
	EndIf
	
	cString := StrTran( cString, CRLF, " " )
	
	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
	//Especifico Adoro devido a erro XML nใo solucionado versao 3.10
	cString := StrTran(cString,"&","e")
Return cString

