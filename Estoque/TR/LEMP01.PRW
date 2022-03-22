#INCLUDE "PROTHEUS.CH"
//ฺ---------ย------------------ย------ย----------------------------------------ย----ย-----------ฟ
//|PROGRAMA | LEMP             |AUTOR | DANIEL PITTHAN SILVEIRA                |DATA|26/03/07   |
//ร---------+------------------ม------ม----------------------------------------ม----ม-----------ด
//|DESCRICAO| Limpa a quantidade empenhada dos produtos selecionados e permite a impressao dos  |
//|         | da listagem empenhada                                                             |
//|         |                                                                                   |
//|         |                                                                                   |
//ร---------+----------------------ย-----ย------------------------------------------------------ด
//|MODULO   | ESTOQUE/CUSTOS       |TIPO | [ ] - PROCESSAMENTO          [X] - TRANSACAO         |
//|         |                      |     | [ ] - PONTO DE ENTRADA       [ ] - VALIDACAO         |
//|         |                      |     | [ ] - GATILHO                [ ] - CONSULTA          |
//|         |                      |     | [ ] - RELATORIO                                      |
//ร---------+--------------ย-------ม-----ม----ย-------------------------------------------------ด
//|MANUT.   |DATA          | AUTOR            |DESCRICAO                                        |
//ร---------+--------------+------------------+-------------------------------------------------ด
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//|         |              |                  |                                                 |
//ภ---------ม--------------ม------------------ม-------------------------------------------------ู
// @history chamado TI     - Leonardo P. Monteiro - 08/03/2022 - Corre็ใo do msunlock para prevenir lock na tabela SB2.

USER FUNCTION LEMP01   

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Limpa a quantidade empenhada dos produtos selecionados e permite a impressao dos da listagem empenhada')
//+------------------------------------------------------------------+
//|DECLARACAO DE VARIAVEIS                                           |
//+------------------------------------------------------------------+
//+-------------------------+
//|AMBIENTE                 |
//+-------------------------+
Public _cAliasSB1		:='SB1'
Public _cAliasSB2 	:='SB2'
Public _cFilSB1		:=xFilial('SB1')
Public _cFilSB2		:=xFilial('SB2')     
Public aInd 	   	:= {}            								//INDICE DO FILTRO 
Public bFiltraBrw 	:= {|| Nil}                           	//MONTAGEM DO FILTRO 


DbSelectArea('SB2')
DbSetOrder(1)	//B2_FILIAL+B2_COD+B2_LOCAL
DbGoTop() 			
DbSelectArea('SB1')
DbSetOrder(1)//B1_FILIAL+B1_COD
DbGoTop()

//+-------------------------+
//|CONTROLE                 |
//+-------------------------+   
Private lInvert	:=.F.													//INVERTE
Private cCampo		:='B1_OK'											//CAMPO DE OK
Private cMarca		:=GetMark(,"SB1","B1_OK")						//MARCA  

								
Private cCadastro	:= 'Limpeza de Empenhos'						//TITULO
Private aRotina 	:={{"Pesquisar"	,"AxPesqui",0,1} ,;   	//ROTINAS
         			    {"Processar"	,"U_LEMP02",0,3}	,;
         			    {"Imprimir"	,"U_LEMP03",0,4}}
         			    
Public  _cProds	    := ''														//PRODUTOS COM EMPENHOS
Public  cCondicao	:="B1_COD  $ _cProds"							//CONDICAO DO FILTRO

//+-------------------------+
//|PARAMETROS               |
//+-------------------------+
Private aParam		:={	0	,;											//PARAMETROS
								''	,;
								''	,;
								''	}												
EpaPerg()																	//CHAMA OS PARAMETROS
SetKey(VK_F12,{||EpaPerg()})								 			//DEFINE A TECLA F12 PARA CHAMADA DOS PARAMETROS












//+=====================================================+
//|PROGRAMA PRINCIPAL                                   |
//+=====================================================+

Processa( {|| Filtra(cCondicao,_cAliasSB1)}, "Aguarde Filtrando Tabela....") //FAZENDO FILTRO
MARKBROW(_cAliasSB1,cCampo,,,lInvert,cMarca,'U_MarkAll()',,,,'U_GrvMark()')	//MARKBROW
EndFilBrw(_cAliasSB1,aInd)																		//REMOVENDO FILTRO



//+=====================================================+
//|FIM                                                  |
//+=====================================================+
RETURN    







 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLPEMP02   บAutor  ณDANIEL              บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a limpeza do empenho                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Estoque/Custos - LEMP01                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION LEMP02 
//+---------------------------------------------+
//| Declaracao de Variaveis                     |                        
//+---------------------------------------------+
Private lShow	:=aParam[1]
Private aArea	:=GetArea()

//+---------------------+
//|Processando          |
//+---------------------+
DbSelectArea("SB1")
DBGOTOP()

While !eof() 
	IF  SB1->B1_OK=cMarca
		DbselectArea("SB2")  
		//+----------------------------+
		//|PROCURANDO PRODUTO NO SB2   |
		//+----------------------------+	
		If Dbseek(_cFilSB2+SB1->B1_COD+SB1->B1_LOCPAD)
			//+-------------------------------------------+
			//|SE A QUANTIDADE EMPENHADA FOR DIFERENTE    |
			//|DE 0 PROCESSO O REGISTRO                   |
			//+-------------------------------------------+		
			If B2_QEMPSA<>0
				//+------------------------------------+
				//|VERIFICANDO SE MOSTRO A TELA DE     |
				//|EMPENHO                             |
				//+------------------------------------+			
				If lShow=1                                                              
					//+------------------------------------+
					//|VERIFICO SE O USUARIO QUER REALMENTE|
					//|PROCESSAR O REGISTRO                |
					//+------------------------------------+				
			   	If MntScr(SB1->B1_COD,SB1->B1_DESC,SB2->B2_QEMPSA,SB2->B2_LOCAL,SB2->B2_QATU)  		   	 	
				     RecLock("SB2",.F.)
				     	Replace B2_QEMPSA With 0
				     SB2->(Msunlock())
				   EndIf 
				Else
					RecLock("SB2",.F.)
				   		Replace B2_QEMPSA With 0
				   	SB2->(Msunlock())
			   EndIf  
			Else
				MsgInfo("Produto "+SB2->B2_COD+" Sem empenho.")
			EndIf				
		EndIf	
		DbselectArea("SB1")              
		lInvert:=.F.			//invertendo a selecao
	EndIf                                         
	DBSKIP()
End            
MarkBRefresh()				//Faz Refresh 
RestArea(aArea)			//Volta a Area

RETURN

   










/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEPAPERG   บAutor  ณDANIEL              บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta as perguntas                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function EpaPerg()
	Pergunte("LEMP01",.T.)
	aParam[1]:=MV_PAR01
	aParam[2]:=MV_PAR02
	aParam[3]:=MV_PAR03
	aParam[4]:=MV_PAR04
Return

   






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLPEMP01   บAutor  ณDANIEL              บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz filtro no na tabela                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Filtra(_cCond,_cAlias)  
Local _aArea	:= GetArea() // Inserido em 03/12/07 por Celso Costa
Local _cQuery	:= "" // Inserido em 03/12/07 por Celso Costa
 
//+-----------------------------------------+
//|Mondanto os Produtos apenas com Empenho  |
//+-----------------------------------------+
EndFilBrw( _cAliasSB1, aInd )

_cQuery := "SELECT DISTINCT B2_COD, B2_QEMPSA " // Inserido em 03/12/07 por Celso Costa
_cQuery += "FROM " + RetSqlName( "SB2" ) + " " // Inserido em 03/12/07 por Celso Costa
_cQuery += "WHERE B2_QEMPSA <> 00 " // Inserido em 03/12/07 por Celso Costa
_cQuery += "AND B2_FILIAL = '" + xFilial( "SB2" ) + "' " // Inserido em 03/12/07 por Celso Costa
_cQuery += "AND D_E_L_E_T_ = '' " // Inserido em 03/12/07 por Celso Costa
_cQuery += "ORDER BY B2_COD" // Inserido em 03/12/07 por Celso Costa

//DbselectArea("SB2") // Comentado em 03/12/07 por Celso Costa 
//ProcRegua(Reccount()) // Comentado em 03/12/07 por Celso Costa 

_cQuery := ChangeQuery( _cQuery ) // Inserido em 03/12/07 por Celso Costa

dbUseArea( .T., "TOPCONN", TCGenQry( ,, _cQuery ), "QRYTMP", .F., .T. ) // Inserido em 03/12/07 por Celso Costa

ProcRegua( LastRec() ) // Inserido em 03/12/07 por Celso Costa

While QRYTMP->( !Eof() )

	IncProc()

//	If B2_QEMPSA<>0 // Comentado em 03/12/07 por Celso Costa 
//	_cProds+='|'+B2_COD // Comentado em 03/12/07 por Celso Costa 
//	EndIf	 // Comentado em 03/12/07 por Celso Costa 
   //	_cProds += '|' + RTRIM(LTRIM(QRYTMP->B2_COD)) // Inserido em 03/12/07 por Celso Costa
   if Len(_cProds) < 1500      &&Mauricio 09/03/11 - Limitado tamanho da string em fun็ใo de problema no sistema com rela็ใo ao filtro(tamanho maior que 2000bytes)
      _cProds += '|' + QRYTMP->B2_COD
   Endif   
      //_cProds += "'" + QRYTMP->B2_COD + "',"      
//	DbSkip() // Comentado em 03/12/07 por Celso Costa 

	QRYTMP->( dbSkip() ) // Inserido em 03/12/07 por Celso Costa
	
EndDo

QRYTMP->( dbCloseArea() ) // Inserido em 03/12/07 por Celso Costa

RestArea( _aArea ) // Inserido em 03/12/07 por Celso Costa

dbselectArea( _cAlias )

//+-----------------------------------------+
//|Mondanto os Produtos apenas com Empenho  |
//+-----------------------------------------+
EndFilBrw( _cAliasSB1, aInd )

bFiltraBrw := {|| FilBrowse( _cAlias, aInd,@_cCond ) }   
Eval( bFiltraBrw )


Return










/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGrvMark   บAutor  ณMicrosiga           บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Marca o registro                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER Function GrvMark()
	DbSelectArea('SB1')
	If IsMark( 'B1_OK', cMarca )  
	    RecLock( 'SB1', .F. )
			Replace B1_OK With Space(2)		
		SB1->(MsUnLock())
		lInvert	:=.F.	
	Else
		RecLock( 'SB1', .F. )
			Replace B1_OK With cMarca
		SB1->(MsUnLock())
		lInvert	:=.T.	
	EndIf 
	MarkBRefresh()
Return
 












/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMackAll() บAutor  ณMicrosiga           บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a macacao de todos os registros                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER Function MarkAll()
	Local nRecno := Recno()
	dbSelectArea('SB1')
	dbGotop()
	While !Eof()
		If IsMark( 'B1_OK', cMarca )
			RecLock( 'SB1', .F. )
				Replace B1_OK With Space(2)
			SB1->(MsUnLock())
		Else
			RecLock( 'SB1', .F. )
				Replace B1_OK With cMarca
			SB1->(MsUnLock())
		EndIf 
		dbSkip()		
	End
	dbGoto( nRecno )
	MarkBRefresh()
Return                  














/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMNTSCR    บAutor  ณDANIEL              บ Data ณ  03/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela de visualizacao dos produtos                     บฑฑ
ฑฑบ          ณCod    - Codigo do produto                                  บฑฑ
ฑฑบ          ณDesc   - Descricao do produto                               บฑฑ
ฑฑบ          ณEmpSa  - Qtd Empenhada                                      บฑฑ
ฑฑบ          ณxLocal - Local no Almoxarifado                              บฑฑ
ฑฑบ          ณSdl    - Saldo                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MntScr(Cod,Desc,EmpSa,xLocal,Sdl)      
//+-----------------------------------------------------+
//|Declaracao de Variaveis                              |
//+-----------------------------------------------------+
Local lRet		:=.T.										//RETORNO INDICA SE DEVE CONTINUAR OU NAO
Local bOk		:={|| lRet:=.T., _odlg:end()}	//ACAO DO BOTAO OK
Local bCancel  :={|| lRet:=.F., _odlg:end()}	//ACAO DO BOTAO CANCELA          


DEFINE MSDIALOG _oDlg TITLE "Produto:"+Cod+" - "+Desc+"" FROM (254),(362) TO (427),(741) PIXEL

	// Cria as Groups do Sistema
	@ (005),(000) TO (070),(188) LABEL "Empenho" PIXEL OF _oDlg

	// Cria Componentes Padroes do Sistema
	@ (020),(005) Say "Saldo:" 								Size (017),(008) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ (020),(040) Say Sdl 										Size (041),(008) COLOR CLR_BLACK 	PIXEL OF _oDlg
	@ (045),(005) Say "Empenhado:" 							Size (032),(008) COLOR CLR_BLUE 	 	PIXEL OF _oDlg
	@ (045),(040) Say EmpSa 									Size (026),(008) COLOR CLR_BLUE	 	PIXEL OF _oDlg
	@ (045),(090) Say "Almoxarifado:" 						Size (033),(008) COLOR CLR_BLACK		PIXEL OF _oDlg
	@ (045),(130) Say xLocal 									Size (011),(008) COLOR CLR_BLACK 	PIXEL OF _oDlg
	DEFINE SBUTTON FROM (075),(130) TYPE 2 ENABLE OF _oDlg ACTION (EVAL(bCancel))
	DEFINE SBUTTON FROM (075),(163) TYPE 1 ENABLE OF _oDlg ACTION (EVAL(bOk))


ACTIVATE MSDIALOG _oDlg CENTERED 
Return(lRet)    

 
















/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLEMP03    บAutor  ณDANIEL              บ Data ณ  03/28/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIMPRIME A TELA ATUAL FILTRADA                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION LEMP03

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo       	:= "RELACAO DE PRODUTOS EMPENHADOS"
Local nLin         	:= 80

Local Cabec1       	:=	""
Local Cabec2       	:= ""
Local imprime      	:= .T.
Local aOrd 				:= {"Codigo","Tipo + Codigo","Descricao + Codigo"}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "LEMP03" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt      	:= Space(10)
Private cbcont     	:= 00
Private CONTFL     	:= 01
Private m_pag      	:= 01
Private wnrel      	:= DTOS(DDATABASE) // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString 		:= "SB1"
//+----------------------------------+
//|VARIAVEIS                         |  
//+----------------------------------+
Private nSaldo		:=0		//SALDO
Private nEmpenho	:=0  		//QTD EMPENHO DA SA
Private cVez		:='S'		//PRIMEIRA VEZ

dbSelectArea("SB1")
dbSetOrder(1)          


//+------------------------------------+
//|CABECALHO                           |
//+------------------------------------+
/*
__________________________________________________________________________________________________________________

PRODUTO:     XXXXXX             DESCRICAO: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  LOCAL:    XX
SALDO FISICO XXX,XXX,XXX,XXX.XX EMPENHADO: XXX,XXX,XXX,XXX.XX                    ENDERECO: XXXXXXXXXXXXXXXXXXXX
TIPO:        XX                 UNIDADE:   XX
__________________________________________________________________________________________________________________
01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          1         2         3         4         5         6         7         8         9        10        11        12        13
*/

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  28/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nOrdem                                        

//+--------------------------------------------+
//|Mudando a ordem pela escolhida do usuario   |
//+--------------------------------------------+
dbSelectArea(cString)
dbSetOrder( aReturn[8])	//RETORNO DA ORDENACAO

//+------------------------------------+
//|Filtro do Usuario                   |
//+------------------------------------+  

cFilterUser :=aReturn[7]
If !Empty(cFilterUser)
	cFilterUser:="!eof() .and. "+cFilterUser
Else	                                     
	cFilterUser:="!eof() "
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(RecCount())


dbGoTop()
While &cFilterUser

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If nLin > 58 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif 
	//+----------------------------+
	//|PROCURANDO PRODUTO NO SB2   |
	//+----------------------------+	  
  	DbselectArea("SB2")  
	If Dbseek(_cFilSB2+SB1->B1_COD+SB1->B1_LOCPAD)
		nSaldo	:=B2_QATU  		   	 	
		nEmpenho	:=B2_QEMPSA 
	Else 
		nSaldo	:=0
		nEmpenho	:=0
	EndIf                
	DbSelectArea("SB1")
   
	If cVez=='N'
		@nlin,000 Psay Replicate("_",Limite); nLin++	
	Else
		cVez:='N'
	EndIf
	
	//+------------------------------------------------------------------------------+
	//|                         I M P R I M I N D O                                  |
	//+------------------------------------------------------------------------------+
    @nlin,000 PSAY "PRODUTO:" 		;	@nLin,013 PSAY SB1->B1_COD
	@nLin,032 PSAY "DESCRICAO:"  	;	@nLin,043 PSAY SB1->B1_DESC
	@nLin,081 PSAY "LOCAL:"			;	@nlin,091 PSAY SB1->B1_LOCPAD
	nLin++
	
	@nlin,000 PSAY "SALDO FISICO"	;	@nLin,013 PSAY nSaldo
	@nLin,032 PSAY "EMPENHADO:"  	;	@nLin,043 PSAY nEmpenho
	if cfilant == "03"
	   @nLin,081 PSAY "ENDERECO:"		;	@nlin,091 PSAY SB1->B1_ENDALM2
	else   
	   @nLin,081 PSAY "ENDERECO:"		;	@nlin,091 PSAY SB1->B1_ENDALM
	endif   
	nLin++ 
	@nlin,000 PSAY "TIPO:"			;	@nLin,013 PSAY SB1->B1_TIPO
	@nLin,032 PSAY "UNIDADE:"  	;	@nLin,043 PSAY SB1->B1_UM
	nLin++	

   dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo


@nlin,000 Psay Replicate("_",Limite)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
//+---------------------+
//|RETORNANDO AMBIENTE  |
//|ANTERIOR             |
//+---------------------+
EndFilBrw(_cAliasSB1,aInd)	
bFiltraBrw := {|| FilBrowse(_cAliasSB1,@aInd,@cCondicao)}
Eval(bFiltraBrw)

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
RETURN
