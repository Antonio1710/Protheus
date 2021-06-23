#INCLUDE "Protheus.ch"
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ATUEMCLI  ³ Autor ³ Mauricio MDS TEC      ³ Data ³ 09/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ LE TXT E ALTERA CAMPO A1_EMAIL DO CADASTRO DE CLIENTES     ³±±
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

User Function ATUEMCLI() 
&&estrutura arquivo
&&COD+LOJA+EMAIL(Tamanho 06,02,70)

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'LE TXT E ALTERA CAMPO A1_EMAIL DO CADASTRO DE CLIENTES')

nTamLin := 80               // Tamanho da linha no arquivo texto
_cArq    := space(40)       // Arquivo texto a importar com codigo+loja
nHdl    := NIL              // Handle para abertura do arquivo
cBuffer := Space(nTamLin+1) // Variavel para leitura
nBytes  := 0                // Variavel para verificacao do fim de arquivo
cFileLog := ""
cPath := GetSrvProfString("StartPath","")+"LOG\"
nOpc := 0
cChar := ' '
nQtChar := 2
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processos iniciais...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera campo email do cadastro de clientes listados no TXT.") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Arquivo TXT:"	SIZE 030,007 OF _oDlg PIXEL
@ 10,20 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
@ 29,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 29,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if nOpc <> 1
	return
endif

AutoGrLog("LOG ALTERACAO EMAIL DE CLIENTES")
AutoGrLog("-------------------------------------")
AutoGrLog(" ")
AutoGrLog(" ")
lArqOK := .t.

nHdl := fOpen(_cArq,2) // Abre o arquivo
If nHdl == -1
	AutoGrLog("NAO FOI POSSIVEL ABRIR O ARQUIVO "+_cArq)
	lArqOK := .f.
else
	nlin := 1
	//valida informacoes do arquivo
	nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha

	While nBytes == nTamLin+nQtChar
	
		_cCod    := Substr(cBuffer,1,6)
		_cLoja   := Substr(cBuffer,8,2)
		
		dbselectarea("SA1")
		dbsetorder(1)
		if !dbseek(xfilial("SA1")+_cCod+_cLoja)
			AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" nao encontrado.")
			lArqOk := .f.
		else                               
			AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+"   DE: "+ALLTRIM(A1_EMAIL))
				
			cEmail := Substr(cBuffer,11,70)
			
			if cChar = 'S'
			    	
				if Reclock("SA1",.f.)
					SA1->A1_EMAIL   := ALLTRIM(cEmail)
					Msunlock()
					dbselectarea("PB3")
					dbsetorder(11)
					If dbseek (xFilial("PB3")+_cCod+_cLoja)
					
						Reclock("PB3",.F.)
							PB3->PB3_EMAIL   := ALLTRIM(cEmail)
						Msunlock()					
					Endif
				endif                
				
			endif
			    
			dbselectarea("SA1")
			AutoGrLog("Linha "+strzero(nlin,5)+" Cliente "+_cCod+_cLoja+" "+A1_NOME+" PARA: "+Alltrim(cEmail))
			lArqOk := .f.
		endif
		
		nBytes := fRead(nHdl,@cBuffer,nTamLin+nQtChar) // Le uma linha
		nLin++
	end
endif

_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
_cPath    := Substr(_cArq,1,RAt("\",_cArq))


MostraErro(_cPath,_cFileLog)
Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )


If nHdl <> -1
	fClose(nHdl) 
endif

Return
