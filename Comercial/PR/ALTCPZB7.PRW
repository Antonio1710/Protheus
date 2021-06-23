#INCLUDE "Protheus.ch"
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ALTCPZB7  ³ Autor ³ WILLIAM COSTA        ³ Data ³ 19/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua leitura de arquivo TXT e altera campos na ZB7       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Obs.: Este programa assume que todas as linhas do arquivo texto sao do mesmo
tamanho, ou seja, padronizadas. Se o arquivo nao conter todos as linhas
do mesmo tamanho, o arquivo pode estar danificado.
/*/

User Function ALTCPZB7() 

	Local aCombo1       := {}
	Local cCombo1       := Space(2)
	Local oCombo1       := Nil
	Local aCombo2       := {}
	Local cCombo2       := Space(2)
	Local oCombo2       := Nil
	Local _cVar         := Space(15)
	Private nCombo1     := 1
	Private nCombo2     := 1
	Private cCod        := ''
	Private cCodBarDe   := ''
	Private cCodBarPara := ''
	Private nPos1       := 0
	Private nPos2       := 0
	Private nEspaceCod  := 0
	Private nEspaceBar  := 0
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Efetua leitura de arquivo TXT e altera campos na ZB7')
	
	aAdd( aCombo1, "01 - Cod Barras Para" )
	aAdd( aCombo2, "01 - Por Rede" )
	aAdd( aCombo2, "02 - Por Codigo de Cliente" )
	
	nTamLin  := 23 
	_cArq    := space(40)      
	nHdl     := NIL             
	cBuffer  := Space(nTamLin+1) 
	nBytes   := 0                
	cFileLog := ""
	_cPath   := ""
	nOpc     := 0
	cChar    := ' '
	nQtChar  := 2
	  
	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera dados dos Codigos de Barras EDI contidos no arquivo texto") From 100,0 To 245,575 PIXEL
	
		@ 03,020 SAY      "Arquivo TXT:"	                SIZE 030,007      OF _oDlg PIXEL
		@ 03,100 MSGet    oArq    VAR _cArq                 SIZE 100,10       OF _oDlg PIXEL
		@ 18,020 SAY      "Escolha campo p/alterar : "                        OF _oDlg PIXEL
		@ 18,100 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 PIXEL OF _oDlg on change nCombo1 := oCombo1:nAt
		@ 33,020 SAY      "Escolha Tipo da Busca : "                        OF _oDlg PIXEL
		@ 33,100 COMBOBOX oCombo2 VAR cCombo2 ITEMS aCombo2 SIZE 100,10 PIXEL OF _oDlg on change nCombo2 := oCombo2:nAt
		@ 48,020 SAY      "Atualiza cadastro (S/N)? "	    SIZE 200,007      OF _oDlg PIXEL
		@ 48,100 MSGet    ochar   VAR cChar                 SIZE 030,10       OF _oDlg PIXEL
		
		DEFINE SBUTTON FROM 55,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
		DEFINE SBUTTON FROM 55,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL
	
	ACTIVATE MSDIALOG  _oDlg CENTERED
	
	if nOpc <> 1
		return()
	endif
	
	AutoGrLog("LOG DE ALTERACAO DO CADASTRO DE Codigo de Barras - Tabela ZB7")
	AutoGrLog("-------------------------------------------------------------")
	AutoGrLog(" ")
	AutoGrLog(" ")
	lArqOK := .t.
	
	_cNomCpo := ""
	
	&&definiçao conforme campo escolhido
	IF nCombo2 == 1
	
	   nTamLin  := 35            &&definido com vagner 6 caracteres
	   _cNomCpo := "REDE" 
	     
	 
	ELSE   
	
		nTamLin  := 33            &&definido com vagner 6 caracteres
	   _cNomCpo := "CLIENTE" 
	   
	Endif      
	
	nHdl := fOpen(_cArq,2) 
	
	If nHdl == -1
		AutoGrLog("NAO FOI POSSIVEL ABRIR O ARQUIVO "+_cArq)
		lArqOK := .f.
	else
		nlin := 1
	
		nBytes := fRead(nHdl,@cBuffer,nTamLin) // Le uma linha
		
		While nBytes == nTamLin
		                                 
		   	nPos1       := at(";",cBuffer)
			nPos2       := at(";",subs(cBuffer,nPos1+1))
			cCod        := Substring(cBuffer,01,nPos1-1)
			cCodBarDe   := Substring(cBuffer,nPos1+1,nPos2-1)
			cCodBarPara := Substring(cBuffer,nPos1+nPos2+1,len(cBuffer))    
			
			IF LEN(cCod) < 6
		
				nEspaceCod  := 6 - LEN(cCod)
				
			ENDIF	
			
			IF LEN(cCodBarDe) < 14
		
				nEspaceBar  := 14 - LEN(cCodBarDe)
				
			ENDIF	
	 		
			
			IF _cNomCpo == "REDE"
			
				&&atualiza ZB7
				dbselectarea("ZB7")
				dbsetorder(3)
				
				if !dbseek(xfilial("ZB7") + cCod + SPACE(nEspaceCod) + cCodBarDe + SPACE(nEspaceBar), .T.)
				
					AutoGrLog("Linha "+strzero(nlin,5)+" Cod Rede ou Cliente "+cCod+ " CodBarDe: "+ cCodBarDe + " nao encontrado na ZB7.")
					lArqOk := .f.
					
				else
				                  
				    if cChar = 'S'	
			       
				   		if Reclock("ZB7",.F.)                                                                                               
				   		
							AutoGrLog("Linha "+strzero(nlin,5)+" Cod Rede "+cCod+ " CodBarDe: "+ cCodBarDe + " Alterado campo Cod Barras Para na ZB7, de: "+CVALTOCHAR(ZB7->ZB7_CODPAR)+" para: "+ CVALTOCHAR(cCodBarPara))
							ZB7->ZB7_CODPAR  := cCodBarPara
						 	Msunlock()
						 
					    endif
				    EndIf	         
				
				    lArqOk := .F.
					
				ENDIF
			
			ELSE     
			
				&&atualiza ZB7
				dbselectarea("ZB7")
				dbsetorder(4)
				
				if !dbseek(xfilial("ZB7") + cCod + cCodBarDe)
				
					AutoGrLog("Linha "+strzero(nlin,5)+" Cod Rede ou Cliente "+cCod+ " CodBarDe: "+ cCodBarDe + " nao encontrado na ZB7.")
					lArqOk := .f.
					
				else
				                  
				    if cChar = 'S'	
			       
				   		if Reclock("ZB7",.F.)                                                                                               
				   		
							AutoGrLog("Linha "+strzero(nlin,5)+" Cod Cliente "+cCod+ " CodBarDe: "+ cCodBarDe + " Alterado campo Cod Barras Para na ZB7, de: "+CVALTOCHAR(ZB7->ZB7_CODPAR)+" para: "+ CVALTOCHAR(cCodBarPara))
							ZB7->ZB7_CODPAR  := cCodBarPara
						 	Msunlock()
						 
					    endif
				    EndIf	         
				
				    lArqOk := .F.
					
				ENDIF
			ENDIF
			nBytes := fRead(nHdl,@cBuffer,nTamLin) // Le uma linha
			nLin++
			
		enddo
	endif
	
	_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
	_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
	_cPath    := Substr(_cArq,1,RAt("\",_cArq))
	
	MostraErro(_cPath,_cFileLog)
	Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )
	
	If nHdl <> -1
		fClose(nHdl) // Fecha o arquivo
	endif

Return()
