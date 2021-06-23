#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST003  บAutor  ณADRIANA OLIVEIRA    บ Data ณ  15/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImporta inventario arquivo CSV                              บฑฑ
ฑฑบ          ณPode ser gerado pela opcao Itens Inventario em excel        บฑฑ
ฑฑบ          ณPersonalizado, layout PLANILHA_INVENTARIO                   บฑฑ
ฑฑบ          ณPreencher a coluna Quantidade e salvar como CSV             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณADORO                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณ046050 || OS 047239 || CONTROLADORIA || DANIELLE_MEIRA      บฑฑ
ฑฑบ07/01/2019ณ|| 8459 || IMP.ARQ.INVENT - Adicionado o campo LOCALIZACAO  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ															  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADEST003

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa inventario arquivo CSV')
	
	Private cPerg
	
	/*LAYOUT DO ARQUIVO CSV A SER IMPORTADO:
	
	Arquivo deve ser delimitado por ";", com 1 linha de cabecalho  e ";" ao final de cada linha tambem
	
	1= Cod. Produto 				(Tipo Caracter)
	2= Armazem          			(Tipo Caracter)
	3= Quantidade Inventariada      (Tipo Numerico)
	4= Data inventario
	5= Contagem (1,2,3...)                                
	6= Escolha (S/N para contagem selecionada)
	7= Localiza็ใo do produto
	
	Exemplo:
	
	PRODUTO;ARMAZEM;QUANTIDADE;DATA;CONTAGEM;ESCOLHA;LOCALIZACAO
	492551;02;100;20140826;1;S;D118
	*/
	Private oDlg01
	Private oFont1
	
	_nHdl    	:= Nil
	_cBuffer 	:= ""
	_nBytes  	:= 0
	_cDelimit	:= ";"
	_cArq    	:= ""
	_dData		:= date()
	_nLinCab	:= 0
	_lGerou     := .f.
	_cPerg		:= PADR("ADEST003",10," ")
	_cFileLog 	:= ""
	_cPath 		:= GetSrvProfString("StartPath","")+"LOG\"
	_cDoc		:= ""
	_cProduto     	:= ""
	_cLocal       	:= ""
	_nQtd		  	:= 0
	_cContagem		:= ""
	_cEscolha		:= ""
	_cLocaliz		:= space(15)
	_cnumseri		:= space(20)
	_clotectl		:= space(10)
	_cnumlote		:= space(6)
	
	
	ValidPerg()
	
	if Pergunte(_cPerg,.T.)
		_cArq    	:= MV_PAR01
		_dData		:= MV_PAR02
		_nLinCab	:= MV_PAR03
	    //Define numero do documento DATA PARAMETRO+SEQUENCIAL
		//_cDoc		:= strzero(day(_dData),2)+strzero(month(_dData),2)+right(str(year(_dData)),2)  
		_cDoc		:= dtos(_dData)
		dbSelectArea("SB7")
		dbSetOrder(3)              
		for si := 1 to 999
			if !dbSeek(xFilial("SB7")+_cDoc+Strzero(si,3))  
				Exit
			endif
		next
	
		Define msDialog oDlg01 From 00,00 To 260,600 Title "IMPORTAวรO PLANILHA DE INVENTARIO" Pixel &&145  220,370
		Define Font oFont1 Name "Arial" Size 0,14 Bold
		@010,005 Say "Esta rotina tem como fun็ใo importar contagem do inventแrio a partir de um arquivo" Font oFont1 of oDlg01 Pixel
		@020,005 Say "TXT delimitado, layout: PRODUTO;ARMAZEM;QUANTIDADE;DATA;CONTAGEM;ESCOLHA;LOCALIZACAO" Font oFont1 of oDlg01 Pixel
		@030,005 Say "PRODUTO=Codigo do Produto"	Font oFont1 of oDlg01 Pixel
		@040,005 Say "ARMAZEM=Codigo do Armazem"	Font oFont1 of oDlg01 Pixel
		@050,005 Say "QUANTIDADE=Quantidade Inventariada"	Font oFont1 of oDlg01 Pixel
		@060,005 Say "DATA=Somente informativa, a rotina considera o que digitar no parametro Data contagem"	Font oFont1 of oDlg01 Pixel
		@070,005 Say "CONTAGEM=Numero da contagem"	Font oFont1 of oDlg01 Pixel
		@080,005 Say "ESCOLHA=preencher com S se for a contagem selecionada"	Font oFont1 of oDlg01 Pixel
		@090,005 Say "LOCALIZACAO=preencher com a localiza็ใo do Produto"	Font oFont1 of oDlg01 Pixel
		
		@110,115 BmpButton Type 1 Action(lRet := .T.,Close(oDlg01))
		@110,150 BmpButton Type 2 Action(lRet := .F.,Close(oDlg01))
		Activate Dialog oDlg01 Centered     
		
		If lRet
			If MsgYesNo(OemToAnsi("Confirma importa็ao do arquivo  "+Alltrim(_cArq)+" com dados de inventแrio?"),"ATENCAO")
				_nHdl := fOpen(_cArq,2)
				fClose(_nHdl)
				
				If _nHdl == -1
					Aviso( "AVISO",OemToAnsi("Nใo foi possํvel abrir o arquivo "+_cArq),{"Sair"} )
				else
					Processa({|| ImpInv()})                                         
						if _lGerou
							Aviso( "AVISO",OemToAnsi("Gerado Documento "+_cDoc+"."+CHR(13)+CHR(10)+"Verificar log em "+_cpath+_cfilelog),{"Sair"} )
						else
							Aviso( "AVISO",OemToAnsi("Nใo foram gerados registros de Inventแrio."+CHR(13)+CHR(10)+"Verificar log em "+_cpath+_cfilelog),{"Sair"} )
						endif
				endif
				
			endif
		Endif
	Endif

Return Nil

Static Function ImpInv

	nLin 		:= 1
	AutoGrLog("LOG IMPORTA DADOS INVENTARIO ("+Alltrim(_cArq)+") - Doc.: "+_cDoc)
	AutoGrLog("--------------------------------------------------------------------------")
	AutoGrLog(" ")
	AutoGrLog(" ")
	lArqOK 		:= .t.
	
	ft_fUse(_cArq)
	
	ProcRegua(RecCount())
	
	ft_fGoTop()
	_nLin := 1
	
	Do While !ft_fEOF()
		lMSErroAuto := .F.
		_cProduto     	:= ""
		_cLocal       	:= ""
		_nQtd		  	:= 0
		_cContagem		:= ""
		_cEscolha		:= ""
		_lcont    := .T.
		_lret     := .T.
		
		_arqOk := .T.
		_cBuffer := ft_fReadLn()
		_nCmp := 1
		
		If _nLin <= _nLinCab      //pula cabecalho
			ft_fSkip()
			_nLin ++
			loop
		Endif
		
		for _i := 1 to 7 // CHAMADO 046050 WILLIAM COSTA 07/01/2019
			
			_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
			
			if _i = 1
				_cProduto := _cTxtPos+space(15-len(_cTxtPos))
			elseif _i = 2
				_cLocal := strzero(val(alltrim(_cTxtPos)),2)
			elseif _i = 3
				_nQtd := Val(_cTxtPos)
			elseif _i = 4
	//			_dData := _cTxtPos
			elseif _i = 5
				_cContagem := _cTxtPos
			elseif _i = 6
				_cEscolha := _cTxtPos
			elseif _i = 7 // CHAMADO 046050 WILLIAM COSTA 07/01/2019 
				_cLocaliz := _cBuffer	// CHAMADO 046050 WILLIAM COSTA 07/01/2019
			endif
			_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
			_nCmp++
		next
		
		IncProc("Importando...")
		
		dbSelectArea("SB1")
		if dbSeek(xFilial("SB1")+_cProduto)
			
			dbSelectArea("SB2")
			if dbSeek(xFilial("SB2")+_cProduto+_cLocal)
				
				dbSelectArea("SB7")
				dbSetOrder(1)  		  
				dbSeek(xFilial("SB7")+dtos(_dData)+_cProduto+_cLocal) 
				if !dbSeek(xFilial("SB7")+dtos(_dData)+_cProduto+_cLocal+_cLocaliz+_cnumseri+_clotectl+_cnumlote+_cContagem)
					
					aDadosSB7 := {	{"B7_FILIAL"  	,xFilial("SB7")  	,Nil},;
				   					{"B7_COD"     	,_cProduto 			,Nil},;
				   					{"B7_DOC"     	,_cDoc	    		,Nil},;
									{"B7_QUANT"   	,_nQtd	     		,Nil},;
				   					{"B7_LOCAL"   	,_cLocal	   		,Nil},;
				   					{"B7_DATA"   	,_dData	    		,Nil},;
				   					{"B7_DTVALID"  	,_dData	    		,Nil},;
				   					{"B7_CONTAGE"  	,_cContagem	   		,Nil},;
				   					{"B7_LOCALIZ"  	,_cLocaliz	   		,Nil},;
				   					{"B7_ESCOLHA"  	,_cEscolha	   		,Nil}}
					
					MSExecAuto({|x,y| mata270(x,y)},aDadosSB7,.F.,3)
					
					If lMSErroAuto
						
						Mostraerro()
						
					else
						
						AutoGrLog("Linha "+strzero(_nlin,5)+" IMPORTADO   SB7 Produto "+_cProduto+"-"+_cLocal+" Quantidade: "+str(_nQtd,10,2)+" Data: "+dtoc(_ddata))
						_lGerou := .t.					
					endif
					
				else
					
					AutoGrLog("Linha "+strzero(_nlin,5)+" DUPLICIDADE SB7 Produto "+_cProduto+"-"+_cLocal+" Quantidade: "+str(_nQtd,10,2)+" Data: "+dtoc(_ddata)+" Documento: "+SB7->B7_DOC)
				endif
			else
				AutoGrLog("Linha "+strzero(_nlin,5)+" NAO EXISTE  SB2 Produto "+_cProduto+"-"+_cLocal+" Quantidade: "+str(_nQtd,10,2)+" Data: "+dtoc(_ddata))
			endif
		else
			AutoGrLog("Linha "+strzero(_nlin,5)+" NAO EXISTE  SB1 Produto "+_cProduto+"-"+_cLocal+" Quantidade: "+str(_nQtd,10,2)+" Data: "+dtoc(_ddata))
			
		endif
		
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณHeraldo C. Hebling  บ Data ณ  20/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao auxiliar de criacao das perguntas dos parametros     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ADORO                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg

	PutSx1(_cPerg,"01","Importar do Arquivo CSV ?", "Importar do Arquivo ?", "Importar do Arquivo ?", "mv_ch1","C",50,0,0,"G",""         ,"","","","mv_par01","","","","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"02","Data Contagem ?", "Data Contagem ?", "Data Contagem ?", "mv_ch2","D",8,0,0,"G",""         ,"","","","mv_par02","","","","","","","","","","","","","","","","","","","")
	PutSx1(_cPerg,"03","Qtd.Linhas Cabe็alho ?", "Qtd.Linhas Cabe็alho ?", "Qtd.Linhas Cabe็alho ?", "mv_ch3","N",1,0,0,"G",""         ,"","","","mv_par03","","","","","","","","","","","","","","","","","","","")

Return