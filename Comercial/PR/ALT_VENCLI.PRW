#INCLUDE "Protheus.ch"
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ALT_VENCLI³ Autor ³ Adriana               ³ Data ³ 14/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LE TXT E ALTERA COD.VEND.CLIENTE                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Obs.: Este programa assume que todas as linhas do arquivo texto sao do mesmo
tamanho, ou seja, padronizadas. Se o arquivo nao conter todos as linhas
do mesmo tamanho, o arquivo pode estar danificado.
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                               	
//³ Declara variaveis                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

User Function ALT_VENCLI()
Local aCombo1  := {}
Local cCombo1  := Space(2)
Local oCombo1  := Nil
Local _cVar    := Space(15)

Private nCombo1 := 1

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'LE TXT E ALTERA COD.VEND.CLIENTE')

aAdd( aCombo1, "VENDEDOR 1" )
aAdd( aCombo1, "VENDEDOR 2" )



nTamLin := 23 //16             // Tamanho da linha no arquivo texto
_cArq    := space(40)        // Arquivo texto a importar com codigo+loja
nHdl    := NIL              // Handle para abertura do arquivo
cBuffer := Space(nTamLin+1) // Variavel para leitura
nBytes  := 0                // Variavel para verificacao do fim de arquivo
cFileLog := ""
//cPath := GetSrvProfString("StartPath","")+"LOG\"
_cPath := ""
nOpc := 0
cChar := ' '
nQtChar := 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos iniciais...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera Cliente/PB3 com vendedores 1 ou 2 vindos do arquivo txt") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Arquivo TXT:"	SIZE 030,007 OF _oDlg PIXEL
@ 10,20 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
@ 29,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 29,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if nOpc <> 1
	//cArq    := GetSrvProfString("StartPath","")+"LOG\"+ALLTRIM(_carq)      // Arquivo texto a importar
//Else
	return
endif
*/

DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera Cliente/PB3 com vendedores 1 ou 2 vindos do arquivo txt") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Arquivo TXT:"	SIZE 030,007 OF _oDlg PIXEL
@ 03,100 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
@ 18,20 SAY "Escolha campo p/alterar : " OF _oDlg PIXEL
@ 18,100 COMBOBOX oCombo1 VAR cCombo1 ITEMS aCombo1 SIZE 100,10 PIXEL OF _oDlg on change nCombo1 := oCombo1:nAt
@ 33,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 33,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if nOpc <> 1
	return()
endif


AutoGrLog("LOG ALTERACAO VENDEDOR DE CLIENTES")
AutoGrLog("-------------------------------------")
AutoGrLog(" ")
AutoGrLog(" ")
lArqOK := .t.

nHdl := fOpen(_cArq,2) // Abre o arquivo
If nHdl == -1
	AutoGrLog("NAO FOI POSSIVEL ABRIR O ARQUIVO "+_cArq)
	lArqOK := .f.
else
	IF nCombo1 == 1  &&Vendedor 1
		nlin := 1
		//valida informacoes do arquivo
		nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
		While nBytes == nTamLin+nQtChar
			_cCod    := Substr(cBuffer,1,6)
			_cLoja   := Substr(cBuffer,8,2)
			
			dbselectarea("SA1")
			dbsetorder(1)
			if !dbseek(xfilial("SA1")+_cCod+_cLoja)
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na SA1.")
				lArqOk := .f.
			else
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+"  VEND1 DE: "+A1_VEND+" na PB3")
				
				cVend    := Substr(cBuffer,11,6)
				cIDVend  := Substr(cBuffer,18,6)
				
				&&Mauricio - 11/04/17 - chamado 035183
   				dbSelectArea("ZBE")
	            RecLock("ZBE",.T.)
		          Replace ZBE_FILIAL 	WITH xFilial("ZBE")
		          Replace ZBE_DATA 	   	WITH dDataBase
		          Replace ZBE_HORA 	   	WITH TIME()
		          Replace ZBE_USUARI	WITH UPPER(Alltrim(cUserName))
		          Replace ZBE_LOG	    WITH ("CAMPO A1_VEND DE " + SA1->A1_VEND + " PARA "+ cVend)  
		          Replace ZBE_MODULO	WITH "SA1"
		          Replace ZBE_ROTINA	WITH "ALT_VENCLI"
		          Replace ZBE_PARAME	WITH "CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA
	            ZBE->(MsUnlock())
								
				if cChar = 'S'
					if Reclock("SA1",.f.)
						SA1->A1_VEND   := cVend
						Msunlock()
					endif
					
				endif
				
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+" VEND1 PARA: "+cvend+" na SA1")
				lArqOk := .f.
			endif
			
			
			// Atualiza a PB3  Alex Borges 28/06/2012
			dbselectarea("PB3")
			dbsetorder(11)
			if !dbseek(xfilial("PB3")+_cCod+_cLoja)
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
				lArqOk := .f.
			else
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3_NOME+"  VEND1 DE: "+PB3_VEND+" na PB3")
				
				cVend    := Substr(cBuffer,11,6)
				cIDVend  := Substr(cBuffer,18,6)
				
				if cChar = 'S'
					if Reclock("PB3",.f.)
						PB3->PB3_VEND     := cIDVend  //Id do vendedor
						PB3->PB3_CODVEN   := cVend	  //Codigo do vendedor
						Msunlock()
					endif
					
				endif
				
				//AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+" PARA: "+cvend+"na PB3")
				lArqOk := .f.
			endif
			nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
			nLin++
		end
	Else   && vendedor 2
		nlin := 1
		//valida informacoes do arquivo
		nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
		While nBytes == nTamLin+nQtChar
			_cCod    := Substr(cBuffer,1,6)
			_cLoja   := Substr(cBuffer,8,2)
			
			dbselectarea("SA1")
			dbsetorder(1)
			if !dbseek(xfilial("SA1")+_cCod+_cLoja)
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na SA1.")
				lArqOk := .f.
			else
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+"  VEND2 DE: "+A1_XVEND2+" na PB3")
				
				cVend    := Substr(cBuffer,11,6)
				cIDVend  := Substr(cBuffer,18,6)
				
				&&Mauricio - 11/04/17 - chamado 035183
   				dbSelectArea("ZBE")
	            RecLock("ZBE",.T.)
		          Replace ZBE_FILIAL 	WITH xFilial("ZBE")
		          Replace ZBE_DATA 	   	WITH dDataBase
		          Replace ZBE_HORA 	   	WITH TIME()
		          Replace ZBE_USUARI	WITH UPPER(Alltrim(cUserName))
		          Replace ZBE_LOG	    WITH ("CAMPO A1_XVEND2 DE " + SA1->A1_XVEND2 + " PARA "+ cVend)  
		          Replace ZBE_MODULO	WITH "SA1"
		          Replace ZBE_ROTINA	WITH "ALT_VENCLI"
		          Replace ZBE_PARAME	WITH "CLIENTE: " + SA1->A1_COD + " " +SA1->A1_LOJA
	            ZBE->(MsUnlock())
				
				if cChar = 'S'
					if Reclock("SA1",.f.)
						SA1->A1_XVEND2   := cVend
						Msunlock()
					endif
					
				endif
				
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+" VEND2 PARA: "+cvend+" na SA1")
				lArqOk := .f.
			endif
			
			
			// Atualiza a PB3  Alex Borges 28/06/2012
			dbselectarea("PB3")
			dbsetorder(11)
			if !dbseek(xfilial("PB3")+_cCod+_cLoja)
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado na PB3.")
				lArqOk := .f.
			else
				AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+PB3_NOME+"  VEND2 DE: "+PB3_XVEND2+" na PB3")
				
				cVend    := Substr(cBuffer,11,6)
				cIDVend  := Substr(cBuffer,18,6)
				
				if cChar = 'S'
					if Reclock("PB3",.f.)
						//PB3->PB3_VEND     := cIDVend  //Id do vendedor     &&Conforme definido com Adriana(21/09/16) o ID do vendedor 2 nao sera atualizado(Campo nao existe).
						PB3->PB3_XVEND2  := cVend	  //Codigo do vendedor
						Msunlock()
					endif
					
				endif
				
				//AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+" PARA: "+cvend+"na PB3")
				lArqOk := .f.
			endif
			nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
			nLin++
		end
	endif
Endif

//cFileLog := "LOG"+_CARQ

//if !lArqOk
//	If cFileLog <> ""
//		MostraErro(cPath,cFileLog)
//	Endif
//endif           

_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
_cPath    := Substr(_cArq,1,RAt("\",_cArq))

//if !lArqOk
	MostraErro(_cPath,_cFileLog)
//	Aviso( OemToAnsi("ATENÇÃO"),OemToAnsi("Arquivo Importado com ERROS. Verifique em ")+_cPath+_cFileLog,{"Sair"} )
//else
	Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )
//Endif

If nHdl <> -1
	fClose(nHdl) // Fecha o arquivo
endif

Return
