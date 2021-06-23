#include "Protheus.ch"
#include "rwmake.ch"

/*{Protheus.doc} User Function GERAP3
	Importacao de preço para tabela Matriz
	@type  Function
	@author Mauricio
	@since 07/03/2012
	@version 01
	@history Chamado 057846 - William Costa - 06/05/2020 - Retirado toda a referencia ao campo B1_ATIVO ou B1_ATIVO1
*/

User Function IMPTBMAT()

	Local cCRLF:=CHR(13)+CHR(10), cCRLF2:=CHR(13)+CHR(10)+CHR(13)+CHR(10)
	Local _cProduto, _nPrecoRs, _nPrecoOl, _cFileLog, _cPath, _lArqOk
	Private _cTabela := ""
	Private _aNome := {}
	Private _aTipo := {}
	Private _aDado := {}
	/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO conforme definido com o usuario:

	Delimitado por ";", com 1 linha de cabecalho
	Primeira linha sempre eh cabecalho  CODIGO,PRECO,A01,B01,C01,CMS,D01,E01,V00
	*/

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de preço para tabela Matriz')

	_nTamLin 	:= 200            		
	_nHdl    	:= Nil           		
	_cBuffer 	:= Space(_nTamLin+1) 	
	_nBytes  	:= 0                	
	_cDelimit	:= ";"                  
	_cPath      := ""
	_cPerg		:= PADR("IMPTBM",10," ")

	ValidPerg()
		
	if Pergunte(_cPerg,.T.)
		_cArq    	:= MV_PAR01      		
																								
		If MsgBox(OemToAnsi("Confirma importação para tabela Matriz do arquivo "+Alltrim(_cArq)+""),"ATENCAO","YESNO")
			_nHdl := fOpen(_cArq,2) 
			fClose(_nHdl)
			
			If _nHdl == -1
				Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
			else
				Processa({|| ImpTXTTB()})
			endif
			
		endif
	Endif

Return()

Static Function ImpTXTTB()

	_cProduto := ""
	_nPreco   := 0.00
	_nPer1    := 0.0000
	_aEstrPro := {}
	_lcont    := .T.
	_lret     := .T.

	Dbgotop()

	ft_fUse(_cArq)

	ProcRegua(RecCount())

	ft_fGoTop()
	_nLin := 1
	_aTab := {}

	AutoGrLog("LOG ALTERACAO IMPORTACAO TABELA MATRIZ")
	AutoGrLog("--------------------------------------")
	AutoGrLog(" ")
	AutoGrLog(" ")
	Do While !ft_fEOF()
		_arqOk   := .T.
		_cBuffer := ft_fReadLn()
		_nCmp    := 1
		
		If _nLin == 1
		_ntot := 2
		_nfim := 0
		For _x := 1 to len(_cBuffer)
			//conto aqui total de colunas relativas as tabelas de preco e associo cada coluna a uma tabela de preço
			if _nFim > 0
				exit
			endif    	       	       
			if ";" $ _cBuffer
				_cCab := Alltrim(Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1))	          
				If _x >= 3
					AADD(_aTab,_cCab)
				Endif 	          	        	            
				_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			Else
				_cCab := Alltrim(_cBuffer)                    
				AADD(_aTab,_cCab)
				_nfim ++
			endif   
		next
		
	_nTotCol := 2 + Len(_aTab)   //Totais de tabelas no arquivo
		
		_aTabDA0 := {}

		dbSelectArea("DA0")
		dbSetOrder(1)
		dbseek(cfilant)

		While DA0->(!Eof()) .And. DA0->DA0_FILIAL == cFilAnt  //pego as tabela da filial corrente aonde o programa esta sendo rodado(Assumimos que as filiais estão iguais)
				AADD(_aTabDA0,ALLTRIM(DA0->DA0_CODTAB))
				DA0->(dbSkip())
		EndDo
		
		_aColTab := {}
		
		for _y := 1 to len(_aTab)
			_cTab := _aTab[_y]
			//_nPos := Ascan(_aTabDA0, &_cTab ) //Retorna a posição da tabela na sequencia do cadastro de tabelas para alimentar a tabela ZZ
			_nPos := Ascan(_aTabDA0,_cTab) //Retorna a posição da tabela na sequencia do cadastro de tabelas para alimentar a tabela ZZ
			AADD(_aColTab,{_cTab,_nPos})                           //na mesma sequencia.	   
		next _y
			
		ft_fSkip()
		_nLin ++
			loop
		Endif
			
		for _i := 1 to _nTotCol
			_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
			_nVar := "_nQTD"+ALLTRIM(STR(_i))
			if _i = 1
				_cProduto    := _cTxtPos
			elseif _i = 2
				_nPreco := Val(StrTran(_cBuffer,",","."))
			else
				&_nVar := Val(StrTran(_cBuffer,",","."))
			endif		
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			_nCmp++
		next
		
		IncProc("Importando...")
		_aValLog := {}
		DbSelectArea("ZZK")
		DbSetOrder(1)
		if dbseek("02"+_cProduto)
		_nPrcAnt := ZZK->ZZK_PRBASE	   
		RecLock("ZZK",.F.)
			ZZK->ZZK_PRBASE := _nPreco             
			_t := 3	         
			For _zz := 1 to len(_aColTab)	        
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]	         
				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos))	         
				//filial, produto, fob anterior, fob atual, tabela,preco atual, preco anterior,coeficiente atual, coeficiente anterior.
				AADD(_aValLog,{"02",_cProduto,_nPrcAnt,_nPreco,_aColTab[_zz][1],&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2,Substr(ZZK->ZZK_DESCRI,1,40)})	         	          	          
				ZZK->&_cCpo1 := &_cVar2                         
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)              
				_t ++
			next
		MsUnlock()
		Else  
			_cBloqueado :=Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_MSBLQL")
			
			If _cBloqueado <> "1"
			RecLock("ZZK",.T.)
			ZZK->ZZK_FILIAL := "02"
			ZZK->ZZK_PRODUT := _cProduto
			ZZK->ZZK_PRBASE := _nPreco
			ZZK->ZZK_DESCRI := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_DESC")
			ZZK->ZZK_UNIDAD := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_UM")
			_nPrcAnt := 0	     
			_t := 3
			For _zz := 1 to len(_aColTab)
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]


				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos))
	//	          AADD(_aValLog,{"02",_cProduto,_aColTab[_zz][1],_nPrcAnt,_nPreco,&_cVar2,0,_nPreco *(&_cVar2),0,_nPreco *(&_cVar2),Substr(ZZK->ZZK_DESCRI,1,40)})  
				AADD(_aValLog,{"02",Alltrim(_cProduto)+"*",_nPrcAnt,_nPreco,_aColTab[_zz][1],&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2,Substr(ZZK->ZZK_DESCRI,1,40)})	         	          	          
				ZZK->&_cCpo1 := &_cVar2
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)
				_t ++
			next
			MsUnlock()          
		else    
				AADD(_aValLog,{"02",_cProduto,0,0,"O produto esta inativo no cadastro B1_MSBLQL="+_cBloqueado,0,0,0,0," ----> NAO IMPORTADO !!!"})	         	          	          
		endif
		Endif
		DbSelectArea("ZZK")
		dbGotop()
		if dbseek("06"+_cProduto)
		_nPrcAnt := ZZK->ZZK_PRBASE
		RecLock("ZZK",.F.)
			ZZK->ZZK_PRBASE := _nPreco
			_t := 3	     
			For _zz := 1 to len(_aColTab)
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]
				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos))
				//AADD(_aValLog,{"06",_aColTab[_zz][1],_nPrcAnt,_nPreco,&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2}) 
				ZZK->&_cCpo1 := &_cVar2
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)
				_t ++
			next
		MsUnlock()
		Else
		RecLock("ZZK",.T.)
			ZZK->ZZK_FILIAL := "06"
			ZZK->ZZK_PRODUT := _cProduto
			ZZK->ZZK_PRBASE := _nPreco
			ZZK->ZZK_DESCRI := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_DESC")
			ZZK->ZZK_UNIDAD := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_UM")
			_nPrcAnt := 0	 
			_t := 3
			For _zz := 1 to len(_aColTab)
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]
				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos ))
				//AADD(_aValLog,{"06",_aColTab[_zz][1],_nPrcAnt,_nPreco,&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2}) 
				ZZK->&_cCpo1 := &_cVar2
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)
				_t ++
			next
		MsUnlock()          
		Endif
		DbSelectArea("ZZK")
		dbGotop()
		if dbseek("07"+_cProduto)
		_nPrcAnt := ZZK->ZZK_PRBASE
		RecLock("ZZK",.F.)
			ZZK->ZZK_PRBASE := _nPreco
			_t := 3	     
			For _zz := 1 to len(_aColTab)
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]
				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos))
				//AADD(_aValLog,{"07",_aColTab[_zz][1],_nPrcAnt,_nPreco,&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2}) 
				ZZK->&_cCpo1 := &_cVar2
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)
				_t ++
			next
		MsUnlock()
		Else
		RecLock("ZZK",.T.)
			ZZK->ZZK_FILIAL := "07"
			ZZK->ZZK_PRODUT := _cProduto
			ZZK->ZZK_PRBASE := _nPreco
			ZZK->ZZK_DESCRI := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_DESC")
			ZZK->ZZK_UNIDAD := Posicione('SB1',1,xFilial("SB1")+_cProduto,"B1_UM")
			_nPrcAnt := 0
			_t := 3
			For _zz := 1 to len(_aColTab)
				_cVar2 := "_nQTD"+ALLTRIM(STR(_t))
				_nPos := _aColTab[_zz][2]
				_cCpo1 := "ZZK_COEF"+ALLTRIM(STR(_nPos))
				_cCpo2 := "ZZK_VAL"+ALLTRIM(STR(_nPos ))
				//AADD(_aValLog,{"07",_aColTab[_zz][1],_nPrcAnt,_nPreco,&_cVar2,ZZK->&_cCpo1,_nPreco *(&_cVar2),ZZK->&_cCpo2}) 
				ZZK->&_cCpo1 := &_cVar2
				ZZK->&_cCpo2 := _nPreco *(&_cVar2)
				_t ++
			next
		MsUnlock()          
		Endif
		
		//gero o log
		If len(_aValLog) > 0
		_cLog := ""
		For _ny := 1 to len(_aValLog)
			_cFil := _aValLog[_ny][1]
			If _ny == 1
				_clog += " Produto: "+_aValLog[_ny][2]+" "+_aValLog[_ny][10]+" Preco de: "+transform(_aValLog[_ny][3],"@E 9,999.99")+;
						" para: "+transform(_aValLog[_ny][4],"@E 9,999.99")+" Tab.: "+_aValLog[_ny][5]+" % de: "+transform(_aValLog[_ny][7],"@E 99.9999")+" para: "+transform(_aValLog[_ny][6],"@E 99.9999") 
			Else
				If _aValLog[_ny - 1][2] == _aValLog[_ny][2]
					_cLog += " Tab.: "+_aValLog[_ny][5]+;
							" % de: "+transform(_aValLog[_ny][7],"@E 99.9999")+" para: "+transform(_aValLog[_ny][6],"@E 99.9999") 	             
				Else      
					_cLog += CHR(13)+CHR(10)                            
					_cLog := " Produto: "+_aValLog[_ny][2]+" "+_aValLog[_ny][10]+" Preco de: "+transform(_aValLog[_ny][3],"@E 9,999.99")+;
							" para: "+transform(_aValLog[_ny][4],"@E 9,999.99")+" Tab.: "+_aValLog[_ny][5]+" % de: "+transform(_aValLog[_ny][7],"@E 99.9999")+" para: "+transform(_aValLog[_ny][6],"@E 99.9999")	          
				Endif
			Endif     	          
		Next _ny
		_cLog += CHR(13)+CHR(10) 
		AutoGrLog(_cLog)
			
		Endif
		
		ft_fSkip()
		_nLin ++
		
	End
	_cFileLog := Left(MV_PAR01,At(".",MV_PAR01)-1)+".LOG"
	_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
	_cPath    := Substr(MV_PAR01,1,RAt("\",MV_PAR01))
	MostraErro(_cPath,_cFileLog)	
	msgInfo("Processamento concluido com sucesso!")

Return()

Static Function ValidPerg

	PutSx1(_cPerg,"01","Importar do Arquivo TXT ?", "Importar do Arquivo  TXT ?", "Importar do Arquivo  TXT ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")

Return