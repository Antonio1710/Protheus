#INCLUDE "Protheus.ch"     

/* ESTRUTURA:
4356;02;MAN;000000005;A;NF;000002;00;
4357;02;MAN;000000006;AB;NF;000002;00;
*/
             
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATUCT2CF บ Autor ณ Ana Helena Barreta  บ Data ณ  10/06/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa que importa informacoes do txt para alimentar os  บฑฑ
ฑฑบ          ณ campos de rastreabilidade da CT2.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                               	
//ณ Declara variaveis                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

User Function ATUCT2CF()
Local _nTamLin							// Tamanho da linha no arquivo texto
Local _nHdl    	:= Nil           		// Handle para abertura do arquivo
Local _cBuffer							// Variavel para leitura
Local _cDelimit	:= ";"                 //Delimitador do arquivo CSV      
Local _cArq    	:= MV_PAR01
Local _nLin     := 1
Local _nTamanA  

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

_cPath := ""
nOpc := 0
cChar := ' '
nQtChar := 2
_cArq    := space(40)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processos iniciais...                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Atualiza dados da CT2") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Arquivo TXT:"	SIZE 030,007 OF _oDlg PIXEL
@ 10,20 MSGet oArq VAR _cArq Size 100,10 OF _oDlg PIXEL
@ 29,20 SAY "Atualiza (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 29,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if nOpc <> 1
	return
endif

lArqOK := .t.

_nHdl := fOpen(_cArq,2) // Abre o arquivo
fClose(_nHdl)
If _nHdl == -1
	Aviso( "AVISO",OemToAnsi("Nใo foi possํvel abrir o arquivo "+_cArq),{"Sair"} )
endif                          

ft_fUse(_cArq) 	//Abre o arquivo
ProcRegua(RecCount())
ft_fGoTop()		//Posiciona no inicio do arquivo

Do While !ft_fEOF()
	_cBuffer := ft_fReadLn()
	IncProc(" Linha: " + STR(_nLin,5,0) )	
	_nCmp := 1
	If _nLin > 0
		Do While Rat(_cDelimit, _cBuffer) > 0
			_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
				If _nCmp == 1
					_RECNO     := _cTxtPos
				Elseif _nCmp == 2								
					cFilCT2    := _cTxtPos
				Elseif _nCmp == 3					
					cPrefixo   := _cTxtPos
				Elseif _nCmp == 4						
					cNum       := _cTxtPos
				Elseif _nCmp == 5						
					cParcela   := _cTxtPos
				Elseif _nCmp == 6						
					cTipodoc   := _cTxtPos
				Elseif _nCmp == 7						
					cCliFor    := _cTxtPos
				Elseif _nCmp == 8						
					cLoja      := _cTxtPos
				Endif						
			_nCmp ++
	
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		EndDo
	Endif	
		
  	ft_fSkip()		//Pula linha
	_nLin ++
	
	if cChar = 'S'
			
		_cQuery := " UPDATE "+RetSqlName("CT2")+" WITH(UPDLOCK) SET "
		_cQuery += " CT2_FILKEY = '"+cFilCT2+"', "
		_cQuery += " CT2_PREFIX = '"+cPrefixo+"', "			
		_cQuery += " CT2_NUMDOC = '"+cNum+"', "			
		_cQuery += " CT2_PARCEL = '"+cParcela+"', "
		_cQuery += " CT2_TIPODC = '"+cTipodoc+"', "			
		_cQuery += " CT2_CLIFOR = '"+cCliFor+"', "						
		_cQuery += " CT2_LOJACF = '"+cLoja+"' "			
		_cQuery += " FROM "+RetSqlName("CT2")+" "		
		_cQuery += " WHERE "+RETSQLNAME("CT2")+".D_E_L_E_T_<>'*' "
		_cQuery += " AND "+RETSQLNAME("CT2")+".R_E_C_N_O_= "+_RECNO			
		TCSQLExec(_cQuery)				              
		
	endif	
	
EndDo

Return