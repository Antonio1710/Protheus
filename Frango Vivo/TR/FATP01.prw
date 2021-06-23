#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#include "FiveWin.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATP01    บAutor  ณDaniel              บ Data ณ  11/29/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de Apanha                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณ Mauricio-HC Consys-para incluir campo peso do apanhe-004675บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณ Chamado 046955 William Costa 13/02/2019                    บฑฑ
ฑฑบ          ณ Valida็ใo do Tudo OK para garantir que a nota nใo esteja   บฑฑ
ฑฑบ          ณ sendo usada em nenhuma outra ordem                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FATP01(nOpc,_QtdApn)

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Apanha')
	
	//+-------------------------------+
	//|VARIAVEIS DE CONTROLE          |
	//+-------------------------------+ 
	Public  nOpcx    := nOpc
	Private nLinExc  := 'ZV5_FILIAL|ZV5_QTDGAI|ZV5_AVEGAI|ZV5_NUMOC' // Campos excluidos   
	Private _aArea   := GetArea()                                    // Guarda a Area Atual 
	Private _cAliasD := 'ZV5'										 // ALIAS DE DESTINO
	Private _cAliasO := 'ZV1'										 // ALIAS DE ORIGEM   
	Private cLinhaOk := '.T.'					         			 // VALIDACAO DA LINHA
	Private cTudoOk  := 'U_FATP01TOK()'								 // VALIDACAO DO FORMULARIO WILLIAM COSTA 13/02/2019 046955
	
	//+------------------------------+
	//| FILIAL                       |
	//+------------------------------+
	DBSELECTAREA("SM0")
	Private _Filial  := M0_CODFIL //TABELAS EXCLUSIVAS
	Private _cFilial := '  '	  //TABELAS COMPARTILHADAS
	
	
	//+----------------------------------------------+
	//| Variaveis do Cabecalho do Modelo 2           |
	//+----------------------------------------------+
	Private NUMOC		:=M->ZV1_NUMOC
	Private GUIA		:=M->ZV1_GUIAPE
	Private PLACA		:=M->ZV1_RPLACA
	Private INTEGRADO	:=M->ZV1_RGRANJ
	
	//+----------------------------------------------+
	//| Variaveis do Rodape do Modelo 2              |
	//+----------------------------------------------+
	Private DATABAT	:=	M->ZV1_DTABAT 
	Private RQTDAPN	:=	_QtdApn 
	
	
	//+----------------------------------+
	//|VARIAVEIS DOS GETADOS    		 |
	//+----------------------------------+
	RGRANJ:=M->ZV1_RGRANJ
	FORREC:=M->ZV1_FORREC
	LOJREC:=M->ZV1_LOJREC
	DESGRJ:=LEFT(POSICIONE("SA2",9,_cFilial+M->ZV1_RGRANJ,"A2_NOME"),20)
	PESOR := 0
	
	
	//+----------------------------------------------+
	//| Titulo da Janela                             |
	//+----------------------------------------------+
	cTitulo:="CONTROLE DE APANHAS"
	
	//+------------------------------------------------+
	//| Array com coordenadas da GetDados no modelo2   |
	//+------------------------------------------------+
	//aCGD:={44,5,118,400}     
	aCGD:={44,5,118,500}     
	  
	
	//+-----------------------------------------------+
	//|Array com as Coodenadas do Modelo 2            |
	//+-----------------------------------------------+
	//aCordw:={10,10,450,850} 
	aCordw:={10,10,450,950} 
	
	                   
	//+----------------------------------+
	//|DEFININDO A OPCAO                 |
	//+----------------------------------+
	
	//+-----+---------------------+
	//|nOpcx|DESCRICAO			  |
	//+-----+---------------------+
	//|3 e 4| Inclui			  |
	//|x>4  | Visualiza			  |
	//+-----+---------------------+
	If _QtdApn=0
		nOpcx:=3
	EndIf
	
	//+-----------------------------------------------+
	//ฆ Montando aHeader                              ฆ
	//+-----------------------------------------------+
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(_cAliasD)
	nUsado:=0
	aHeader:={}
	While !Eof() .And. (x3_arquivo == _cAliasD)
	    IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
	        nUsado:=nUsado+1 
	        
	        //AQUI FALO QUAIS CAMPOS VOU DESPRESAR
	        IF ALLTRIM(X3_CAMPO) $ nLinExc
	        	DBSKIP()
	        	LOOP
	        ENDIF            
	        AADD(aHeader,;
	        	{TRIM(X3_TITULO),;
	        	X3_CAMPO,;
	           	X3_PICTURE,;
	           	X3_TAMANHO,;
	           	X3_DECIMAL,; 
	           	X3_VLDUSER,; 
	           	X3_USADO,;
	           	X3_TIPO,;
	           	X3_ARQUIVO,;
	           	X3_CONTEXT})
	    Endif
	    dbSkip()
	End 
	
	
	//+-----------------------------------------------+
	//| Montando aCols                                |
	//+-----------------------------------------------+
	aCols:={}
	DBSELECTAREA("ZV5")	
	DBSETORDER(1)                                
	IF nOpcx=3 
		IF DBSEEK(_cFilial+NUMOC,.T.)
			WHILE ZV5_NUMOC=NUMOC
				AADD(aCOLS,{   ;
								ZV5_RGRANJ,;
								ZV5_FORCOD,;
								ZV5_FORLOJ,;
								ZV5_DESGRJ,;
								ZV5_QTDAVE,;
								ZV5_PESOAP,;
								ZV5_HRCARI,;
								ZV5_HRCARF,;
								ZV5_DTABAT,; 
								ZV5_NUMNFS,; // Chamado 040118 - Fernando Sigoli
								ZV5_SERIE ,; // Chamado 040118 - Fernando Sigoli
								.F.		   ;
					})
				DBSKIP()		
		  	END 		
		ELSE          
			AADD(aCOLS,{			;
						RGRANJ		,;						//GRANJA
						FORREC		,;						//FORNECEDOR
						LOJREC		,;						//LOJA
						DESGRJ		,;						//DESCRICAO 							
						_QtdApn		,;						//QTD APN
						PESOR       ,;                		//PESO APN
						Space(5)	,;						//HORA 
						Space(5)	,;						//HORA
						DDATABASE	,;	      				//DATA
						Space(9)    ,;                      //NOTA FISCAL // Chamado 040118 - Fernando Sigoli
						Space(3)    ,;                      //SERIE       // Chamado 040118 - Fernando Sigoli
						.F.			;						//DELETADO
						})	
		ENDIF
	ELSE
		IF DBSEEK(_cFilial+NUMOC)
		  	WHILE ZV5_NUMOC=NUMOC
				AADD(aCOLS,{   ;
								ZV5_RGRANJ,;
								ZV5_FORCOD,;
								ZV5_FORLOJ,;
								ZV5_DESGRJ,;
								ZV5_QTDAVE,;
								ZV5_PESOAP,;
								ZV5_HRCARI,;
								ZV5_HRCARF,;
								ZV5_DTABAT,;  
								ZV5_NUMNFS,; // Chamado 040118 - Fernando Sigoli
								ZV5_SERIE ,; // Chamado 040118 - Fernando Sigoli
								.F.		   ;
					})
				DBSKIP()  
		  	END 
		ENDIF
	EndIf                     
	
	
	//+----------------------------------------------+
	//| Array com descricao dos campos do Cabecalho  |
	//+----------------------------------------------+
	aC:={}         
																			// aC[n,1] = Nome da Variavel Ex.:"cCliente"
																			// aC[n,2] = Array com coordenadas do Get [x,y], em
																			//           Windows estao em PIXEL
																			// aC[n,3] = Titulo do Campo
																			// aC[n,4] = Picture
																			// aC[n,5] = Validacao
																			// aC[n,6] = F3
																			// aC[n,7] = Se campo e' editavel .t. se nao .f.
	
	
	AADD(aC,{"GUIA" 		,{18,010},"GUIA "		,"999999"	,,,.F.})
	AADD(aC,{"NUMOC"		,{18,070},"ORD. CARR."	,"999999"	,,,.F.})
	AADD(aC,{"INTEGRADO"	,{18,160},"INT."		,"@!"		,,,.F.})
	AADD(aC,{"PLACA"		,{18,230},"PLACA REC."	,"@!"		,,,.F.})
	
	//+-------------------------------------------------+
	//| Array com descricao dos campos do Rodape        |
	//+-------------------------------------------------+
	aR:={}
																			// aR[n,1] = Nome da Variavel Ex.:"cCliente"
																			// aR[n,2] = Array com coordenadas do Get [x,y], em
																			//           Windows estao em PIXEL
																			// aR[n,3] = Titulo do Campo
																			// aR[n,4] = Picture
																			// aR[n,5] = Validacao
																			// aR[n,6] = F3
																			// aR[n,7] = Se campo e' editavel .t. se nao .f.
																			
																			// AADD(aR,{"nLinGetD" ,{120,10},"Linha na GetDados",;
																			// "@E 999",,,.F.})   
																			
	AADD(aR,{"DATABAT"		,{125,010},"DATA DE ABATE"	,,,,.F.})
	AADD(aR,{"RQTDAPN"		,{125,100},"APANHA"			,'99999999',,,.F.})
	
																			//+----------------------------------------------+
																			//ฆ Validacoes na GetDados da Modelo 2           ฆ
																			//+----------------------------------------------+
																			//cLinhaOk 	:='.T.'//"ExecBlock('Md2LinOk',.f.,.f.)"
																			//cTudoOk  	:='.T.' //"ExecBlock('Md2TudOk',.f.,.f.)"
																			//+----------------------------------------------+
																			//ฆ Chamada da Modelo2                           ฆ
																			//+----------------------------------------------+
																			// lRet = .t. se confirmou
																			// lRet = .f. se cancelou  
	
	
	//+---------------------------+
	//|MODELO 2                   |
	//+---------------------------+
	lRet:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOK,,,,,aCordw)   
		
	If lRet      
		//+---------------------+
		//|   INCLUSAO          |
		//+---------------------+
	  	If (nOpcx=3)     
		  	Processa({|| Md2Inclu(_cAliasD)},'PROCESSANDO',"Gravando os dados, aguarde...")  			
		Endif                                                                                
		If (nOpcx<>3)
		    Return
		EndIf
	EndIf            
	
	
	
	RestArea(_aArea)														//Volta a Area 

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMD2INCLUI บAutor  ณDANIEL              บ Data ณ  11/30/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFAZ INCLUSAO DOS DADOS                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Md2Inclu(_cAliasD)

	Local i := 0
	Local j := 0
	Local x	:= 0 
	Local SmsApn:=0
	
	//+--------------------------------+
	//|SOMANDO QUANTIDADE DE AVES      |
	//+--------------------------------+    
	For x:=1 to Len(aCOLS)
		If !aCOLS[x,12] //			//Verifico se a Linha NAO esta  
			SmsApn+=(aCOLS[x][5])
		EndIf
	Next x	                           
	
	//+--------------------------------+
	//|VALIDACAO DA QUANTIDADE DE AVES |
	//+--------------------------------+    
	If SmsApn<>RQTDAPN
		MsgInfo("Quantidade de Apanha Digitada Diferente Informada")
		Return
	EndIf	                                
	
	                                   
	//+--------------------------------+
	//|GRAVANDO OS DADOS               |
	//+--------------------------------+    
	
	ProcRegua(Len(aCOLS)) 										// Definindo o tamanho da barra de Processamento 
	dbSelectArea(_cAliasD)
	dbSetOrder(2)
	For i := 1 To Len(aCOLS)  
		IncProc() 												
		If (DbSeek(_cFilial+NUMOC+aCOLS[I][1]+aCOLS[I][2]+aCOLS[I][3],.T.)) .AND. (nOpcx=3) 
				//VERIFICO SE A LINHA NAO ESTA DELETADA
				RecLock(_cAliasD,.F.)
				If !aCOLS[i,12] 	//11			    
					
					REPLACE	ZV5_RGRANJ	WITH aCOLS[I][1]
					REPLACE ZV5_FORCOD	WITH aCOLS[I][2]
					REPLACE ZV5_FORLOJ	WITH aCOLS[I][3]
					REPLACE ZV5_DESGRJ	WITH aCOLS[I][4]
					REPLACE ZV5_QTDAVE	WITH aCOLS[I][5]
					REPLACE ZV5_PESOAP 	WITH aCOLS[I][6]
					REPLACE ZV5_HRCARI	WITH aCOLS[I][7]
					REPLACE ZV5_HRCARF	WITH aCOLS[I][8] 
					REPLACE ZV5_DTABAT	WITH aCOLS[I][9]
					REPLACE ZV5_NUMNFS	WITH aCOLS[I][10] // Chamado 040118 - Fernando Sigoli
					REPLACE ZV5_SERIE	WITH aCOLS[I][11] // Chamado 040118 - Fernando Sigoli
					       
				Else                                   
					//SE ESTA DELETADA REMOVO O REGISTRO
					DbDelete()	                                
				EndIf	                                       
				MsUnlock() 
		ELSE
			If !aCOLS[i,12] 		//11									//Verifico se a Linha NAO esta DELETADA (.T.)
				RecLock(_cAliasD,.T.)   
					
					REPLACE ZV5_NUMOC	WITH NUMOC
					REPLACE	ZV5_RGRANJ	WITH aCOLS[I][1]
					REPLACE ZV5_FORCOD	WITH aCOLS[I][2]
					REPLACE ZV5_FORLOJ	WITH aCOLS[I][3]
					REPLACE ZV5_DESGRJ	WITH aCOLS[I][4]
					REPLACE ZV5_QTDAVE	WITH aCOLS[I][5]
					REPLACE ZV5_PESOAP 	WITH aCOLS[I][6]
					REPLACE ZV5_HRCARI	WITH aCOLS[I][7]
					REPLACE ZV5_HRCARF	WITH aCOLS[I][8] 
					REPLACE ZV5_DTABAT	WITH aCOLS[I][9] 
					REPLACE ZV5_NUMNFS	WITH aCOLS[I][10] // Chamado 040118 - Fernando Sigoli
					REPLACE ZV5_SERIE	WITH aCOLS[I][11] // Chamado 040118 - Fernando Sigoli
					       
				MsUnLock()
			Endif
		ENDIF	
	Next i
	
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFATP01TOK บAutor  ณWILLIAM COSTA       บ Data ณ  13/02/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do Tudo OK para garantir que a nota nใo esteja   บฑฑ
ฑฑบ          ณ sendo usada em nenhuma outra ordem chamado 046955          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION FATP01TOK()

	Local lRetLin     := .T.
	Local nPosNota    := ASCAN(aHeader,{|x| Upper(AllTrim(x[2])) == 'ZV5_NUMNFS'})
	Local nCont       := 0
	Local _cQuery     := "" 
	Local cFilPV      := GetMV("MV_#LFVFIL",,"03")
	Local cSerNFFV    := GetMV("MV_#LFVSER",,"01")
	Local cCliCod     := GetMV("MV_#LFVCLI",,"027601")
	Local cCliLoj     := GetMV("MV_#LFVLOJ",,"00")
	Local cProdPV     := GetMV("MV_#LFVPRD",,"300042")
	Local cQryEXT     := " "
	Local cQryCAN     := " "
	Private _aArea    := GetArea()
	Private _nCODFNF  := ''
	Private _nLojNF   := ''
	Private _cSerie   := ''
	Private _nNumNf   := ''
	Private _cPlac    := ''
	Private _ORDEM    := '' 

	U_ADINF009P('FATP01' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Cadastro de Apanha')
	
	FOR nCont := 1 TO LEN(ACOLS)
	
		IF lRetLin == .T.

			_nCODFNF := ZV1->ZV1_FORREC
			_nLojNF  := ZV1->ZV1_LOJREC
			_cSerie  := ZV1->ZV1_SERIE
			_nNumNf  := ACOLS[nCont][nPosNota]
			_cPlac   := ZV1->ZV1_PPLACA
			_ORDEM   := ZV1->ZV1_NUMOC 
			
			_cQuery := "SELECT ZV1_NUMOC, ZV1_NUMNFS, ZV1_SERIE, ZV1_CODFOR, ZV1_LOJFOR "
			_cQuery += "FROM "+retsqlname("ZV1") +" WHERE RTRIM(LTRIM(ZV1_NUMNFS)) = '"+ALLTRIM(_nNumNF)+"' and "
			_cQuery += "RTRIM(LTRIM(ZV1_SERIE)) = '"+ALLTRIM(_cSerie)+"' and "
			_cQuery += "ZV1_FORREC = '"+_nCODFNF+"' and ZV1_LOJREC = '"+_nLojNF+"' and "
			_cQuery += ""+RetSqlName("ZV1")+ ".D_E_L_E_T_ <> '*' ORDER BY ZV1_NUMOC"
			
			TcQuery _cQuery New Alias "VZV1"
			 
			DbSelectArea("VZV1")
			VZV1->(dbGoTop())
			While !VZV1->(eof())
			   If VZV1->ZV1_NUMOC <> _ORDEM      && Verifica se nao esta alterando uma OC.
			   
			      MsgInfo("A NF/SERIE "+_nNumNf+" / "+_cSerie+" informada ja foi utilizada na OC: "+VZV1->ZV1_NUMOC+" para o Fornecedor/loja: "+_nCODFNF+" / "+_nLojNF+" .Favor Verificar!!!")
			      VZV1->(DbCloseArea())
			      lRetLin     := .F.
			      
			   endif
			   
			   VZV1->(dbSkip())
			EndDo
			    
			VZV1->(DbCloseArea())
		    
		    //inicio - Fernando Sigoli Chamado:043085 13/08/2018
			//verificar se a nota que esta sendo lan็ada existe
			cQryEXT := " SELECT COUNT(*)  AS RECNFEXT "
			cQryEXT += " 	    FROM "+retsqlname("SF2") +" SF2 WITH (NOLOCK) "
			cQryEXT += " JOIN "+retsqlname("SD2") +" SD2 WITH (NOLOCK) "
			cQryEXT += " ON SF2.F2_FILIAL = SD2.D2_FILIAL "
			cQryEXT += " AND SF2.F2_DOC = SD2.D2_DOC   "
			cQryEXT += " AND SF2.F2_CLIENTE = SD2.D2_CLIENTE "
			cQryEXT += " AND SF2.F2_LOJA = SD2.D2_LOJA  "
			cQryEXT += " WHERE SF2.F2_FILIAL  = '"+cFilPV+"'  "    
			cQryEXT += " AND SF2.F2_CLIENTE = '"+cCliCod+"' "
			cQryEXT += " AND SF2.F2_LOJA 	= '"+cCliLoj+"' "
			cQryEXT += " AND SF2.F2_DOC     = '"+PADL(_nNumNf,9,"0")+"' "  
			cQryEXT += " AND SD2.D2_COD     = '"+cProdPV+"'"
			cQryEXT += " AND SF2.D_E_L_E_T_ = '' "	
			cQryEXT += " AND SD2.D_E_L_E_T_ = '' " 
			
			If Select("VEXT") > 0
				VEXT->(DbCloseArea())
			EndIf
			
			TcQuery cQryEXT New Alias "VEXT"
			
			DbSelectArea("VEXT")
			VEXT->(dbGoTop())  
			If VEXT->RECNFEXT <= 0
			
				MsgInfo ("Aten็ใo. Nota Fiscal: " +PADL(_nNumNf,9,"0")+ " Cliente:" +cCliCod+"-"+cCliLoj+ " nใo localizada. Por favor, verificar")
				lRetLin     := .F.
			
			EndIF
			
			VEXT->(DbCloseArea())
			
		    //verificar se a nota que esta sendo lan็ada nao esta cancelada.
		    cQryCAN :=  " SELECT COUNT(SF2.F2_DOC) AS RECNFCAN  "
			cQryCAN +=  " FROM "+retsqlname("SF2") +" SF2 WITH (NOLOCK) INNER JOIN "+retsqlname("C00") +" C00 WITH (NOLOCK) ON " 
			cQryCAN +=  " SF2.F2_CHVNFE = C00.C00_CHVNFE  "
			cQryCAN +=  " WHERE  "
			cQryCAN +=  " SF2.F2_FILIAL = '"+cFilPV+"'  "
			cQryCAN +=  " AND C00.C00_SITDOC = '3'  "
			cQryCAN +=  " AND SF2.D_E_L_E_T_ = '*' "
			cQryCAN +=  " AND C00.D_E_L_E_T_ = '' "
			cQryCAN +=  " AND SF2.F2_DOC = '"+PADL(_nNumNf,9,"0")+"'"   
			cQryCAN +=  " GROUP BY F2_DOC "  
			
			If Select("VSF2") > 0
				VSF2->(DbCloseArea())
			EndIf
			
			TcQuery cQryCAN New Alias "VSF2" 
			
			DbSelectArea("VSF2")
			VSF2->(dbGoTop()) 
							
			If VSF2->RECNFCAN > 0
			
				MsgInfo ("Aten็ใo. Nota Fiscal " +PADL(_nNumNf,9,"0")+ " com situa็ใo Cancelada . Por favor, verificar")
				lRetLin := .F.
				
			EndIF
			//Fim - Fernando Sigoli Chamado:043085 13/08/2018  
			
			VSF2->(DbCloseArea()) 
			
			//Inicio: fernando sigoli 30/08/2018
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			
			cQuery := " SELECT ZV5_NUMNFS, ZV5_NUMOC "
			cQuery += " FROM " + RetSqlName("ZV5")
			cQuery += " WHERE ZV5_FILIAL='"+xFilial("ZV5")+"' "
			cQuery += " AND ZV5_NUMNFS='"+PADL(_nNumNf,9,"0")+"' "
			cQuery += " AND D_E_L_E_T_='' "                                      
			
			tcQuery cQuery new alias "Work"
			
			Work->( dbGoTop() )
			
			If Work->( !EOF() )
			
				If !Empty(Work->ZV5_NUMNFS) .AND. Work->ZV5_NUMOC  <> _ORDEM
			
					MsgInfo ("Aten็ใo. Nota Fiscal " +PADL(_nNumNf,9,"0")+ " ja utilizada nos apontamentos de Apanha. OC: "+Work->ZV5_NUMOC+ " . Por favor, verificar") 
					lRetLin := .F.
				  
				EndIf
			
			EndIf
			
			If Select("Work") > 0
				Work->( dbCloseArea() )
			EndIf
			//Fim:fernando sigoli 30/08/2018
			
		ENDIF
	END
	
	RestArea(_aArea)
	
RETURN(lRetLin)