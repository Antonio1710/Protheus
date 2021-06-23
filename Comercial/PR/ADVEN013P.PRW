#include "Protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ IMPMETA2 ³ Autor ³ Mauricio            ³ Data ³ 22/12/11   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao de Metas de Vendedores na tabela ZZT            ³±±
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

User Function ADVEN013P()

&&Mauricio - 19/08/15 alterado leiaute e programa para nova importação somente de volume....
/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO:

Delimitado por ";", SEM linha de cabecalho
 

1= Vendedor
2= Supervisor 	
3= Grupo  
4= Data 	
5= Peso 	(Tipo Numerico)
*/

_nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
_nHdl    	:= Nil           		// Handle para abertura do arquivo
_cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
_cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
_cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
_nQtChar 	:= 2
_cDelimit	:= ";"                 //Delimitador do arquivo CSV

_cPerg		:= PADR("IMPMET",10," ")
ValidPerg()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de Metas de Vendedores na tabela ZZT')

if Pergunte(_cPerg,.T.)
	_cArq    	:= MV_PAR01      		// Arquivo texto a importar
	
	If MsgBox(OemToAnsi("Confirma importação de Valores do arquivo "+Alltrim(_cArq)+" para a tabela de Meta de VOLUME de vendedores? "),"ATENCAO","YESNO")
		_nHdl := fOpen(_cArq,2) // Abre o arquivo
		fClose(_nHdl)
		If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		else
			Processa({|| ImpCSVMS()})
		endif
	endif
Endif

Return

Static Function ImpCSVMS()

Dbgotop()

ft_fUse(_cArq) 	//Abre o arquivo

ProcRegua(RecCount())
ft_fGoTop()		//Posiciona no inicio do arquivo
_nLin := 1

Do While !ft_fEOF()
	_arqOk := .T.
	_cBuffer := ft_fReadLn()
	_nCmp := 1
	
	FOR I := 1 TO 5
		_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
		if _nCmp = 1
			_Supervisor    := _cTxtPos
			//Verifica se existe o supervisor
			dbSelectArea("SA3")
			dbSetOrder(1)
			//Posicinar no primeiro supervisor do parametro
			If dbseek(xFilial("SA3")+_Supervisor,.f.)
				_NomSupervisor := ALLTRIM(A3_NOME)
			Else
				ALERT("VENDEDOR "+_Supervisor+" INVALIDO NA LINHA :"+ALLTRIM(Str(_nLin)))
				Return
			End If
		elseif _nCmp = 2
			_cSup := _cTxtPos
		elseif _nCmp = 3
			_Grupo := _cTxtPos
			_NomGrupo := ""
			//Verifica se existe o Grupo do Produto
			DbSelectArea("SBM")
			Dbsetorder(1)//FILIAL+GRUPO
			If DBSEEK(xFilial("SBM")+_Grupo,.T.)
				_NomGrupo  :=SBM->BM_DESC
			Else
				ALERT("GRUPO "+_Grupo+" INVALIDO NA LINHA :"+ALLTRIM(Str(_nLin)))
				Return
			EndIf
			
		elseif _nCmp = 4
			_Data := ctod(_cTxtPos)
		elseif _nCmp = 5
			_Peso := Val(StrTran(_cBuffer,",","."))
		endif
		_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		_nCmp++
	Next
	
	IncProc("Importando : "+_Supervisor + " Grupo: " + _Grupo + " Data: "+DTOC(_Data))
	
	&&Mauricio - 02/05/17 - chamado 034887
	If !(_Grupo == "00  " .Or. Alltrim(_Grupo) == "00")
		
		dbSelectArea("ZZT")
		dbSetOrder(5) &&Na base teste é 3 na base de produçao sera 5
		// Verifica se ja tem esta meta
		// Caso tenho sobrepor
		If dbseek(xFilial("ZZT")+_Supervisor+_cSup+_Grupo+DTOS(_Data),.t.)        //Vendedor+supervisor+grupo+data
			
			RecLock("ZZT",.F.)
			// Sobrepor informacoes da Meta VOLUME
			//Replace ZZT_VALOR    With _Valor
			Replace ZZT_PESMET   With _Peso
			MSUNLOCK()
			
		Else
			
			RecLock("ZZT",.T.)
			// Incluir informacoes
			Replace ZZT_FILIAL   With xFilial("ZZT")
			Replace ZZT_VENDED   With _Supervisor
			Replace ZZT_SUPERV   With _cSup
			Replace ZZT_NOMVEN   With _NomSupervisor
			Replace ZZT_GRUPO    With _Grupo
			Replace ZZT_NOMGRU   With _NomGrupo
			Replace ZZT_DATA     With _Data
			Replace ZZT_PESMET   With _Peso
			MSUNLOCK()
			
		Endif
	Endif
	
	ft_fSkip()
	_nLin ++
	
End

iF _arqOk
	msgInfo("Processamento concluido com sucesso!")
endIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDPERG ºAutor  ³ADRIANA - HC        º Data ³  27/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para incluir perguntas no SX1                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg

PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")


Return
