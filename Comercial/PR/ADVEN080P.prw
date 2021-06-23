#include "Protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ADVEN080P³ Autor ³Mauricio-MDS TEC       ³ Data ³ 25/08/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao de Motivos de nao compra de vendedores          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Comercial                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Arquivos ³                                                            ³±±
±±³ em Uso   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Manutencao :                                                          ³±±
±±³                                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function ADVEN080P()


/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO:

Delimitado por ";", com 1 linha de cabecalho
 

1= CODIGO CLIENTE 	
2= LOJA CLIENTE  
3= Data apuracao DE
4= Data apuracao Ate
5= Codigo do MOTIVO
*/

_nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
_nHdl    	:= Nil           		// Handle para abertura do arquivo
_cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
_cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
_cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
_nQtChar 	:= 2
_cDelimit	:= ";"                 //Delimitador do arquivo CSV


_cPerg		:= PADR("ADVEN80P",10," ")
ValidPerg()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de Motivos de nao compra de vendedores')


if Pergunte(_cPerg,.T.)
	_cArq    	:= MV_PAR01      		// Arquivo texto a importar
	
	If MsgBox(OemToAnsi("Confirma importação dos motivos de não compra do arquivo "+Alltrim(_cArq)+"? "),"ATENCAO","YESNO")
		_nHdl := fOpen(_cArq,2) // Abre o arquivo
		fClose(_nHdl)
		If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		else
			Processa({|| ImpMOT()})
		endif
	endif
Endif

Return()

Static Function ImpMot()

Dbgotop()

ft_fUse(_cArq) 	//Abre o arquivo

ProcRegua(RecCount())
ft_fGoTop()		//Posiciona no inicio do arquivo
ft_fSkip()		//Pula a primeira linha (cabecalho)
_nLin := 2      //1 && se nao tiver cabecalho

Do While !ft_fEOF()
	_arqOk := .T.
	_cBuffer := ft_fReadLn()
	_nCmp := 1
	
	FOR I := 1 TO 7
		_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
		if _nCmp = 1
			_cCli    := _cTxtPos
		elseif _nCmp = 2
			_cLoj := _cTxtPos
		elseif _nCmp = 3
			_DTAPDE := ctod(_cTxtPos)
		elseif _nCmp = 4
			_DTAPAT := ctod(_cTxtPos)
		elseif _nCmp = 5	
			_CodMot := Alltrim(_cBuffer)
		endif
		_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		_nCmp++
	Next
	IncProc("Realizando a importação, aguarde......")
	
	
	//MSGINFO("MOTIVO : "+_CodMOt)
	
	DbSelectArea("ZBI")
	DbSetOrder(3)
	If dbseek(xFilial("ZBI")+_cCLi+_cLoj)
		While ZBI->(!Eof()) .And. ZBI->ZBI_CODCLI+ZBI->ZBI_LOJA == _cCli + _cLoj
			IF ZBI->ZBI_DTAPDE >= _DTAPDE .And. ZBI->ZBI_DTAPAT <= _DTAPAT
				//_cMot := Posicione("SX5",1,"02"+"ZY"+_CodMot,"X5_DESCRI")
				If Reclock("ZBI",.F.)
					ZBI->ZBI_MOTIVO := _CodMot
					ZBI->(MsUnlock())
				Endif
			ENDIF
			ZBI->(dbSkip())
		Enddo
	Endif
	
	ft_fSkip()
	_nLin ++
	
	
End

iF _arqOk
	msgInfo("Processamento concluido com sucesso!")
endIf

Return()

Static Function ValidPerg
PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")
Return()