#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FILEIO.CH"
#INCLUDE "TopConn.CH"  
#INCLUDE "rwmake.ch"          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณADEST011P บAutor  ณWILLIAM COSTA       บ Data ณ  11/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de transferencias de estoque conforme parametriza-บฑฑ
ฑฑบ          ณ cao da tabela ZBA.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAlteracao ณChamado: 049041 - Fernando Sigoli - 08/05/2019 Altera็ใo    บฑฑ      
ฑฑบ          ณde Alias TRB --> ESTTRB, TRC --> ESTTRC. Devido estes       บฑฑ
ฑฑบ          ณmesmos alias  estarem usando no ponto de entrada A261TOK	  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ADEST011P()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Define Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Private aSays		:= {}
	Private aButtons	:= {}   
	Private cCadastro	:= "ADEST011P - TRANSFERสNCIAS DE ESTOQUE ADORO"    
	PRIVATE oFontA06	:= TFont():New( "Arial",,10,,.f.,,,,,.f. )
	PRIVATE oFontA09	:= TFont():New( "Arial",,-9,,.f.,,,,,.f. )
	PRIVATE oFontA09b	:= TFont():New( "Arial",,-9,,.t.,,,,,.f. )
	PRIVATE oFontA07	:= TFont():New( "Arial",,12,,.T.,,,,,.f. )
	PRIVATE oPrn		:= TMSPrinter():New()
	Private nOpca		:= 0
	Private cPerg		:= 'ADEST011P'
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Programa de transferencias de estoque conforme parametrizacao da tabela ZBA')
	
	//+------------------------------------------------+
	//|Cria grupo de Perguntas                         |
	//+------------------------------------------------+
	 MontaPerg()
	 
	 //+-----------------------------------------------+
	//|Monta Form Batch - Interface com o Usuario     |
	//+-----------------------------------------------+
	AADD(aSays,"Efetua transfer๊ncias de estoque conforme parametriza็ใo da tabela ZBA. " )
	
	AADD(aButtons, { 15,.T.,{|o| nOpca:=15, ProcLogView(cFilAnt,"ADEST011P") }})
	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) }})
	AADD(aButtons, { 1,.T.,{|o| nOpca:=1, o:oWnd:End(), Processa({||ProcFile()},"Transferindo Produtos","Aguarde...")    }})
	AADD(aButtons, { 2,.T.,{|o| nOpca:=2, o:oWnd:End() }})
	  
	FormBatch( cCadastro, aSays, aButtons )  
	
Return (Nil)

Static Function ProcFile() 

	Private cDoc            := ''
	Private cNumseq         := ''
	Private cLocalizOrigem  := ''
	Private cLocalizDestino := ''
	Private cMensagem       := ''
	Private aQuant          := {}
	Private nQuant          := 0
	Private nCont           := 1
    Private aItens          := {}   
	Private cErro           := ''
	Private cDescProd       := ''                     
	Private cUMProd         := ''
	Private dData			:= DDATABASE 
	Private nQuantEstoque   := 0
		
    ProcLogIni( {},"ADEST011P")
    
    IF DTOC(MV_PAR09)  <> '  /  /    '           .AND. ;
       MV_PAR09         > SuperGetMv("MV_ULMES") .AND. ;
       MONTH(MV_PAR09)  = MONTH(MV_PAR10)        .AND. ;
       MONTH(MV_PAR09)  = MONTH(MV_PAR11)        .AND. ;
       MV_PAR11        >= MV_PAR10
    
	    SqlTransferencia()  
	                        
	    cMensagem := ''
	    
	    DbSelectArea("ESTTRB") 
	    While ESTTRB->(!EOF())        
	    	
	    	nCont         := 0          
	    	nQuantEstoque := 0
	    
	    	// *** 	INICIO A VERIFICICAO SE EXISTE QUANTIDADE NO ESTOQUE > 0 *** //
	    
	    	DbSelectArea("SB2") 
			
				SB2->(DbSetOrder(1))
			
				If SB2->(DbSeek( xFilial("SB2") + ESTTRB->ZBA_CODORI + ESTTRB->ZBA_LOCORI,.T.))
				    
					            
					aQuant := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR09+1) 
					
				EndIf
				
			SB2->( DBCLOSEAREA() )  
			
			For nCont:=1 to Len(aQuant)
						
				nQuantEstoque := aQuant[1]
							
			Next nCont  
			
			// *** 	FINAL A VERIFICICAO SE EXISTE QUANTIDADE NO ESTOQUE > 0 *** //
			
			IF nQuantEstoque > 0 
	    
		    	SqlVMovimentosInternos(ESTTRB->ZBA_CODORI)
			    While ESTTRC->(!EOF())
			    
			    	cDoc            := ''   
		    		cNumseq         := ''        
		    		cLocalizOrigem  := ''
		        	cLocalizDestino := ''
		        	nCont           := 1
		        	nQuant          := 0 
		        	aItens          := {}
			    	cDoc            := NextNumero("SD3",2,"D3_DOC",.T.) //GetSXENum("SD3","D3_DOC") 
					cNumseq         := ProxNum()   
					
					AADD(aItens,{cDoc	 ,STOD(ESTTRC->D3_EMISSAO)})
					
			    	nQuant := ESTTRC->D3_QUANT
								
					IF nQuant <= 0
					
						cMensagem += "Produto Origem: " + ESTTRB->ZBA_CODORI + " - " + Posicione("SB1",1,xFilial("SB1") + ESTTRB->ZBA_CODORI, "B1_DESC")  + CHR(13) + CHR(10) + ;
						             "Local Origem:   " + ESTTRB->ZBA_LOCORI                                                                           + CHR(13) + CHR(10) + ;
						             "Produto Destino:" + ESTTRB->ZBA_CODDES + " - " + Posicione("SB1",1,xFilial("SB1") + ESTTRB->ZBA_CODDES, "B1_DESC")  + CHR(13) + CHR(10) + ;
						             "Local Destino:  " + ESTTRB->ZBA_LOCDES                                                                           + CHR(13) + CHR(10) + ;
						             "Motivo: Quantidade menor ou igual a 0 no estoque, Quantidade = " + cValtochar(nQuant)                         + CHR(13) + CHR(10) + ;
						             "------------------------------------------------------------------------------------------------  "           + CHR(13) + CHR(10) + ;
						             CHR(13) + CHR(10) 
						
					   	ESTTRC->(dbSkip()) 
					   	LOOP
					   	
					ENDIF   
					
					IF Substr(ALLTRIM(cDoc),1,5) == 'INVEN'   
					
						cMensagem += "Produto Origem: " + ESTTRB->ZBA_CODORI + " - " + Posicione("SB1",1,xFilial("SB1") + ESTTRB->ZBA_CODORI, "B1_DESC")  + CHR(13) + CHR(10) + ;
						             "Local Origem:   " + ESTTRB->ZBA_LOCORI                                                                           + CHR(13) + CHR(10) + ;
						             "Produto Destino:" + ESTTRB->ZBA_CODDES + " - " + Posicione("SB1",1,xFilial("SB1") + ESTTRB->ZBA_CODDES, "B1_DESC")  + CHR(13) + CHR(10) + ;
						             "Local Destino:  " + ESTTRB->ZBA_LOCDES                                                                           + CHR(13) + CHR(10) + ;
						             "Motivo: Consta um Inventario no movimento Interno ้ necessario ter um outro tipo de movimenta็ใo  "           + CHR(13) + CHR(10) + ;
						             "------------------------------------------------------------------------------------------------  "           + CHR(13) + CHR(10) + ;
						             CHR(13) + CHR(10) 
						
					   	ESTTRC->(dbSkip()) 
					   	LOOP
					ENDIF   
					
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))  
					
					IF SB1->(DbSeek( xFilial("SB1") + ESTTRB->ZBA_CODORI, .T.))
					
						//tratamento para criar armazem no SB2 - destino
						DbSelectArea("SB2") 
						
							SB2->(DbSetOrder(1))
						
							If !SB2->(DbSeek( xFilial("SB2") + ESTTRB->ZBA_CODDES + ESTTRB->ZBA_LOCDES,.T.))
							    
								
								CriaSB2(ESTTRB->ZBA_CODDES,ESTTRB->ZBA_LOCDES)
								
							EndIf
							
						SB2->( DBCLOSEAREA() )   
						
						cLocalizOrigem  := IIF(ALLTRIM(ESTTRB->ZBA_LOCORI) == '03',GetMv("MV_X_ENPRO"),Posicione("SBE",10,xFilial("SBE")+ESTTRB->ZBA_CODORI+ESTTRB->ZBA_LOCORI,"BE_LOCALIZ"))
				        cLocalizDestino := IIF(ALLTRIM(ESTTRB->ZBA_LOCDES) == '03',GetMv("MV_X_ENPRO"),Posicione("SBE",10,xFilial("SBE")+ESTTRB->ZBA_CODDES+ESTTRB->ZBA_LOCDES,"BE_LOCALIZ"))
				        cDescProd       := Posicione("SB1",1,xFilial("SB1")+ESTTRB->ZBA_CODDES,"B1_DESC")
						cUMProd         := Posicione("SB1",1,xFilial("SB1")+ESTTRB->ZBA_CODORI,"B1_UM")
					
				        nCont++
						aadd (aItens,{})
						aItens[nCont] :=  {{"D3_COD" 	, ESTTRB->ZBA_CODORI	   ,NIL}}// 01.Produto Origem
						aAdd(aItens[nCont],{"D3_DESCRI" , SB1->B1_DESC		   ,NIL})// 02.Descricao
						aAdd(aItens[nCont],{"D3_UM"     , SB1->B1_UM		   ,NIL})// 03.Unidade de Medida
						aAdd(aItens[nCont],{"D3_LOCAL"  , ESTTRB->ZBA_LOCORI	   ,NIL})// 04.Local Origem
						aAdd(aItens[nCont],{"D3_LOCALIZ", cLocalizOrigem	   ,NIL})// 05.Endereco Origem
						aAdd(aItens[nCont],{"D3_COD"    , ESTTRB->ZBA_CODDES     ,NIL})// 06.Produto Destino
						aAdd(aItens[nCont],{"D3_DESCRI" , cDescProd		       ,NIL})// 07.Descricao
						aAdd(aItens[nCont],{"D3_UM"     , cUMProd		       ,NIL})// 08.Unidade de Medida
						aAdd(aItens[nCont],{"D3_LOCAL"  , ESTTRB->ZBA_LOCDES	   ,NIL})// 09.Armazem Destino
						aAdd(aItens[nCont],{"D3_LOCALIZ", cLocalizDestino      ,NIL})// 10.Endereco Destino
						aAdd(aItens[nCont],{"D3_NUMSERI", CriaVar("D3_NUMSERI"),NIL})// 11.Numero de Serie
						aAdd(aItens[nCont],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL})// 12.Lote Origem
						aAdd(aItens[nCont],{"D3_NUMLOTE", CriaVar("D3_NUMLOTE"),NIL})// 13.Sub-Lote
						aAdd(aItens[nCont],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL})// 14.Data de Validade
						aAdd(aItens[nCont],{"D3_POTENCI", CriaVar("D3_POTENCI"),NIL})// 15.Potencia do Lote
						aAdd(aItens[nCont],{"D3_QUANT"  , nQuant    		   ,NIL})// 16.Quantidade
						aAdd(aItens[nCont],{"D3_QTSEGUM", CriaVar("D3_QTSEGUM"),NIL})// 17.Quantidade na 2 UM
						aAdd(aItens[nCont],{"D3_ESTORNO", CriaVar("D3_ESTORNO"),NIL})// 18.Estorno
						aAdd(aItens[nCont],{"D3_NUMSEQ" , cNumseq			   ,NIL})// 19.NumSeq
						aAdd(aItens[nCont],{"D3_LOTECTL", CriaVar("D3_LOTECTL"),NIL})// 20.Lote Destino
						aAdd(aItens[nCont],{"D3_DTVALID", CriaVar("D3_DTVALID"),NIL})// 21.Data de Validade Destino
						
						Begin Transaction
						             
							IF LEN(aItens) >= 1 
								lMsErroAuto := .F.
								
								DDATABASE := STOD(ESTTRC->D3_EMISSAO)
								
								MsExecAuto({|x| MATA261(x)},aItens)
								
								DDATABASE := dData
								
								IF lMsErroAuto
									DisarmTransaction()
									cErro := MostraErro()
									
									cMensagem += "Motivo:         " + cErro                                                                                     + CHR(13) + CHR(10) + ;
									             "------------------------------------------------------------------------------------------------  "           + CHR(13) + CHR(10) + ;
									             CHR(13) + CHR(10)
								ELSE
								    
									cMensagem += "Motivo:         " + "Processado com Sucesso e DOC = " + cDoc                                                  + CHR(13) + CHR(10) + ;
									             "------------------------------------------------------------------------------------------------  "           + CHR(13) + CHR(10) + ;
									             CHR(13) + CHR(10)
									             
									ProcLogAtu("Processado com Sucesso e DOC = " + cDoc)
									              
								ENDIF                
								
								
				            ENDIF
						End Transaction 
				    ENDIF
						
				 	SB1->( DBCLOSEAREA() )   
			       
			    ESTTRC->(dbSkip())
				ENDDO                                              
				
				//Chamado: 049041 - Fernando Sigoli 08/05/2019
				If Select("ESTTRC") > 0
					ESTTRC->( dbCloseArea() )
				EndIf

				//ESTTRC->(dbCloseArea())
		    
		    ENDIF // IF nQuantEstoque > 0 
		
		ESTTRB->(dbSkip())
		ENDDO
		 
		//Chamado: 049041 - Fernando Sigoli 08/05/2019
		If Select("ESTTRB") > 0
			ESTTRB->( dbCloseArea() )
		EndIf

		//ESTTRB->(dbCloseArea())
		
	ELSE 
    
    	ALERT("Erros Possiveis: "                                           + CHR(13) + CHR(10) +;
    	      "1-) Data do Saldo em Branco;"                                + CHR(13) + CHR(10) +;
    	      "2-) Data do Saldo menor que data do Fechamento do Estoque; " + CHR(13) + CHR(10) +;
    	      "3-) Data de Transfer๊ncia nใo ้ o mesmo m๊s da Data Saldo; " + CHR(13) + CHR(10) +;
    	      "favor verificar, nใo ้ possํvel continuar!!!")
    
    ENDIF
    
    ProcLogAtu("ADEST011P")
    
    IF ALLTRIM(cMensagem) <> ''
    
    	U_ExTelaMen("ADEST011P - Tela de Produtos nใo Processados!!!", cMensagem, "Arial", 10, , .F., .T.)
    	
	ENDIF
	
	Msginfo('Processamento concluido com sucesso !!!')
	
Return( NIL )                              

Static Function MontaPerg()                                  
	Private bValid	:=Nil 
	Private cF3		:=Nil
	Private cSXG	:=Nil
	Private cPyme	:=Nil
	
    PutSx1(cPerg,'01','Produto de Origem De  ?','','','mv_ch01','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR01')
	PutSx1(cPerg,'02','Produto de Origem Ate ?','','','mv_ch02','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR02')
	PutSx1(cPerg,'03','Local de Origem De    ?','','','mv_ch03','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR03')
	PutSx1(cPerg,'04','Local de Origem Ate   ?','','','mv_ch04','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR04')
	PutSx1(cPerg,'05','Produto Destino De    ?','','','mv_ch05','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR05')
	PutSx1(cPerg,'06','Produto Destino Ate   ?','','','mv_ch06','C',06,0,0,'G',bValid,"SB1",cSXG,cPyme,'MV_PAR06')
	PutSx1(cPerg,'07','Local Destino de      ?','','','mv_ch07','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR07')
	PutSx1(cPerg,'08','Local Destino Ate     ?','','','mv_ch08','C',06,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR08')
	PutSx1(cPerg,'09','Data Saldo            ?','','','mv_ch09','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR09')
	PutSx1(cPerg,'10','Data Ini Transf       ?','','','mv_ch09','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR10')
	PutSx1(cPerg,'11','Data Fin Transf       ?','','','mv_ch10','D',08,0,0,'G',bValid,cF3  ,cSXG,cPyme,'MV_PAR11')
	Pergunte(cPerg,.F.)
Return (Nil)  

Static Function SqlTransferencia()                   

	Local cFil := xFilial("ZBA")
	
	//Chamado: 049041 - Fernando Sigoli 08/05/2019
	If Select("ESTTRB") > 0
		ESTTRB->( dbCloseArea() )
	EndIf

	BeginSQL Alias "ESTTRB"
			%NoPARSER%     
			SELECT ZBA_CODORI,
			       ZBA_LOCORI,
			       ZBA_CODDES,
			       ZBA_LOCDES
			  FROM %Table:ZBA% ZBA
			 WHERE ZBA_FILIAL      = %exp:cFil%
			   AND ZBA_CODORI     >= %exp:MV_PAR01%
			   AND ZBA_CODORI     <= %exp:MV_PAR02%
			   AND ZBA_LOCORI     >= %exp:MV_PAR03%
			   AND ZBA_LOCORI     <= %exp:MV_PAR04%
			   AND ZBA_CODDES     >= %exp:MV_PAR05%
			   AND ZBA_CODDES     <= %exp:MV_PAR06%
			   AND ZBA_LOCDES     >= %exp:MV_PAR07%
			   AND ZBA_LOCDES     <= %exp:MV_PAR08%  
			   AND ZBA_STATUS      = '1'
			   AND ZBA.D_E_L_E_T_ <> '*'
    EndSQl    
             
RETURN(NIL)

Static Function SqlVMovimentosInternos(cCod)                   

	Local cFil     := xFilial("SD3")
	Local cDataIni := DTOS(MV_PAR10)
	Local cDataFin := DTOS(MV_PAR11)                  
	
	//Chamado: 049041 - Fernando Sigoli 08/05/2019
	If Select("ESTTRC") > 0
		ESTTRC->( dbCloseArea() )
	EndIf

	BeginSQL Alias "ESTTRC"
			%NoPARSER%  
			SELECT D3_FILIAL,
			       D3_COD,
				   D3_CF,
				   D3_QUANT,
				   D3_LOCAL,
				   D3_EMISSAO
			 FROM %Table:SD3%
			WHERE D3_FILIAL   = %exp:cFil%
			  AND D3_COD      = %exp:cCod%
			  AND D3_CF       = 'DE4'
			  AND D3_EMISSAO >= %exp:cDataIni%
			  AND D3_EMISSAO <= %exp:cDataFin%     
			  AND D3_LOCAL   >= %exp:MV_PAR03%
			  AND D3_LOCAL   <= %exp:MV_PAR04%
			  AND D3_ESTORNO  = ''
			  AND D_E_L_E_T_ <> '*'  
			  
	     ORDER BY D3_EMISSAO
	EndSQl            
	 
RETURN(NIL)
