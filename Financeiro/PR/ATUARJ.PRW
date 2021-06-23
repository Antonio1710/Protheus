#include "Protheus.ch"
#include "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ATUARJ ³ Autor ³ Alex Borges             ³ Data ³ 24/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao para atualizar titulos com recuperacao judicial ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
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

User Function ATUARJ()


/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO:

Delimitado por ";", com 1 linha de cabecalho
 

1= FILIAL 	
2= FORNECEDOR 
3= LOJA 
4= PREFIXO	
5= NUMERO DO TITULO
6= PARCELA
*/

_nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
_nHdl    	:= Nil           		// Handle para abertura do arquivo
_cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
_cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
_cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
_nQtChar 	:= 2
_cDelimit	:= ";"                 //Delimitador do arquivo CSV

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao para atualizar titulos com recuperacao judicial')

_cPerg		:= PADR("ATUARJ",10," ")
ValidPerg()

if Pergunte(_cPerg,.T.)
	_cArq    	:= MV_PAR01      		// Arquivo texto a importar
	
	If MsgBox(OemToAnsi("Confirma importação dos titulos que ficarão bloqueados por recuperacao judicial? Arquivo "+Alltrim(_cArq)+" "),"ATENCAO","YESNO")
		_nHdl := fOpen(_cArq,2) // Abre o arquivo
		fClose(_nHdl)
		If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		else
			Processa({|| ImpCSVRJ()})
		endif
	endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpCSVRJ ºAutor  ³Alex Borges -        º Data ³  24/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa rotina de importacao com regua de processamento     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpCSVRJ()
cFileLog := ""
cPath := GetSrvProfString("StartPath","")+"LOG\"

AutoGrLog("LOG DE TITULOS NAO ATUALIZADOS PARA RECUPERACAO JUDICIAL")
AutoGrLog("-------------------------------------")
AutoGrLog(" ")
AutoGrLog(" ")



Dbgotop()

ft_fUse(_cArq) 	//Abre o arquivo

ProcRegua(RecCount())
	ft_fGoTop()		//Posiciona no inicio do arquivo
	_nLin := 0     
	
	Do While !ft_fEOF() 
	     _arqOk := .T.
		_cBuffer := ft_fReadLn() 
		_nCmp := 1 
        _Chave := "" 

		FOR I := 1 TO 6
	   	    _cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
			if _nCmp = 1	
				_Filial := _cTxtPos
			elseif _nCmp = 2   
			    _Fornecedor := PadR(_cTxtPos,6) 
			     _cTxtPos := PadR(_cTxtPos,6) 
			elseif _nCmp = 3   
				_Loja := _cTxtPos
		    elseif _nCmp = 4 
				_Prefixo := PadR(_cTxtPos,3)
				_cTxtPos := PadR(_cTxtPos,3)
			elseif _nCmp = 5 
				_NumTit := PadR(_cTxtPos,9)	
				_cTxtPos := PadR(_cTxtPos,9)
		    elseif _nCmp = 6  
				_Parcela := PadR(_cTxtPos,3)
				_cTxtPos := PadR(_cTxtPos,3)
			endif 
			_Chave += _cTxtPos
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			_nCmp++
		End
	   	IncProc("Importando : Fornecedor: "+_Fornecedor + " Loja: " + _Loja + " Titulo : "+_NumTit) 
	   

		dbSelectArea("SE2")
		dbSetOrder(6)
	    // Verifica se existe o titulo
	    If dbseek(_Chave,.T.)
		    RecLock("SE2",.F.)
		    // Sobrepor informacoes da Meta Preco
		    Replace E2_DATALIB    With cTod('')
		    Replace E2_HIST       With "PROCESSO REC. JUDICIAL"
		    Replace E2_RJ         With "X"
		    MSUNLOCK()
   		Else
  			AutoGrLog("Linha "+strzero(_nLin,5)+", Filial : "+_Filial+" Fornecedor: "+_Fornecedor+" Loja: "+_Loja+" Prefixo: "+_Prefixo+" Titulo: "+_NumTit+" Parcela: "+_Parcela+" nao encontrado.")
			lArqOk := .f.
   		Endif
		ft_fSkip()
		_nLin ++
	

End

_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
_cPath    := Substr(_cArq,1,RAt("\",_cArq))


MostraErro(_cPath,_cFileLog)
      
iF _arqOk
     msgInfo("Processamento concluido com sucesso!")
endIf

Return



Static Function ValidPerg

PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")


Return
