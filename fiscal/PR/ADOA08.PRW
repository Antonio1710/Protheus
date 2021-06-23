#Include "Protheus.ch"
#Include "Rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} User Function ADOA08
	CSV - Gera Saldo Poder de terceiros
	@type  Function
	@author hcconsys - heverson
	@since 21.05.08
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	@history 20/12/2018 - WILLIAM COSTA  - 045947 - ADICIONADO CAMPO PRECO UNITARIO
	@history 29/03/2019 - WILLIAM COSTA  - 048192 - ADICIONADO TRES PERGUNTAS
	@history 18/06/2019 - ABEL BABINI    - 049414 - ADICIONADO CENTRO DE CUSTO
	@history 29/10/2019 - ABEL BABINI    - 052892 - ADICIONADO CENTRO DE CUSTO
	/*/

User Function ADOA08()

	//Local cPerg	:= "ADOA08"
	Local cPerg	:= PADR("ADOA08",10," ")

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'CSV - Gera Saldo Poder de terceiros')
	
	ValidPerg(cPerg)
	
	If !Pergunte(cPerg,.T.)
		Return ( .T. )
	EndIf
	
	MsgRun("Aguarde, Gerando Planilha ...","",{|| CursorWait(),GeraSB6(),CursorArrow()})

Return


/**********************/
Static Function GeraSB6()

	Local aStru		:= {}
	Local aRegs		:= {}
	
	
	Local cArq		:= " "
	Local _xFilSB6 	:= xFilial("SB6")   
	Local _xFilSA1 	:= xFilial("SA1")
	Local _xFilSA2 	:= xFilial("SA2")
	Local _xFilSB1 	:= xFilial("SB1")
	Local _xFilSD1 	:= xFilial("SD1")
	Local _cCliFor	:= "" 
	Local _cRazSoc 	:= "" 
	Local cCamposB6 := ""
	Local _seqArq	:= 0
	Local _nSalVal	:= 0         
	Local  _cProduto := "" 
	Local _nSalOri	:= 0         
	Local cArq		:= "SALDO_P3"
	Local aCCusto	:= {} //Ch.049414 - ABEL BABINI - 18/06/2019
	
	//_ProxNum	:= _nProxNum + 1
	
	dbSelectArea("SF2")
	dbSetOrder(1)
	
	                                    
	// MONTA CABECALHO EXCEL
	
	aStru := {	{"FILIAL"		 ,"C",02,0},; // Data do Embarque
				{"CLI_FOR"		 ,"C",06,0},; // Codigo Cliente Fornecedor 
				{"LOJA"			 ,"C",02,0},; // Loja
				{"RAZAO_SOCIAL"	 ,"C",40,0},; // Razao Social 
				{"COD_PRODUTO"	 ,"C",15,0},; // Codigo Produto 
				{"DESC_PROD"	 ,"C",51,0},; // Descricao do Produto 
				{"SR_ORIGINAL"	 ,"C",03,0},; // serie de nf original 
				{"NF_ORIGINAL"	 ,"C",09,0},; // numero de nf original	// Alterado por Adriana em 22/05/17 - chamado 035252
				{"DT_EMISSAO"	 ,"D",10,0},; // emissao da nf 
				{"QTD_ORIGINAL"	 ,"D",13,4},; // quantidade original    
				{"UN_MEDIDA"	 ,"C",02,0},; // unidade de medida
				{"VALOR_UNIT"    ,"N",16,4},; // valor  Unitario // 20/12/2018 WILLIAM 045947    
				{"VALOR_ORIGINAL","N",16,4},; // valor  Original 
				{"DT_ULT_ENTREGA","D",10,0},; // Data Ultima Entrega 
				{"SALDO_QTD"	 ,"N",18,4},; // Saldo em Quantidade 
				{"SALDO_VLR"	 ,"N",15,2},; // Saldo em Valor 
				{"TIPO"			 ,"C",01  },; // tipo
				{"CFOP"			 ,"C",05  },; // CFOP
				{"Responsavel"	 ,"C",40  },;  // responsavel //chamado 036681 William Costa 15/08/2017
				{"C.CUSTO"		 ,"C",05  },; // C.CUSTO //18/06/2019 - ABEL BABINI Ch.049414
				{"DESC_CC"		 ,"C",40  },; // NOME C.CUSTO //18/06/2019 - ABEL BABINI Ch.049414
				{"VALOR_ICMS"	 ,"N",15,2}} // Valor ICMS //29/10/2019 - ABEL BABINI    - 052892 - ADICIONADO CENTRO DE CUSTO
				
	cQuery := "SELECT B6_FILIAL,B6_CLIFOR,B6_LOJA,B6_PRODUTO,B6_SERIE,B6_DOC,B6_EMISSAO,B6_QUANT,B6_PRUNIT,B6_CUSTO1,B6_UENT,B6_SALDO,B6_TIPO,B6_TPCF,B6_TES"
	cQuery += " FROM "+RetSqlName("SB6")+" "
	cQuery += " WHERE B6_FILIAL = '"+_xFilSB6+"' "
	cQuery += "	 AND B6_EMISSAO >= '"+Dtos(mv_par01)+"' AND B6_EMISSAO <='"+Dtos(mv_par02)+"' "
	
	IF MV_PAR06 == 1 //29/03/2019 WILLIAM COSTA chamado 048192
	
		cQuery += " AND B6_SALDO   <> 0 "
		
	ENDIF
	
	cQuery += " AND B6_PRODUTO >= '"+MV_PAR04+"' " //29/03/2019 WILLIAM COSTA chamado 048192
	cQuery += " AND B6_PRODUTO <= '"+MV_PAR05+"' " //29/03/2019 WILLIAM COSTA chamado 048192
	cQuery += " AND D_E_L_E_T_  = ' ' "
	cQuery += "ORDER BY B6_FILIAL,B6_CLIFOR,B6_LOJA,B6_SERIE,B6_DOC"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.T.,.T.)
	
	tcsetfield("QRY","B6_FILIAL" ,"C",2   )
	tcsetfield("QRY","B6_CLIFOR" ,"C",6   )
	tcsetfield("QRY","B6_LOJA"	 ,"C",2   )
	tcsetfield("QRY","B6_PRODUTO","C",15  )
	tcsetfield("QRY","B6_SERIE"	 ,"C",3   )
	tcsetfield("QRY","B6_DOC"	 ,"C",9   )	// Alterado por Adriana em 22/05/17 - chamado 035252
	tcsetfield("QRY","B6_EMISSAO","D"     )
	tcsetfield("QRY","B6_QUANT"	 ,"N",13,4)   
	tcsetfield("QRY","B6_PRUNIT" ,"N",13,4)
	tcsetfield("QRY","B6_CUSTO1" ,"N",16,4)
	tcsetfield("QRY","B6_UENT"	 ,"D"     )
	tcsetfield("QRY","B6_SALDO"	 ,"N",18,4)
	tcsetfield("QRY","B6_TIPO"	 ,"C",1   )
	tcsetfield("QRY","B6_TPCF"	 ,"C",1   )
	tcsetfield("QRY","B6_TES"	 ,"C",3   )
	
	QRY->(dbGotop())
	
	While QRY->(!EOF())  
		aCCusto	:= {} //Ch.049414 - ABEL BABINI - 18/06/2019
		If mv_par03 == 1 .And. QRY->B6_TIPO != "D"
			QRY->(dbSkip())
			Loop
		ElseIf mv_par03 == 2 .And. QRY->B6_TIPO != "E"
			QRY->(dbSkip())
			Loop
		EndIf
	
		If QRY->B6_TPCF == "C" .AND. QRY->B6_CLIFOR+QRY->B6_LOJA != _cCliFor 
			_cCliFor:=QRY->B6_CLIFOR+QRY->B6_LOJA
			dbSelectArea("SA1")
			dbSeek(_xFilSA1+QRY->B6_CLIFOR+QRY->B6_LOJA)
			_cRazSoc:= SA1->A1_NOME
	
		Elseif QRY->B6_CLIFOR+QRY->B6_LOJA <> _cCliFor 
			_cCliFor:=QRY->B6_CLIFOR+QRY->B6_LOJA
			dbSelectArea("SA2")
			dbSeek(_xFiLSA2+QRY->B6_CLIFOR+QRY->B6_LOJA)
			_cRazSoc:= SA2->A2_NOME
		Endif	
	  	
	    If QRY->B6_PRODUTO != _cProduto 
	    	_cProduto:= QRY->B6_PRODUTO  
	    	dbSelectArea("SB1")
			dbSeek(_xFilSB1+QRY->B6_PRODUTO)
		Endif  
	
	
		_nSalOri := Round(QRY->B6_PRUNIT  * QRY->B6_QUANT,2)  
	
		_nSalVal:= Round(QRY->B6_PRUNIT  * QRY->B6_SALDO,2)  
		
		cCamposB6 := '"' +  STRZERO(VAL(QRY->B6_FILIAL),2) 								+'"'	+";"	// 01
		cCamposB6 += '"' + Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6))						+'"' 	+";"	// 02
		cCamposB6 += '"'	+ Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))						+'"' 	+";"	// 03
		cCamposB6 += '"'	+ Alltrim(_cRazSoc)											+'"'	+";"	// 04
		cCamposB6 += '"' + Alltrim(QRY->B6_PRODUTO)										+'"' 	+";"	// 05
		cCamposB6 += '"' + Alltrim(NOACENTO2(SB1->B1_DESCOMP))							+'"' 	+";"	// 06  //Alterado Ch.049414 - ABEL BABINI - 18/06/2019 
		cCamposB6 += '"'	+ Alltrim(QRY->B6_SERIE)									+'"'	+";"	// 07
		cCamposB6 += '"'	+ Alltrim(STRZERO(VAL(QRY->B6_DOC),9	))					+'"'	+";"	// 08 	// Alterado por Adriana em 22/05/17 - chamado 035252
		cCamposB6 += Alltrim(DTOC(QRY->B6_EMISSAO))										+";"			// 09
		//cCamposB6 += Alltrim(Transform((QRY->B6_QUANT*100),"@E 999,999,999,999.9999"))  +";"			      	// Alterado por Adriana em 30/05/17 - chamado 035325     
		cCamposB6 += Alltrim(Transform(QRY->B6_QUANT,"@E 999,999,999,999.9999"))  		+";"			// 10	// Alterado por Adriana em 30/05/17 - chamado 035325
		cCamposB6 += Alltrim(SB1->B1_UM) 					 							+";"			// 11
		//cCamposB6 += Alltrim(transform((_nSalOri*100),"@E 999,999,999,999.9999")) 		+";"		      	// Alterado por Adriana em 30/05/17 - chamado 035325   
		cCamposB6 += Alltrim(transform(QRY->B6_PRUNIT,"@E 999,999,999,999.9999")) 		+";"			// 12	// 20/12/2018 WILLIAM 045947 
		cCamposB6 += Alltrim(transform(_nSalOri,"@E 999,999,999,999.9999")) 		+";"				// 13	// Alterado por Adriana em 30/05/17 - chamado 035325
		cCamposB6 += Alltrim(DTOC(QRY->B6_UENT))										+";"			// 14
		//cCamposB6 += Alltrim(Transform((QRY->B6_SALDO*100),"@R 999999999999,99"))  	+";"			
		cCamposB6 += Alltrim(transform(QRY->B6_SALDO,"@E 999,999,999,999.9999" ))		+";"			// 15	// Alterado por Adriana em 30/05/17 - chamado 035325
		cCamposB6 += Alltrim(transform(_nSalVal,"@E 999,999,999,999.9999" ))			+";" 			// 16	// Alterado por Adriana em 30/05/17 - chamado 035325
		cCamposB6 += Alltrim(QRY->B6_TIPO) 
		cCamposB6 += ';' + IIF(Alltrim(QRY->B6_TIPO) == 'E'                         ,;
		                       CFOPNfSaida(STRZERO(VAL(QRY->B6_FILIAL),2)           ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_DOC),9))     ,;
		                                   Alltrim(QRY->B6_SERIE)                   ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6))  ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))    ,;
		                                   Alltrim(QRY->B6_PRODUTO)                  ;
		                                   )                                        ,;
		                       CFOPNfEntrada(STRZERO(VAL(QRY->B6_FILIAL),2)         ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_DOC),9))   ,;
		                                     Alltrim(QRY->B6_SERIE)                 ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6)),;
		                                     Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))  ,;
		                                     Alltrim(QRY->B6_PRODUTO)                ;
		                                     )                                       ;
		                      ) //chamado 036681 William Costa 15/08/2017
		cCamposB6 += ';' + IIF(Alltrim(QRY->B6_TIPO) == 'E'                         ,;
		                       RespNfSaida(STRZERO(VAL(QRY->B6_FILIAL),2)           ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_DOC),9))     ,;
		                                   Alltrim(QRY->B6_SERIE)                   ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6))  ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))    ,;
		                                   Alltrim(QRY->B6_PRODUTO)                  ;
		                                   )                                        ,;
		                       RespNfEntrada(STRZERO(VAL(QRY->B6_FILIAL),2)         ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_DOC),9))   ,;
		                                     Alltrim(QRY->B6_SERIE)                 ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6)),;
		                                     Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))  ,;
		                                     Alltrim(QRY->B6_PRODUTO)                ;
		                                     )                                       ;
		                      ) //chamado 036681 William Costa 15/08/2017
		// Inicio chamado 049414 Abel Babini 18/06/2019
		IF (Alltrim(QRY->B6_TIPO) == 'E')
			aCCusto	:= CCNfSaid(STRZERO(VAL(QRY->B6_FILIAL),2)           ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_DOC),9))     ,;
		                                   Alltrim(QRY->B6_SERIE)                   ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6))  ,;
		                                   Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))    ,;
		                                   Alltrim(QRY->B6_PRODUTO)                  ;
		                                   )
		ELSE
			aCCusto	:= CCNfEntr(STRZERO(VAL(QRY->B6_FILIAL),2)         ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_DOC),9))   ,;
		                                     Alltrim(QRY->B6_SERIE)                 ,;
		                                     Alltrim(STRZERO(VAL(QRY->B6_CLIFOR),6)),;
		                                     Alltrim(STRZERO(VAL(QRY->B6_LOJA),2))  ,;
		                                     Alltrim(QRY->B6_PRODUTO)                ;
		                                     )
		ENDIF
		
		cCamposB6 += ';' + aCCusto[1][1] //CCUSTO Ch.049414 - ABEL BABINI - 18/06/2019 
		cCamposB6 += ';' + aCCusto[1][2] //DESCR_CCUSTO Ch.049414 - ABEL BABINI - 18/06/2019 
		cCamposB6 += ';' + Alltrim(transform(aCCusto[1][3] ,"@E 999,999,999,999.9999" )) //29/10/2019 - ABEL BABINI    - 052892 - ADICIONADO CENTRO DE CUSTO
		// Fim chamado 049414 Abel Babini 18/06/2019
				                    
		AAdd(aRegs,cCamposB6)
	
		QRY->(DbSkip())
		
	EndDo
	
	CriaExcel(aStru,aRegs,cArq)
	
	QRY->(dbCloseArea())

Return

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³CriaExcel ºAutor  ³hcconsys            º Data ³  08/05/08   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDesc.     ³Gera o arquivo excel de acordo com a estrutura, registros e º±±
//±±º          ³nome passados a funcao.                                     º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³Generico (Especifico adoro                                  º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Static Function CriaExcel(aStru,aRegs,cArq)

	Local cDirDocs 	:= MsDocPath()
	Local cPath		:= AllTrim(GetTempPath())
	Local oExcelApp
	Local cCrLf 	:= Chr(13) + Chr(10)
	Local nHandle
	Local nX
	
	ProcRegua(Len(aRegs)+2)
	
	if file(cPath+"\"+cArq+".CSV")
		FErase(cPath+"\"+cArq+".CSV")		
	endif
	
	nHandle := MsfCreate(cDirDocs+"\"+cArq+".CSV",0)
	
	If nHandle > 0
		
		// Grava o cabecalho do arquivo
		
		IncProc("Aguarde! Gerando arquivo de integração com Excel...")
		
		aEval(aStru, {|e,nX| fWrite(nHandle, e[1] + If(nX < Len(aStru), ";", "") ) } )
		
		fWrite(nHandle, cCrLf ) // Pula linha
		
		For nX := 1 to Len(aRegs)
			IncProc("Aguarde! Gerando arquivo de integração com Excel...")
			fWrite(nHandle,aRegs[nX])
			fWrite(nHandle, cCrLf ) // Pula linha
		Next
		
		IncProc("Aguarde! Abrindo o arquivo..." )
		
		fClose(nHandle)
		
		CpyS2T( cDirDocs+"\"+cArq+".CSV" , cPath, .T. )
		
	 	
		If ! ApOleClient('MsExcel')
			MsgAlert("Excel nao instalado!")
			Return
		Else
			
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cPath+cArq+".CSV" ) // Abre uma planilha
			oExcelApp:SetVisible(.T.)
		
		EndIf
	 
	Else
		MsgAlert( "Falha na criacao do arquivo" )
	Endif

Return


/******************************/
Static Function ValidPerg(cPerg)

	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i, j
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := Padr(cPerg,10," ")
	
	aAdd(aRegs,{cPerg,"01","Data de ?","Data de   	 ","Data de        "				,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Ate ?","Data Ate       ","Data Ate       "				,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo ?",".     	     ",".			   "			  	,"mv_ch3","N",01,0,0,"C","","mv_par03","De Terceiros",".",".","","","Em Terceiros",".",".","","","Ambos",".",".","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Codigo Produto de ?","Codigo Produto de ?","Codigo Produto de ?"    ,"mv_ch4","C",15,0,0,"C","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""}) //29/03/2019 WILLIAM COSTA chamado 048192
	aAdd(aRegs,{cPerg,"05","Codigo Produto Ate ?","Codigo Produto Ate ?","Codigo Produto Ate ?" ,"mv_ch5","C",15,0,0,"C","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""}) //29/03/2019 WILLIAM COSTA chamado 048192
	aAdd(aRegs,{cPerg,"06","Saldo Diferente de Zero	?",". ",". "	            		  	,"mv_ch6","N",01,0,0,"C","","mv_par06","Sim",".",".","","","Nao",".",".","","","",".",".","","","","","","","","","","","","",""}) //29/03/2019 WILLIAM COSTA chamado 048192
	
	For i := 1 to Len(aRegs)
		If 	!dbSeek( cPerg + aRegs[i,2] )
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock("SX1")
		Endif
	Next
	
	dbSelectArea(_sAlias)

Return                                           

// Inicio chamado 036681 William Costa 15/08/2017

STATIC FUNCTION RespNfSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd) 

	Local cResponsavel := ''
	
	SqlNfSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd)
	While TRB->(!EOF()) 
			    
		cResponsavel := TRB->C5_XRESPON
		
		TRB->(dbSkip())
	
	ENDDO
    TRB->(dbCloseArea())   
	
RETURN(cResponsavel)

STATIC FUNCTION RespNfEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd) // Inicio chamado 036681 William Costa 15/08/2017

	Local cResponsavel := ''
	
	SqlNfEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd)
	While TRC->(!EOF()) 
			    
		cResponsavel := TRC->F1_XRESPON
		
		TRC->(dbSkip())
	
	ENDDO
    TRC->(dbCloseArea())   
	
RETURN(cResponsavel)

STATIC FUNCTION CFOPNfSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd) 

	Local cCFOP := ''
	
	SqlCFOPSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd)
	While TRD->(!EOF()) 
			    
		cCFOP := TRD->D2_CF
		
		TRD->(dbSkip())
	
	ENDDO
    TRD->(dbCloseArea())   
	
RETURN(cCFOP)

STATIC FUNCTION CFOPNfEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd) // Inicio chamado 036681 William Costa 15/08/2017

	Local cCFOP := ''
	
	SqlCFOPEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd)
	While TRE->(!EOF()) 
			    
		cCFOP := TRE->D1_CF
		
		TRE->(dbSkip())
	
	ENDDO
    TRE->(dbCloseArea())   
	
RETURN(cCFOP)

STATIC FUNCTION SqlNfSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd)

	BeginSQL Alias "TRB"
			%NoPARSER%  
			SELECT D2_PEDIDO,
			       C5_XRESPON
			  FROM %Table:SD2% WITH(NOLOCK), %Table:SC5% WITH(NOLOCK)
			 WHERE D2_FILIAL               = %EXP:cFil%
			   AND D2_DOC                  = %EXP:cDoc%
			   AND D2_SERIE                = %EXP:cSerie%
			   AND D2_CLIENTE              = %EXP:cCli%
			   AND D2_LOJA                 = %EXP:cLoja%
			   AND D2_COD                  = %EXP:cProd%
			   AND %Table:SD2%.D_E_L_E_T_ <> '*'
			   AND C5_FILIAL               = D2_FILIAL
			   AND C5_NUM                  = D2_PEDIDO
			   AND C5_CLIENTE              = D2_CLIENTE
			   AND C5_LOJACLI              = D2_LOJA
			   AND %Table:SC5%.D_E_L_E_T_ <> '*'
			
			GROUP BY D2_PEDIDO,C5_XRESPON
			
	EndSQl            

RETURN(NIL) 

STATIC FUNCTION SqlNfEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd)

	BeginSQL Alias "TRC"
			%NoPARSER%  
			SELECT F1_XRESPON
			  FROM %Table:SF1% WITH(NOLOCK)
			WHERE F1_FILIAL               = %EXP:cFil%
			  AND F1_DOC                  = %EXP:cDoc%
			  AND F1_SERIE                = %EXP:cSerie%
			  AND F1_FORNECE              = %EXP:cFornece%
			  AND F1_LOJA                 = %EXP:cLoja%
			  AND %Table:SF1%.D_E_L_E_T_ <> '*'
			
	EndSQl            

RETURN(NIL)

STATIC FUNCTION SqlCFOPSaida(cFil,cDoc,cSerie,cCli,cLoja,cProd)

	BeginSQL Alias "TRD"
			%NoPARSER%  
			SELECT D2_CF
			  FROM %Table:SD2% WITH(NOLOCK)
			 WHERE D2_FILIAL               = %EXP:cFil%
			   AND D2_DOC                  = %EXP:cDoc%
			   AND D2_SERIE                = %EXP:cSerie%
			   AND D2_CLIENTE              = %EXP:cCli%
			   AND D2_LOJA                 = %EXP:cLoja%
			   AND D2_COD                  = %EXP:cProd%
			   AND %Table:SD2%.D_E_L_E_T_ <> '*'
			
			GROUP BY D2_CF
			
	EndSQl            

RETURN(NIL) 

STATIC FUNCTION SqlCFOPEntrada(cFil,cDoc,cSerie,cFornece,cLoja,cProd)

	BeginSQL Alias "TRE"
			%NoPARSER%  
			SELECT D1_CF
			  FROM %Table:SD1% WITH(NOLOCK)
			WHERE D1_FILIAL               = %EXP:cFil%
			  AND D1_DOC                  = %EXP:cDoc%
			  AND D1_SERIE                = %EXP:cSerie%
			  AND D1_FORNECE              = %EXP:cFornece%
			  AND D1_LOJA                 = %EXP:cLoja%  
			  AND D1_COD                  = %EXP:cProd%
			  AND %Table:SD1%.D_E_L_E_T_ <> '*'
			
	EndSQl            

RETURN(NIL) // Final chamado 036681 William Costa 15/08/2017


// Inicio chamado 049414 Abel Babini 18/06/2019
STATIC FUNCTION CCNfSaid(cFil,cDoc,cSerie,cCli,cLoja,cProd) 

	Local aCCusto := {}
	
	BeginSQL Alias "TRF"
			%NoPARSER%  
			SELECT D2_CCUSTO, CTT_DESC01, D2_VALICM
			  FROM %Table:SD2% WITH(NOLOCK)
			  LEFT JOIN %Table:CTT% CTT ON
			   	CTT.%notDel% AND
			   	CTT.CTT_CUSTO = D2_CCUSTO 
			 WHERE D2_FILIAL               = %EXP:cFil%
			   AND D2_DOC                  = %EXP:cDoc%
			   AND D2_SERIE                = %EXP:cSerie%
			   AND D2_CLIENTE              = %EXP:cCli%
			   AND D2_LOJA                 = %EXP:cLoja%
			   AND D2_COD                  = %EXP:cProd%
			   AND %Table:SD2%.D_E_L_E_T_ <> '*'
						
	EndSQl     
	AADD(aCCusto, {TRF->D2_CCUSTO,TRF->CTT_DESC01, TRF->D2_VALICM})
    TRF->(dbCloseArea())   
	
RETURN(aCCusto)

STATIC FUNCTION CCNfEntr(cFil,cDoc,cSerie,cFornece,cLoja,cProd) // Inicio chamado 036681 William Costa 15/08/2017
	Local aCCusto := {}
	
	BeginSQL Alias "TRG"
		%NoPARSER%  
		SELECT D1_CC, CTT_DESC01, D1_VALICM
			FROM %Table:SD1% WITH(NOLOCK)
			LEFT JOIN %Table:CTT% CTT ON
				CTT.%notDel% AND
				CTT.CTT_CUSTO = D1_CC 
		WHERE D1_FILIAL               = %EXP:cFil%
			AND D1_DOC                  = %EXP:cDoc%
			AND D1_SERIE                = %EXP:cSerie%
			AND D1_FORNECE              = %EXP:cFornece%
			AND D1_LOJA                 = %EXP:cLoja%  
			AND D1_COD                  = %EXP:cProd%
			AND %Table:SD1%.D_E_L_E_T_ <> '*'		
	EndSQl     
	AADD(aCCusto, {TRG->D1_CC,TRG->CTT_DESC01,TRG->D1_VALICM})
    TRG->(dbCloseArea())   
	
RETURN(aCCusto)

STATIC FUNCTION NoAcento2(cString)
	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := 'àèìòù'+'ÀÈÌÒÙ'
	Local cTio   := "ãõÃÕ"
	Local cCecid := "çÇ"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"
	
	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf                     
			nY:= At(cChar,cTio)
			If nY > 0          
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf                     
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next
	
	If cMaior$ cString 
									cString := strTran( cString, cMaior, "" ) 
	EndIf
	If cMenor$ cString 
									cString := strTran( cString, cMenor, "" )
	EndIf
	
	cString := StrTran( cString, CRLF, " " )
	
	For nX:=1 To Len(cString)
									cChar:=SubStr(cString, nX, 1)
									If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
																	cString:=StrTran(cString,cChar,".")
									Endif
	Next nX
	//Especifico Adoro devido a erro XML não solucionado versao 3.10
	cString := StrTran(cString,"&","e")
	cString := StrTran(cString,'"','')
Return cString


// Fim chamado 049414 Abel Babini 18/06/2019
