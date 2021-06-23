#include "rwmake.ch"
#include "topconn.ch"
/*/{Protheus.doc} User Function ADIMPDA1
	Importacao de precos de arquivo texto para tabela DA1 -  
	Itens da Tabela de Precos.
	DA0/DA1
	Comercial - Adoro 
	@type  Function
	@author ADRIANA - HC
	@since 27/10/2010
	@version 01
	@history Everson, 28/07/2020, Chamado 059906. Tratamento de error log.
	/*/
User Function ADIMPDA1()
	Local cCRLF:=CHR(13)+CHR(10), cCRLF2:=CHR(13)+CHR(10)+CHR(13)+CHR(10)
	Local _cProduto, _nPrecoRs, _nPrecoOl, _cFileLog, _cPath, _lArqOk

	Private _cTabela := ""
	Private _aNome := {}
	Private _aTipo := {}
	Private _aDado := {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de precos de arquivo texto para tabela DA1 - Itens da Tabela de Precos')
	/*LAYOUT DO ARQUIVO CSV OU TXT A SER IMPORTADO:

	Delimitado por ";", com 1 linha de cabecalho

	1= Cod. Produto 	(Tipo Caracter)
	2= Preco Venda 		(Tipo Numerico, com 2 decimais, mascara 999999,99)
	3= Preco Supervisor	(Tipo Numerico, com 2 decimais, mascara 999999,99)
	4= Preco Gerente	(Tipo Numerico, com 2 decimais, mascara 999999,99)

	Exemplo:
	ZZ0
	COD;DA1_XPRLIQ
	184474;4,85
	185498;5,25
	185499;5,15
	*/

	_nTamLin 	:= 42            		// Tamanho da linha no arquivo texto
	_nHdl    	:= Nil           		// Handle para abertura do arquivo
	_cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
	_nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
	_cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
	_cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
	_nQtChar 	:= 2
	_cDelimit	:= ";"                 //Delimitador do arquivo CSV      
	_cCodTab    := "'"


	_cPerg		:= PADR("ADIMPDA1",10," ")
	ValidPerg()

	if Pergunte(_cPerg,.T.)
	/*
		//incluido ana 01/02/11
		For i:=1 to len(Alltrim(MV_PAR03))
			If substr(Alltrim(MV_PAR03),i,1)  == ","
				_cCodTab += "','"         
			Else 
				_cCodTab += substr(Alltrim(MV_PAR03),i,1)		
			Endif
		Next
		_cCodTab += "'"

		_cArq    	:= MV_PAR01      		// Arquivo texto a importar
		_cFiliais	:= Alltrim(MV_PAR02)	// Filiais a serem atualizadas
		_cQuery := "SELECT DA0_FILIAL, DA0_CODTAB, DA0_PERTXT "
		_cQuery += "FROM "+retsqlname("DA0")+" "
		_cQuery += "WHERE DA0_FILIAL IN ("+_cFiliais+") AND "
		_cQuery += "DA0_IMPTXT = '1' AND "
		_cQuery += "DA0_CODTAB IN ("+ Alltrim(_cCodTab)+ ") AND " //Incluido 31/01/11 Ana
		_cQuery += "D_E_L_E_T_= '' "
		_cQuery += "ORDER BY DA0_FILIAL, DA0_CODTAB "
		
		TCQUERY _cQuery new alias "XDA0"
		DbSelectArea("XDA0")
		
		_cMsg := ""
		While !XDA0->(Eof())
			_cMsg += XDA0->DA0_CODTAB+" com "+Transform(XDA0->DA0_PERTXT,"@R 99%")+CHR(13)
			DbSkip()
		end
		
		If MsgBox(OemToAnsi("Confirma importação de Valores do arquivo "+Alltrim(_cArq)+" para as Tabelas de Preços: ")+CHR(13)+_cMsg,"ATENCAO","YESNO")
			_nHdl := fOpen(_cArq,2) // Abre o arquivo
			fClose(_nHdl)
			If _nHdl == -1
				Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
			else
				Processa({|| RunImpTXT()})
			endif
		endif
		DbSelectArea("XDA0")
		DbCloseArea()
	*/	
		Processa( {|| LeArqCSV()},"Lendo Arquivo .... " + MV_PAR01)
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
				If DA1->(DBSeek( Alltrim(cValToChar(CFILANT)) + Alltrim(cValToChar(_cTabela))+ Alltrim(cValToChar(_cProduto)) )) //Everson - 28/07/2020. Chamado 059906.
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
				
				//Everson - 15/03/2018. SalesForce.
				If FindFunction("U_ADVEN073P") .And. MsgYesNo("Deseja enviar as informações ao SalesForce.","Função ADIMPDA1")
					U_ADVEN073P( DToS(Date()), DToS(Date()),.F.)
				
				EndIf
				
				MostraErro(_cPath,_cFileLog)
				Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!")+"Arquivo gravado em:"+_cPath+_cFileLog,{"Sair"} )
			else		
				MostraErro(_cPath,_cFileLog)
				Aviso( OemToAnsi("ATENÇÃO"),OemToAnsi("Arquivo Importado com ERROS. Verifique em: ")+cCRLF2+_cPath+_cFileLog,{"Sair"} )
			Endif			
		Endif
	Endif

Return
/*/{Protheus.doc} RunImpTXT
	Executa rotina de importacao com regua de processamento.
	@type  Static Function
	@author ADRIANA - HC 
	@since 27/10/2010
	@version 01
	/*/
/*
Static Function RunImpTXT()
	_lArqOK := .t.

	AutoGrLog("LOG IMPORTACAO DE PRECOS")
	AutoGrLog("--------------------------------------------------------------------------------")
	AutoGrLog(" ")

	Dbgotop()

	ft_fUse(_cArq) 	//Abre o arquivo

	ProcRegua(RecCount())
	While !XDA0->(Eof())
		_cFilial := XDA0->DA0_FILIAL
		_cCodTab := XDA0->DA0_CODTAB
		_nPerTXT := XDA0->DA0_PERTXT
		
		IncProc(" Filial: " + _cFilial+" - Tabela: "+_cCodTab )
		
		ft_fGoTop()		//Posiciona no inicio do arquivo
		ft_fSkip()		//Pula a primeira linha (cabecalho)
		_nLin := 2      //1 && se nao tiver cabecalho
		
		Do While !ft_fEOF()
			_cBuffer := ft_fReadLn()
			_cBuffer := StrTran(_cBuffer,".","")
			_nCmp := 1
			
			Do While Rat(_cDelimit, _cBuffer) > 0
				_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
				if _nCmp = 1		//Codigo de produto
					_cCod    := PadR(_cTxtPos,15)
				elseif _nCmp = 2   //Preco de Venda
					_nPrcVen := Val(StrTran(_cTxtPos,",","."))
				elseif _nCmp = 3   //Preco de Supervisor
					_nPrcSup := Val(StrTran(_cTxtPos,",","."))
				endif
				_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
				_nCmp++
			EndDo
			// Ultimo campo && Preco de Gerente
			_nPrcGer := Val(StrTran(_cBuffer,",","."))
			
			dbselectarea("DA1")
			dbsetorder(1)
			if !dbseek(_cFilial+_cCodTab+_cCod)
				
				AutoGrLog("Linha "+StrZero(_nlin,5)+"-> Filial "+_cFilial+", Tabela "+_cCodTab+", Cod. Produto "+AllTrim(_cCod)+" nao encontrado.")
				_lArqOk := .f.
				
			else
				
				if _nPerTXT > 0
					_nPrcVen := Round(_nPrcVen * (1+(_nPerTXT/100)),2)
					_nPrcSup := Round(_nPrcSup * (1+(_nPerTXT/100)),2)
					_nPrcGer := Round(_nPrcGer * (1+(_nPerTXT/100)),2)
				endif
				
				if Reclock("DA1",.f.)
					DA1->DA1_PRCVEN	:= _nPrcVen
					DA1->DA1_PRCSUP	:= _nPrcSup
					DA1->DA1_PRCGER	:= _nPrcGer
					Msunlock()
				else
					AutoGrLog("Linha "+strzero(_nlin,5)+"-> Filial "+_cFilial+", Tabela "+_cCodTab+", Cod. Produto "+AllTrim(_cCod)+" nao conseguiu gravar (LOCK).")
					lArqOk := .f.
				endif
				
			endif
			
			ft_fSkip()
			_nLin ++
		end
		
		DbSelectArea("XDA0")
		DbSkip()
	End

	_cFileLog := Left(_cArq,At(".",_cArq)-1)+".LOG"
	_cFileLog := Alltrim(Substr(_cFileLog,RAt("\",_cFileLog)+1,20))
	_cPath    := Substr(_cArq,1,RAt("\",_cArq))

	if !_lArqOk
		MostraErro(_cPath,_cFileLog)
		Aviso( OemToAnsi("ATENÇÃO"),OemToAnsi("Arquivo Importado com ERROS. Verifique em ")+_cPath+_cFileLog,{"Sair"} )
	else
		Aviso( "Aviso",OemToAnsi("Importação realizada com sucesso!"),{"Sair"} )
	Endif

Return
*/
/*/{Protheus.doc} VALIDPERG
	@type  Static Function
	@author ADRIANA - HC 
	@since 27/10/2010
	@version 01
	/*/
Static Function ValidPerg

	PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")
	//PutSx1(_cPerg,"02","Seleciona Filiais"    , "Seleciona Filiais"    , "Seleciona Filiais"    , "mv_ch2","C",50,0,0,"G","U_FXFIL()","","","","mv_par02","","","","","","","","","","","","","","","","","","","")

Return
/*/{Protheus.doc} ValTabPre
	@type  Static Function
	@author ANA 
	@since 03/02/2011
	@version 01
	/*/
/*    
//Incluido 03/02/11 - ANA
User Function ValTabPre()

	Local cTitulo:=""
	Local MvPar
	Local MvParDef:=""
	Local nTam := 3 
	Local nX := 0
	Local nLen := 0

	Private aGrupo:={}

	cAlias := Alias() 					 // Salva Alias Anterior

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	dbSelectArea("DA0")
	DbGotop()
	CursorWait()
			While !Eof() 
				Aadd(aGrupo,DA0->DA0_CODTAB + " - " + Alltrim(DA0->DA0_DESCRI))
				MvParDef+=DA0->DA0_CODTAB
				dbSkip()
			Enddo
	CursorArrow()
							

	IF f_Opcoes(@MvPar,"Tabelas",aGrupo,MvParDef,12,49,.F., nTam, Len(aGrupo))  // Chama funcao f_Opcoes

		mvpar := StrTran(mvpar, "*", "")
		nLen := Len(mvpar)-1

		For nX := 0 To nLen Step nTam
			mvpar := SubStr(mvpar, 1, nX+nTam+Int(nX/nTam))+","+SubStr(mvpar, nX+nTam+Int(nX/nTam)+1, Len(mvpar))
		Next nX
		
		_nTam := LEN(MVPAR)
		MVPAR := SUBSTR(MVPAR,1,_nTAM-1)
		
		&MvRet := mvpar                                                                          // Devolve Resultado

	EndIF	

	dbSelectArea(cAlias) 								 // Retorna Alias

Return MvParDef
*/
/*/{Protheus.doc} LeArqCSV
	@type  Static Function
	@author  
	@since 03/02/2011
	@version 01
	/*/
Static Function LeArqCSV()
	Local _nTamLin							// Tamanho da linha no arquivo texto
	Local _nHdl    	:= Nil           		// Handle para abertura do arquivo
	Local _cBuffer							// Variavel para leitura
	Local _cDelimit	:= ";"                 //Delimitador do arquivo CSV      
	Local _cArq    	:= MV_PAR01
	Local _nLin     := 1
	Local _nTamanA

	_nHdl := fOpen(_cArq,2) // Abre o arquivo
	fClose(_nHdl)
	If _nHdl == -1
		Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
	endif                          

	ft_fUse(_cArq) 	//Abre o arquivo
	ProcRegua(RecCount())
	ft_fGoTop()		//Posiciona no inicio do arquivo

	Do While !ft_fEOF()
		_cBuffer := ft_fReadLn()
		IncProc(" Linha: " + STR(_nLin,5,0) )
		//_cBuffer := StrTran(_cBuffer,".","")	
		_nCmp := 1
		If _nLin > 1
			Do While Rat(_cDelimit, _cBuffer) > 0
				_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
						
				if _nLin == 2
					Aadd(_aNome)
					_aNome[Len(_aNome)] := _cTxtPos
				endif
				if _nLin == 3
					Aadd(_aTipo)
					_aTipo[Len(_aTipo)] := _cTxtPos
				endif
				if _nLin > 3
					If _aTipo[_nCmp] = "Caracter"
						_aDado[_nLin - 3, _nCmp] := _cTxtPos
					else 
						If _aTipo[_nCmp] = "Numerico"
							_cTxtPos := StrTran(_cTxtPos,".","")
							_cTxtPos := StrTran(_cTxtPos,",",".")
							_aDado[_nLin - 3, _nCmp] := Val(_cTxtPos)
						endif
					endif
					_nCmp ++
				endif
		
				_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			EndDo
			// último campo
			if _nLin == 2
				Asize(_aNome, Len(_aNome) + 1)
				_aNome[Len(_aNome)] := _cBuffer
			endif
			if _nLin == 3
				Asize(_aTipo, Len(_aTipo) + 1)
				_aTipo[Len(_aTipo)] := _cBuffer
				_aDado := Array(1, Len(_aTipo))
			endif
			if _nLin > 3
					//_aDado[_nLin - 3, _nCmp] := _cBuffer
					If _aTipo[_nCmp] = "Caracter"
						_aDado[_nLin - 3, _nCmp] := _cBuffer
					else 
						If _aTipo[_nCmp] = "Numerico"
							_cBuffer := StrTran(_cBuffer,".","")
							_cBuffer := StrTran(_cBuffer,",",".")
							_aDado[_nLin - 3, _nCmp] := Val(_cBuffer)
						endif
					endif
					Aadd(_aDado, { "", 0 } )
					/*
					for _nInd = 1 to Len(_aTipo)
						If _aTipo[_nInd] = "Caracter"
							_aDado[_nLin - 2, _nInd] := ""
						endif
						If _aTipo[_nInd] = "Numerico"
							_aDado[_nLin - 2, _nInd] := 0
						endif
					endfor
					*/
			endif
		Else
			If _nLin == 1
				_cTabela := Alltrim(_cBuffer)
			EndIf
		Endif
		
		ft_fSkip()		//Pula linha
		_nLin ++
	EndDo
	_nTamanA := Len(_aDado)         // exclui o último que foi criado indevidamente
	If _aDado[_nTamanA,1] = "" .And. _aDado[_nTamanA,2] = 0
		ASize(_aDado, _nTamanA - 1)
	Endif
Return
