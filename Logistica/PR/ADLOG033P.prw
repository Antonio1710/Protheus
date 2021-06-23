#Include "PROTHEUS.CH"  
#INCLUDE 'FILEIO.CH'
#INCLUDE 'TopConn.CH'  
#INCLUDE "rwmake.ch"


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADLOG033P ºAutor  ³William Costa       º Data ³  07/06/2017 º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Programa de importacao de uma planilha em csv para levar    º±±
//±±º          ³ao Cadastro de Cliente do Protheus os seguintes campos      º±±
//±±º          ³do cadastro de clientes HORA INICIAL MANHA, HORA FINAL MANHAº±±
//±±º          ³HORA INCIAL TARDE, HORA FINAL TARDE, LONGITUDE, LATITUDE    º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºALTERACAO ³051327 || OS 052641 || ADM || MARCOS || 8505 || RAVEX       º±±
//±±º          ³Identificado que existe importacao que esta subindo latitudeº±±
//±±º          ³e longitude errada foi feito um elseif para verificar se a  º±±
//±±º          ³primeira posicao dos campos de latitude e longitude e um -  º±±
//±±º          ³significa que ele é menor que zero e nao vai gerar erro no  º±±
//±±º          ³ravex - William Costa 27/08/2019                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºALTERACAO ³052423 || OS 053772 || ADM || || 11994455580 || ROTEIRO     º±±
//±±º          ³RAVEX - Adicionado novas travas para parar os erros de      º±±
//±±º          ³latitude e longitude                                        º±±
//±±º          ³ravex - William Costa 09/10/2019                            º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ SIGAFAT                                                    º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


/*BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³LAYOUT DE IMPORTACAO³
//³                    ³
//³Cliente             ³
//³Loja                ³
//³HOR INI MANHA       ³
//³MIN INI MANHA       ³
//³HOR FIN MANHA       ³
//³MIN FIN MANHA       ³
//³HOR INI TARDE       ³
//³MIN INI TARDE       ³
//³HOR FIN TARDE       ³
//³MIN FIN TARDE       ³
//³LONGITUDE           ³
//³LATITUDE            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
ENDDOC*/

User Function ADLOG033P()

	Private cTxt        := ""
	Private cFileOpen   := ""
	Private cTitulo1    := "Selecione o arquivo"
	Private cExtens	  := "Arquivo CSV | *.csv" 
	Private nLinha      := 1
	Private nPos1       := 0
	Private nPos2       := 0
	Private nPos3       := 0
	Private nPos4       := 0
	Private nPos5       := 0
	Private nPos6       := 0
	Private nPos7       := 0
	Private nPos8       := 0
	Private nPos9       := 0
	Private nPos10      := 0
	Private nPos11      := 0
	Private nPos12      := 0
	Private cCliente    := ''
	Private cLoja       := ''
	Private cHrIniManha := ''
	Private cMnIniManha := ''
	Private cHrFinManha := ''
	Private cMnFinManha := ''
	Private cHrIniTarde := ''
	Private cMnIniTarde := ''
	Private cHrFinTarde := ''
	Private cMnFinTarde := ''
    Private cLongitude  := ''	
	Private cLatitude   := ''	  
	Private cMsgSucesso := ''
	Private cMsgErro    := ''   
	Private cPath       := 'C:\temp\resumoimporthoras.csv' //Local de Geração do Arquivo
	Private nHdl        := NIL 
	Private cVar        := '' 
	Private lAchouSa1   := .F.
	Private lAchouPB3   := .F.	
	Private nTotStr1    := 0
	Private nTotStr2    := 0
	Private lOk         := .T.

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de importacao de uma planilha em csv para levar ao Cadastro de Cliente do Protheus os seguintes campos do cadastro de clientes HORA INICIAL MANHA, HORA FINAL MANHA HORA INCIAL TARDE, HORA FINAL TARDE, LONGITUDE, LATITUDE')
	
	cFileOpen := cGetFile(cExtens,cTitulo1,2,,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
	
	If !File(cFileOpen)
		MsgAlert("Arquivo texto: "+cFileOpen+" não Localizado",'ADLOG033P')
		Return(.F.)
	EndIf       
	
	If !Empty( cFileOpen )
	
	   If ( MsgNoYes( "Confirma importacao do arquivo " + cFileOpen ) )
	
	      Processa( { || ProcFile("Analisando arquivo!!!") } )
	     
	   End
	End

Return( NIL )

Static Function ProcFile()
	
	FT_FUSE(cFileOpen)   //ABRIR
	FT_FGOTOP()          //PONTO NO TOPO
	ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER
	
	While !FT_FEOF()  //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		
		IncProc('Aguarde, importando registros...')
		
		// Capturar dados
		cTxt    := FT_FREADLN() //LENDO LINHA 
		lAchouSa1   := .F.
	    lAchouPB3   := .F.	
		
		IF nLinha > 1
		
			nPos1  		:= at(";",cTxt)               			                                                    // Cliente
			nPos2  		:= at(";",subs(cTxt,nPos1+1))				                                                // Loja
			nPos3  		:= at(";",subs(cTxt,nPos1+nPos2+1))                                                         // HOR INI MANHA
			nPos4  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+1))                                                   // MIN INI MANHA
			nPos5  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+1))                                             // HOR FIN MANHA
			nPos6  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+1))                                       // MIN FIN MANHA
			nPos7  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+1))                                 // HOR INI TARDE
		   	nPos8  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+1))                           // MIN INI TARDE
			nPos9  		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+1))                     // HOR FIN TARDE
			nPos10 		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+1))               // MIN FIN TARDE
			nPos11 		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+nPos10+1))        // LONGITUDE
			nPos12 		:= at(";",subs(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+nPos10+nPos11+1)) // LATITUDE
			cCliente    := STRZERO(VAL(SUBSTR(cTxt,01,nPos1-1)),6)
		    cLoja       := STRZERO(VAL(SUBSTR(cTxt,nPos1+1,nPos2 - 1)),2)
		    cHrIniManha := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+1,nPos3 - 1)),2)
	 	    cMnIniManha := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+1,nPos4 - 1)),2)
		    cHrFinManha := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+1,nPos5 - 1)),2)
		    cMnFinManha := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+1,nPos6 - 1)),2)
		    cHrIniTarde := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+1,nPos7 - 1)),2)
		    cMnIniTarde := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+1,nPos8 - 1)),2)
		    cHrFinTarde := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+1,nPos9 - 1)),2)
		    cMnFinTarde := STRZERO(VAL(SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+1,nPos10 - 1)),2)
	        cLongitude  := SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+nPos10+1,nPos11 - 1)	
			cLatitude   := SUBSTR(cTxt,nPos1+nPos2+nPos3+nPos4+nPos5+nPos6+nPos7+nPos8+nPos9+nPos10+nPos11+1,LEN(cTxt))	
			lOk         := .T.
			// *** INICIO WILIAM COSTA 27/08/2019 - 052423 || OS 053772 || ADM || || 11994455580 || ROTEIRO RAVEX

			//busca se não tem nenhumponto . não pode
			nTotStr1 := 0
			nTotStr2 := 0
			nTotStr1 := ContaString(cLongitude, ".", .F.)
			nTotStr2 := ContaString(cLatitude, ".", .F.)

			IF nTotStr1 == 0 .OR. ;
			   nTotStr2 == 0

			   cMsgErro += cCliente + ';' + cLoja + ';' + ' Latitude ou longitude não tem o caracter "." não pode, favor verificar' + CHR(13) + CHR(10)
				lOk     := .F.	

			ENDIF   

			//busca mais que um ponto . não pode
			nTotStr1 := 0
			nTotStr2 := 0
			nTotStr1 := ContaString(cLongitude, ".", .F.)
			nTotStr2 := ContaString(cLatitude, ".", .F.)

			IF nTotStr1 >= 2 .OR. ;
			   nTotStr2 >= 2

			   cMsgErro += cCliente + ';' + cLoja + ';' + ' Latitude ou longitude tem duas vezes o caracter "." não pode, favor verificar' + CHR(13) + CHR(10)
			   lOk     := .F.

			ENDIF   

			//busca por ponto e virgula ; não pode
			nTotStr1 := 0
			nTotStr2 := 0
			nTotStr1 := ContaString(cLongitude, ";", .F.)
			nTotStr2 := ContaString(cLatitude, ";", .F.)

			IF nTotStr1 >= 1 .OR. ;
			   nTotStr2 >= 1

			   cMsgErro += cCliente + ';' + cLoja + ';' + ' Latitude ou longitude tem o caracter ponto e virgula não pode, favor verificar' + CHR(13) + CHR(10)
			   lOk     := .F.

			ENDIF   
			
			nTotStr1 := 0
			nTotStr2 := 0

			// *** FINAL WILIAM COSTA 27/08/2019 - 052423 || OS 053772 || ADM || || 11994455580 || ROTEIRO RAVEX
			IF lOk == .T.
		    
				IF cHrIniManha == '00' .OR. ;
				cHrFinManha == '00' .OR. ;
				cHrIniTarde == '00' .OR. ; 
				cHrFinTarde == '00'   
				
					cMsgErro += cCliente + ';' + cLoja + ';' + ' Erro no campo de Hora não pode ser zero' + CHR(13) + CHR(10)
				
				// *** INICIO WILIAM COSTA 27/08/2019 - 051327 || OS 052641 || ADM || MARCOS || 8505 || RAVEX
					
				ELSEIF SUBSTR(cLongitude,1,1) <> "-" .OR. ;
					   SUBSTR(cLatitude,1,1)  <> "-" 
				
					cMsgErro += cCliente + ';' + cLoja + ';' + ' Erro no campo de Latitude ou Longitude, nao pode ser maior que zero' + CHR(13) + CHR(10)
					
				// *** FINAL WILIAM COSTA 27/08/2019 - 051327 || OS 052641 || ADM || MARCOS || 8505 || RAVEX
				
				// *** INICIO WILIAM COSTA 27/08/2019 - 052423 || OS 053772 || ADM || || 11994455580 || ROTEIRO RAVEX
					
				ELSEIF VAL(cLongitude) < -99 .OR. ;
					   VAL(cLatitude)  < -99
				
					cMsgErro += cCliente + ';' + cLoja + ';' + ' Erro no campo de Latitude ou Longitude, nao pode ser menor que - 99' + CHR(13) + CHR(10)
					
				// *** FINAL WILIAM COSTA 27/08/2019 -052423 || OS 053772 || ADM || || 11994455580 || ROTEIRO RAVEX
					
				ELSE
							
					DBSELECTAREA("SA1")
					DbSetOrder(1)
						
					IF SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))
					
						RecLock("SA1",.F.)              
						
							SA1->A1_HRINIM	:= cHrIniManha + ':' + cMnIniManha
							SA1->A1_HRFINM	:= cHrFinManha + ':' + cMnFinManha
							SA1->A1_HRINIT	:= cHrIniTarde + ':' + cMnIniTarde
							SA1->A1_HRFINT	:= cHrFinTarde + ':' + cMnFinTarde
							SA1->A1_XLONGIT	:= cLongitude					
							SA1->A1_XLATITU	:= cLatitude
								
						MsUnlock()	 
						
						lAchouSa1 := .T.
						
					ENDIF		
						
					DBCLOSEAREA("SA1")
					
					DBSELECTAREA("PB3")
					DbSetOrder(11)
						
					IF PB3->(DbSeek(xFilial("PB3")+cCliente+cLoja))
						RecLock("PB3",.F.)              
						
							PB3->PB3_HRINIM	:= cHrIniManha + ':' + cMnIniManha
							PB3->PB3_HRFINM	:= cHrFinManha + ':' + cMnFinManha
							PB3->PB3_HRINIT	:= cHrIniTarde + ':' + cMnIniTarde
							PB3->PB3_HRFINT	:= cHrFinTarde + ':' + cMnFinTarde
							PB3->PB3_XLONGI	:= cLongitude					
							PB3->PB3_XLATIT	:= cLatitude
								
						MsUnlock()	   
						
						lAchouPB3 := .T.	
					
					ENDIF		
						
					DBCLOSEAREA("PB3")
					
					//se encontrou o cliente
					IF lAchouSa1 == .T. 
					
						cMsgSucesso += cCliente + ';' + cLoja + ';' + 'Sucesso' +  CHR(13) + CHR(10)
						
					ELSE
					
						cMsgErro += cCliente + ';' + cLoja + ';' + ' Erro Cliente nao Encontrado ' + CHR(13) + CHR(10)	  
					
					ENDIF
				ENDIF
			ENDIF	
		ENDIF
		
		nLinha:= nLinha + 1
			
		FT_FSKIP()   //proximo registro no arquivo txt
		
	EndDo
	
	FT_FUSE() //fecha o arquivo txt
	
	cVar := 'Clientes;Loja;Status' + CHR(13) + CHR(10)
	cVar += cMsgSucesso            
	cVar += cMsgErro                  
	
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
		
		MsAguarde({||shellExecute("Open", cPath, "NULL", "C:\",3)},"Aguarde","Abrindo relatório...")
		
	ENDIF

Return(NIL)

STATIC FUNCTION ContaString(cPalavra, cCaracter, lMaiusculo)

    Local nTotal      := 0
    Local nAtual      := 0
    Default cPalavra  := ""
    Default cCaracter := ""
     
    //Se transforma tudo em maiusculo
    If lMaiusculo
        cPalavra  := Upper(cPalavra)
        cCaracter := Upper(cCaracter)
    EndIf
     
    //Percorre todas as letras da palavra
    For nAtual := 1 To Len(cPalavra)
        //Se a posição atual for igual ao caracter procurado, incrementa o valor
        If SubStr(cPalavra, nAtual, 1) == cCaracter
            nTotal++
        EndIf
    Next
    
Return nTotal