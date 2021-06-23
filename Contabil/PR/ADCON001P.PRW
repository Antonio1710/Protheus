#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ADCON001P ³ Autor ³ ADRIANA OLIVEIRA      ³ Data ³ 28/01/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua leitura de arquivo TXT e altera campos na CT2       ³±±
±±³          ³ constantes na primeira linha do arquivo                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Obs.: Este programa altera registros na tabela CT2, de acordo com o conteudo
do arquivo texto, sendo que na primeira linha devem ser indicados quais os
campos que serao alterados+R_E_C_N_O_, e nas demais linhas deve ser indicado
o conteudo de cada campo constante na primeira linha. Conforme exemplo que 
segue:

CT2_FILKEY;CT2_PREFIX;CT2_NUMDOC;CT2_PARCEL;CT2_TIPODC;CT2_CLIFOR;CT2_LOJACF;R_E_C_N_O_
02;01;000431571;;NF;001994;00;15465382
02;01;000425667;;NF;034954;00;15059181
02;01;000367684;;NF;034954;00;14416214
;;;;;;;14277639
;;;;;;;14277640
;;;;;;;14277643

A rotina dá opção de apenas validar as informações para posteriormente serem gravadas.
Também gera um log indicando os registros que foram alterados, o conteudo anterior e o atual.  

d:\totvs\Protheus11\Protheus_Data\generico\conccli_1.txt (arquivo a ser importado)
d:\totvs\Protheus11\Protheus_Data\generico\conccli_1.log (log gerado)
/*/

User Function ADCON001P()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_nTamLin	:= 0		       // Tamanho da linha no arquivo texto
_nHdl    	:= Nil             // Handle para abertura do arquivo
_cBuffer	:= ""		       // Variavel para leitura
_cDelimit	:= ";"             // Delimitador do arquivo CSV
_cArq    	:= space(40)
_nLin     	:= 1
cFileLog 	:= ""
_cPath 		:= ""
nOpc 		:= 0
cChar		:= "N"
_aCampos	:= {}
_aConteudo 	:= {}
_lAbortado	:= .F.
_ContAnt    := ""
_cCampos	:= ""

DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera dados contábeis na tabela CT2 de acordo com o arquivo texto") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Arquivo TXT:"	SIZE 030,007 OF _oDlg PIXEL
@ 03,100 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
@ 33,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 33,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if nOpc <> 1
	return()
endif

lArqOK := .t.

_nHdl := fOpen(_cArq,2) // Abre o arquivo
fClose(_nHdl)
If _nHdl = -1
	Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
	
else
	
	ft_fUse(_cArq) 	//Abre o arquivo
	ProcRegua(RecCount())
	ft_fGoTop()		//Posiciona no inicio do arquivo
	
	Do While !ft_fEOF()
		_cBuffer := ft_fReadLn()
		IncProc(" Linha: " + STR(_nlin,10,0) )
		_cBuffer := _cBuffer + ";"     //incluido para considerar ultimo campo
		
		if _nLin = 1
			Do While Rat(_cDelimit, _cBuffer) > 0
				_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
				AADD(_aCampos,Alltrim(_cTxtPos))
				_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			EndDo
			_msgCampos	:= ""
			
			_CampoValido := .T.
			dbSelectArea("SX3")
			dbSetOrder(2)
			
			for _i := 1 to len(_aCampos)-1 //nao considera ultimo campo r_e_c_n_o_
				_msgCampos 	+= _aCampos[_i]+Chr(13)
				_cCampos	+= _aCampos[_i]+" Ant;"+_aCampos[_i]+";"
				
				if !MsSeek(_aCampos[_i])
					_CampoValido := .F.
					Exit
				endif
			next
			
			if !_CampoValido
				Alert("Processo Cancelado, campo "+Alltrim(_aCampos[_i])+" não Existe!")
				AutoGrLog("Processo Cancelado, campo "+Alltrim(_aCampos[_i])+" não Existe")
				_lAbortado	:= .T.
				Exit
			endif
			
			If !ApMsgYesNo(OemToAnsi("Confirma alteração nos campos abaixo? ")+Chr(13)+Chr(13)+_msgCampos,OemToAnsi(" T A B E L A - C T 2 "))
				Alert("Processo Cancelado")
				AutoGrLog("Processo Cancelado pelo usuario")
				_lAbortado	:= .T.
				Exit
			else
				AutoGrLog("R_E_C_N_O_;"+_cCampos)
			Endif
			ft_fSkip()		//Pula linha
			_nLin ++
			_cBuffer := ft_fReadLn()
			IncProc(" Linha: " + STR(_nlin,10,0) )
			_cBuffer := _cBuffer + ";"     //incluido para considerar ultimo campo
		Endif
		
		_aConteudo :={}
		
		Do While Rat(_cDelimit, _cBuffer) > 0
			_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
			AADD(_aConteudo,_cTxtPos)
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		EndDo
		
		if len(_aCampos) <> len(_aConteudo)
			Alert("Processo Abortado - Erro de estrutura do arquivo TEXTO")
			AutoGrLog("Processo Abortado - Erro de estrutura do arquivo TEXTO")
			_lAbortado	:= .T.
			Exit
		Endif
		
		dbSelectArea("CT2")
		DbGoTo(Val(_aConteudo[len(_aCampos)]))
		_cConteudo    := ""
		if !Eof() .and. RecLock("CT2",.F.)
			
			for _j := 1 to len(_aCampos)-1
				_cConteudo			+= CT2->&(_aCampos[_j])+";"+_aConteudo[_j]+";"//Alltrim(_aConteudo[_j])+";"
				if cChar = "S"
					CT2->&(_aCampos[_j]):= _aConteudo[_j] //Alltrim(_aConteudo[_j])
				endif
			next
			
			MsUnlock("CT2")
			AutoGrLog(_aConteudo[len(_aCampos)]+";"+_cConteudo)
			
		Endif
		ft_fSkip()		//Pula linha
		_nLin ++
	EndDo
endif

_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
_cPath    := Substr(_cArq,1,RAt("\",_cArq))

MostraErro(_cPath,_cFileLog)
if !_lAbortado
	Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )
endif

If _nHdl <> -1
	fClose(_nHdl) // Fecha o arquivo
endif

Return()
