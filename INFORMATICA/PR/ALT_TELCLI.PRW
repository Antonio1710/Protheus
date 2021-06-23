#include "Protheus.ch"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TEL_CLI  ³ Autor ³ Adriana                                                                                   ³ Data ³ 25/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ALTERA TELEFONE DO CLIENTE                                                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function TEL_Cli()
&&Mauricio 30/04/14 - iniciado alteração de toda a logica do programa em função de mudança com inclusão de mais telefones no arquivo a ser importado.
&&Esta rotina importa telefone somente para cadastro de Clientes.

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'ALTERA TELEFONE DO CLIENTE')

/*LAYOUT DO ARQUIVO CSV OU TXT A SER IMPORTADO:

Arquivo deve ser delimitado por ";", com 1 linha de cabecalho  e ";" ao final de cada linha tambem

1= Cod. Cliente 	(Tipo Caracter)
2= Cod. Loja        (Tipo Caracter)
3= DDD tel1         (Tipo Caracter)
4= Tel 1            (Tipo Caracter)
5= DDD tel2         (Tipo Caracter)
6= TEl 2            (Tipo Caracter)
7= DDD tel 3        (Tipo Caracter)
8= Tel 3            (Tipo Caracter)
9= DDD tel 4        (Tipo Caracter)
10=TEL 4            (Tipo Caracter)
11=DDD 5            (Tipo Caracter)
12=TEL 5            (Tipo Caracter)
13=DDD 6            (Tipo Caracter)
14=TEL 6            (Tipo Caracter)

Exemplo:

CLIENTE;LOJA;DDD;TELEFONE;DDD;TELEFONE;DDD;TELEFONE;DDD;TELEFONE;DDD;TELEFONE;DDD;TELEFONE;
000001;00;011;5555-1455;;;;;;;012;88884444;;;
*/

_nTamLin 	:= 150            		
_nHdl    	:= Nil           		
_cBuffer 	:= Space(_nTamLin+1) 	
_nBytes  	:= 0                	
_cDelimit	:= ";"                  

_cPerg		:= PADR("ALTTELCLI",10," ")
ValidPerg()
       
if Pergunte(_cPerg,.T.)
	_cArq    	:= MV_PAR01      		
	                                                                                         
	If MsgYesNo(OemToAnsi("Confirma importaçao do arquivo  "+Alltrim(_cArq)+" com telefones para o Cadastro de Clientes?"),"ATENCAO")
		_nHdl := fOpen(_cArq,2) 
		fClose(_nHdl)
		
		If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		else
			Processa({|| ImpTel()})
		endif
		
	endif
Endif

Return()

Static Function ImpTel()
_cFileLog := ""
cPath := GetSrvProfString("StartPath","")+"LOG\"
nLin := 1
AutoGrLog("LOG ALTERACAO TELEFONE SA1 e PB3")
AutoGrLog("----------------------------------------------------")
AutoGrLog(" ")
AutoGrLog(" ")
lArqOK := .t.

ft_fUse(_cArq)

ProcRegua(RecCount())

ft_fGoTop()
_nLin := 1

Do While !ft_fEOF()
    _cCli     := ""
    _cLoj     := ""
    _cDD1     := ""
    _cTF1     := ""
    _cDD2     := ""
    _cTF2     := ""
    _cDD3     := ""
    _cTF3     := ""
    _cDD4     := ""
    _cTF4     := ""
    _cDD5     := ""
    _cTF5     := ""
    _cDD6     := ""
    _cTF6     := ""
    _aEstrPro := {}
    _lcont    := .T.
    _lret     := .T.

	_arqOk := .T.
	_cBuffer := ft_fReadLn()
	_nCmp := 1
	
	If _nLin == 1      //pula cabecalho
		ft_fSkip()
		_nLin ++
		loop
	Endif
	
	for _i := 1 to 14
	
		_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
		
		if _i = 1
			_cCli := alltrim(_cTxtPos)
		elseif _i = 2
			_cLoj := alltrim(_cTxtPos)
		elseif _i = 3
			_cDD1 := alltrim(_cTxtPos)
		elseif _i = 4
			_cTF1 := alltrim(_cTxtPos)
	    elseif _i = 5
			_cDD2 := alltrim(_cTxtPos)
		elseif _i = 6
			_cTF2 := alltrim(_cTxtPos)		
		elseif _i = 7
			_cDD3 := alltrim(_cTxtPos)
		elseif _i = 8
			_cTF3 := alltrim(_cTxtPos)
	    elseif _i = 9
			_cDD4 := alltrim(_cTxtPos)
		elseif _i = 10
			_cTF4 := alltrim(_cTxtPos)	
	    elseif _i = 11
			_cDD5 := alltrim(_cTxtPos)
		elseif _i = 12
			_cTF5 := alltrim(_cTxtPos)
	    elseif _i = 13
			_cDD6 := alltrim(_cTxtPos)
		elseif _i = 14
			_cTF6 := alltrim(_cTxtPos)				
		endif
		
		_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		_nCmp++
	next
	
	IncProc("Importando...")
		
	DbSelectArea("SA1")
	DbSetOrder(1)
	dbgotop()
	if dbseek(xFilial("SA1")+_cCli+_cLoj)
	   _cDD1A     := SA1->A1_DDD
       _cTF1A     := SA1->A1_TEL     
       _cTF2A     := SA1->A1_TEL2
       _cTF3A     := SA1->A1_TEL3
       _cTF4A     := SA1->A1_TEL4
       _cTF5A     := SA1->A1_TEL5
       _cTF6A     := SA1->A1_TEL6
                                 
       // So grava se tiver conteudo, para limpar campo gravado tem que ser pelo cadastro SA1, PB3
       
	   Reclock("SA1",.F.)
	   If !Empty(_cDD1)
		  SA1->A1_DDD := Alltrim(_cDD1)
		  AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do DDD:  "+_cDD1A+"             Para  DDD:  "+_cDD1)  	   
	   Endif
	   
	   If !Empty(_cTF1)
		  SA1->A1_TEL := Alltrim(_cTF1)
		  AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL:  "+_cTF1A+" Para  TEL:  "+_cTF1) 		  	   	   
	   Endif
	   
	   IF !Empty(_cTF2)
	      If !Empty(_cDD2)	      
	         SA1->A1_TEL2 := Alltrim(_cDD2)+" "+Alltrim(_cTF2)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL2: "+_cTF2A+" Para  TEL2: "+Alltrim(_cDD2)+" "+Alltrim(_cTF2))
	      Else
	         SA1->A1_TEL2 := Alltrim(_cTF2)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL2: "+_cTF2A+" Para  TEL2: "+Alltrim(_cTF2))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF3)
	      If !Empty(_cDD3)	      
	         SA1->A1_TEL3 := Alltrim(_cDD3)+" "+Alltrim(_cTF3)
	          AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL3: "+_cTF3A+" Para  TEL3: "+Alltrim(_cDD3)+" "+Alltrim(_cTF3))
	      Else
	         SA1->A1_TEL3 := Alltrim(_cTF3)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL3: "+_cTF3A+" Para  TEL3: "+Alltrim(_cTF3))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF4)
	      If !Empty(_cDD4)	      
	         SA1->A1_TEL4 := Alltrim(_cDD4)+" "+Alltrim(_cTF4)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL4: "+_cTF4A+" Para  TEL4: "+Alltrim(_cDD4)+" "+Alltrim(_cTF4))
	      Else
	         SA1->A1_TEL4 := Alltrim(_cTF4)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL4: "+_cTF4A+" Para  TEL4: "+Alltrim(_cTF4))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF5)
	      If !Empty(_cDD5)	      
	         SA1->A1_TEL5 := Alltrim(_cDD5)+" "+Alltrim(_cTF5)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL5: "+_cTF5A+" Para  TEL5: "+Alltrim(_cDD5)+" "+Alltrim(_cTF5))
	      Else
	         SA1->A1_TEL5 := Alltrim(_cTF5)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL5: "+_cTF5A+" Para  TEL5: "+Alltrim(_cTF5))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF6)
	      If !Empty(_cDD6)	      
	         SA1->A1_TEL6 := Alltrim(_cDD6)+" "+Alltrim(_cTF6)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL6: "+_cTF6A+" Para  TEL6: "+Alltrim(_cDD6)+" "+Alltrim(_cTF6))
	      Else
	         SA1->A1_TEL6 := Alltrim(_cTF6)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" SA1 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL6: "+_cTF6A+" Para  TEL6: "+Alltrim(_cTF6))
	      Endif   	   
	   Endif	   
	   SA1->(MsUnlock())	
	Endif
	
	//Incluido por Adriana em 28/05/2014 para gravar tabela PB3 - chamado 19134		      
	DbSelectArea("PB3")
	DbSetOrder(11)
	dbgotop()
	if dbseek(xFilial("PB3")+_cCli+_cLoj)
	   _cDD1A     := PB3->PB3_DDD
       _cTF1A     := PB3->PB3_TEL     
       _cTF2A     := PB3->PB3_TEL2
       _cTF3A     := PB3->PB3_TEL3
       _cTF4A     := PB3->PB3_TEL4
       _cTF5A     := PB3->PB3_TEL5
       _cTF6A     := PB3->PB3_TEL6
        
	   Reclock("PB3",.F.)
	   If !Empty(_cDD1)
		  PB3->PB3_DDD := Alltrim(_cDD1)
		  AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do DDD:  "+_cDD1A+"             Para  DDD:  "+_cDD1)  	   
	   Endif
	   
	   If !Empty(_cTF1)
		  PB3->PB3_TEL := Alltrim(_cTF1)
		  AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL:  "+_cTF1A+" Para  TEL:  "+_cTF1) 		  	   	   
	   Endif
	   
	   IF !Empty(_cTF2)
	      If !Empty(_cDD2)	      
	         PB3->PB3_TEL2 := Alltrim(_cDD2)+" "+Alltrim(_cTF2)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL2: "+_cTF2A+" Para  TEL2: "+Alltrim(_cDD2)+" "+Alltrim(_cTF2))
	      Else
	         PB3->PB3_TEL2 := Alltrim(_cTF2)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL2: "+_cTF2A+" Para  TEL2: "+Alltrim(_cTF2))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF3)
	      If !Empty(_cDD3)	      
	         PB3->PB3_TEL3 := Alltrim(_cDD3)+" "+Alltrim(_cTF3)
	          AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL3: "+_cTF3A+" Para  TEL3: "+Alltrim(_cDD3)+" "+Alltrim(_cTF3))
	      Else
	         PB3->PB3_TEL3 := Alltrim(_cTF3)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL3: "+_cTF3A+" Para  TEL3: "+Alltrim(_cTF3))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF4)
	      If !Empty(_cDD4)	      
	         PB3->PB3_TEL4 := Alltrim(_cDD4)+" "+Alltrim(_cTF4)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL4: "+_cTF4A+" Para  TEL4: "+Alltrim(_cDD4)+" "+Alltrim(_cTF4))
	      Else
	         PB3->PB3_TEL4 := Alltrim(_cTF4)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL4: "+_cTF4A+" Para  TEL4: "+Alltrim(_cTF4))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF5)
	      If !Empty(_cDD5)	      
	         PB3->PB3_TEL5 := Alltrim(_cDD5)+" "+Alltrim(_cTF5)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL5: "+_cTF5A+" Para  TEL5: "+Alltrim(_cDD5)+" "+Alltrim(_cTF5))
	      Else
	         PB3->PB3_TEL5 := Alltrim(_cTF5)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL5: "+_cTF5A+" Para  TEL5: "+Alltrim(_cTF5))
	      Endif   	   
	   Endif
	   IF !Empty(_cTF6)
	      If !Empty(_cDD6)	      
	         PB3->PB3_TEL6 := Alltrim(_cDD6)+" "+Alltrim(_cTF6)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL6: "+_cTF6A+" Para  TEL6: "+Alltrim(_cDD6)+" "+Alltrim(_cTF6))
	      Else
	         PB3->PB3_TEL6 := Alltrim(_cTF6)
	         AutoGrLog("Linha "+strzero(_nlin,5)+" PB3 Alterado Cliente "+_cCli+"-"+_cLoj+" do TEL6: "+_cTF6A+" Para  TEL6: "+Alltrim(_cTF6))
	      Endif   	   
	   Endif	   
	   PB3->(MsUnlock())	
	Endif
	//
			      
	ft_fSkip()
	_nLin ++
	nLin ++
	
Enddo

_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
_cPath    := Substr(_cArq,1,RAt("\",_cArq))

MostraErro(_cPath,_cFileLog)

FT_FUSE()

fClose(_nHdl)

Return()





/*   
	_cMesg := OemToAnsi("Confirma importação de Valores do arquivo " + Alltrim(MV_PAR01) + cCRLF2 +;
						" para a Tabela: " ) + _cTabela + cCRLF2 + "Campos Lidos e Alterados: " + cCRLF2
	AEval( _aNome, { |_aNome| _cMesg += _aNome + cCRLF })
	
	If MsgBox(_cMesg,"ATENCAO","YESNO")
		DbSelectArea("DA1")
		DA1->(DbSetOrder(1))
		_lArqOk := .T.
		For _nInd = 1 to Len(_aDado)
			_cProduto := _aDado[_nInd,1]
			_nPrecoRs := _aDado[_nInd,2]
			If DA1->(DBSeek(CFILANT+_cTabela+_cProduto))
				_nPrecoOl := DA1->DA1_XPRLIQ
				If DA1->(Reclock("DA1",.F.))
					DA1->DA1_XPRLIQ	:= _nPrecoRs
					Msunlock()
					AutoGrLog("Linha "+strzero(_nInd,5)+"-> Filial "+CFILANT+", Tabela "+_cTabela+", Cod. Produto "+AllTrim(_cProduto)+ ;
								" DE: " + Transform(_nPrecoOl,"@E 9,999.99") + " PARA: " + Transform(_nPrecoRs,"@E 9,999.99") )
				else
					AutoGrLog("Linha "+strzero(_nInd,5)+"-> Filial "+CFILANT+", Tabela "+_cTabela+", Cod. Produto "+AllTrim(_cProduto)+ ;
								" nao conseguiu gravar (LOCK).")
				endif
			else
				AutoGrLog("Linha "+strzero(_nInd,5)+"-> Filial "+CFILANT+", Tabela "+_cTabela+", Cod. Produto "+AllTrim(_cProduto)+;
							" nao encontrou Produto na DA1.")
			Endif
		Endfor
		&&Mauricio - MDS TECNOLOGIA - 06/11/13 - Solicitado por Vagner ajustar sequencia de item da tabela pela ordem de codigo de produtos.
		DbSelectArea("DA1")
		DA1->(DbSetOrder(1))
		dbGotop()
		If DA1->(DBSeek(CFILANT+_cTabela))  &&Posiciono no primeiro registro da tabela por ordem de FILIAL/TABELA
		   _nSeq := 1
		   While DA1->(!Eof()) .And. DA1->DA1_FILIAL == CFILANT .AND. DA1->DA1_CODTAB == _cTabela
		         Reclock("DA1",.F.)
		            DA1->DA1_ITEM := STRZERO(_nSeq,4)		         
		         DA1->(MsUnlock())
		         _nSeq += 1
		         DA1->(dbSkip())
		   Enddo
		Endif  
		_cFileLog := Left(MV_PAR01,At(".",MV_PAR01)-1)+".LOG"
		_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
		_cPath    := Substr(MV_PAR01,1,RAt("\",MV_PAR01))
		if _lArqOk
			MostraErro(_cPath,_cFileLog)
			Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!")+"Arquivo gravado em:"+_cPath+_cFileLog,{"Sair"} )
		else		
			MostraErro(_cPath,_cFileLog)
			Aviso( OemToAnsi("ATENÇÃO"),OemToAnsi("Arquivo Importado com ERROS. Verifique em: ")+cCRLF2+_cPath+_cFileLog,{"Sair"} )
		Endif			
	Endif
Endif

Return





/*
cFileLog := ""
cPath := GetSrvProfString("StartPath","")+"LOG\"
cTabela := "SA1"
cPrefixo:= "A1_"
cChar := "S"
_cArq := "SA1_TEL"
_cTelefone := ""
_cDDD := ""
nLin := 1            
nOpc := 0

DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Altera telefone de clientes/ fornecedores, separando DDD e telefone") From 100,0 To 225,575 PIXEL
@ 03,20 SAY "Tabela:"	SIZE 030,007 OF _oDlg PIXEL
@ 10,20 MSGet oArq VAR cTabela Size 100,10 OF _oDlg PIXEL
@ 29,20 SAY "Atualiza cadastro (S/N)? "	SIZE 200,007 OF _oDlg PIXEL
@ 29,100 MSGet ochar VAR cChar Size 030,10 OF _oDlg PIXEL

DEFINE SBUTTON FROM 40,190 TYPE 1 ACTION (nOpc:=1, _oDlg:End()) ENABLE OF _oDlg PIXEL
DEFINE SBUTTON FROM 40,240 TYPE 2 ACTION ( _oDlg:End()) ENABLE OF _oDlg PIXEL

ACTIVATE MSDIALOG  _oDlg CENTERED

if !nOpc = 1
	return
endif

AutoGrLog("LOG ALTERACAO TELEFONE - "+cTabela)
AutoGrLog("----------------------------------------------------")
AutoGrLog(" ")
AutoGrLog(" ")
lArqOK := .t.
_cArq := cTabela+"_TEL"   
cPrefixo := substr(cTabela,2,2)+"_"
dbselectarea(cTabela)
dbgotop()
While !eof()       
	AutoGrLog("Linha "+strzero(nlin,5)+" "+&(cTabela+"->"+cPrefixo+"COD")+&(cTabela+"->"+cPrefixo+"LOJA")+"      DE:  DDD "+&(cTabela+"->"+cPrefixo+"DDD")+" Telefone: "+&(cTabela+"->"+cPrefixo+"TEL"))
	_cTelefone :=&(cTabela+"->"+cPrefixo+"TEL")
	if !empty(_cTelefone) .and. &(cTabela+"->"+cPrefixo+"EST")<>"EX"
		_cTelefone    := iif(	at("/",_cTelefone) > 0,  left(_cTelefone,at("/",_cTelefone)),_cTelefone)		
		_cTel    := LTrim(str(FisGetTel(	_cTelefone )[3],18))                                                       
		_cTel    := iif(len(_cTel)>5,left(_cTel,len(_ctel)-4)+"-"+right(_ctel,4),_cTel)
		if len(_cTel) = 11
			_cDDD := iif(empty(&(cTabela+"->"+cPrefixo+"DDD")),left(_cTel,2), &(cTabela+"->"+cPrefixo+"DDD"))
			_cTel := right(_cTel,9)
		else
			_cDDD  := iif(empty(&(cTabela+"->"+cPrefixo+"DDD")),iif(FisGetTel(	_cTelefone )[2]>0,StrZero(FisGetTel(	_cTelefone)[2],3),"   "), &(cTabela+"->"+cPrefixo+"DDD"))
		endif
		if cChar = "S" .and. lastkey() <> 27
			if Reclock(cTabela,.f.)         
				&(cTabela+"->"+cPrefixo+iif(&(cTabela+"->"+cPrefixo+"EST")="EX","DDI","DDD")) := _cDDD
				&(cTabela+"->"+cPrefixo+"TEL")  := _cTel
				Msunlock()
			endif
		endif
		
		AutoGrLog("Linha "+strzero(nlin,5)+" "+cTabela+" "+&(cTabela+"->"+cPrefixo+"COD")+&(cTabela+"->"+cPrefixo+"LOJA")+"  PARA:  DDD "+_cDDD  +" Telefone: "+_cTel)
		lArqOk := .f.
	else
		AutoGrLog("Linha "+strzero(nlin,5)+" "+cTabela+" "+&(cTabela+"->"+cPrefixo+"COD")+&(cTabela+"->"+cPrefixo+"LOJA")+iif(&(cTabela+"->"+cPrefixo+"EST")="EX","EXPORTACAO/IMPORTACAO","  TELEFONE EM BRANCO"))
	endif
	
	nLin++                 

	DBSkip() 

end

cFileLog := "LOG"+_CARQ

if !lArqOk
	If cFileLog <> ""
		MostraErro(cPath,cFileLog)
	Endif
endif

Return
*/

Static Function ValidPerg

PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")

Return
