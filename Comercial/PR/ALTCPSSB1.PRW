#INCLUDE "Protheus.ch"
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ALTCPSB1  ³ Autor ³ WILLIAM COSTA        ³ Data ³ 14/07/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua leitura de arquivo TXT e altera campos na SB1       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Obs.: Este programa assume que todas as linhas do arquivo texto sao do mesmo
tamanho, ou seja, padronizadas. Se o arquivo nao conter todos as linhas
do mesmo tamanho, o arquivo pode estar danificado.
/*/

User Function ALTCPSB1() 

	Local aCombo1  := {}
	Local cCombo1  := Space(2)
	Local oCombo1  := Nil
	Local _cVar    := Space(15)
	
	Private nCombo1 := 1
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Efetua leitura de arquivo TXT e altera campos na SB1')
	
	aAdd( aCombo1, "01-EDI" )
	
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
	  
	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera dados do produtos contidos no arquivo texto") From 100,0 To 225,575 PIXEL
	
		@ 03,020 SAY      "Arquivo TXT:"	                SIZE 030,007      OF _oDlg PIXEL
		@ 03,100 MSGet    oArq    VAR _cArq                 SIZE 100,10       OF _oDlg PIXEL
		@ 18,020 SAY      "Escolha campo p/alterar : "                        OF _oDlg PIXEL
		@ 18,100 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 PIXEL OF _oDlg on change nCombo1 := oCombo1:nAt
		@ 33,020 SAY      "Atualiza cadastro (S/N)? "	    SIZE 200,007      OF _oDlg PIXEL
		@ 33,100 MSGet    ochar   VAR cChar                 SIZE 030,10       OF _oDlg PIXEL
		
		DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
		DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL
	
	ACTIVATE MSDIALOG  _oDlg CENTERED
	
	if nOpc <> 1
		return()
	endif
	
	AutoGrLog("LOG DE ALTERACAO DO CADASTRO DE PRODUTOS")
	AutoGrLog("-------------------------------------")
	AutoGrLog(" ")
	AutoGrLog(" ")
	lArqOK := .t.
	
	_cNomCpo := ""
	
	&&definiçao conforme campo escolhido
	IF nCombo1 == 1
	
	   nTamLin  := 6            &&definido com vagner 6 caracteres
	   _cNomCpo := "EDI"   
	   
	Endif      
	
	nHdl := fOpen(_cArq,2) 
	
	If nHdl == -1
		AutoGrLog("NAO FOI POSSIVEL ABRIR O ARQUIVO "+_cArq)
		lArqOK := .f.
	else
		nlin := 1
	
		nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
		
		While nBytes == nTamLin+nQtChar
		
			_cCod    := Substr(cBuffer,1,6)
			
			&&atualiza SA1
			dbselectarea("SB1")
			dbsetorder(1)
			
			if !dbseek(xfilial("SB1")+_cCod)
			
				AutoGrLog("Linha "+strzero(nlin,5)+" Produto "+_cCod+" nao encontrado na SB1.")
				lArqOk := .f.
				
			else
			                  
			    IF _cNomCpo == "EDI"
			    
			       if cChar = 'S'	
			       
				   		if Reclock("SB1",.f.)
					  
							AutoGrLog("Linha "+strzero(nlin,5)+" Produto "+_cCod+" "+SB1->B1_DESC+" Alterado campo "+_cNomCpo+" na SB1, de: "+CVALTOCHAR(SB1->B1_XEDI)+" para: "+ ".T.")
						 	SB1->B1_XEDI   := .T.
						 	Msunlock()
						 
					    endif
					    
				   ELSE	     
				   
				   		if Reclock("SB1",.f.)
					  
							AutoGrLog("Linha "+strzero(nlin,5)+" Produto "+_cCod+" "+SB1->B1_DESC+" Alterado campo "+_cNomCpo+" na SB1, de: "+CVALTOCHAR(SB1->B1_XEDI)+" para: "+ ".F.")
						 	SB1->B1_XEDI   := .F.
						 	Msunlock()
						 
					    endif
				   endif   
				Endif
				
				lArqOk := .f.
				
			endif						
			
			nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
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
