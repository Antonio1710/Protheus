#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AD0088   º Autor ³ Gustavo Gonela     º Data ³  05/11/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Fechamento por Veiculo / Transportadora                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Logistica                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º02/03/07  ³ DANIEL - REFEITO, PASSADO PARA TOPCONNECT                  º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                                        

User Function AD0088

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01             // Data de                              |
	//³ mv_par02             // Data ate                             ³
	//| mv_par03             // Transportadora de                    |
	//³ mv_par04             // Transportadora ate                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Fechamento por Veiculo / Transportadora')
	
	cPerg   := "AD0088"
	Pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	
	cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	cDesc2       := "de acordo com os parametros informados pelo usuario."
	cDesc3       := "Fechamento Veiculo / Transportadora"
	cPict        := ""
	titulo       := "Fechamento Veiculo / Transportadora"
	nLin         := 65
	Cabec1       := ""
	Cabec2       := ""
	imprime      := .T.
	aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "G"
	Private nomeprog     := "AD0088" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01      
	Private wnrel        := "AD0088" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cGuiaAnt     := ""
	
	Private cString := "SZK"
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  18/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	
	dbSelectArea(cString)
	dbSetOrder(1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SetRegua(RecCount())
	
	// Parametros
	_dDtEntr  := mv_par01
	_dDtEntr2 := mv_par02
	_cTransp  := mv_par03
	_cTransp2 := mv_par04
	_cTipFrt  := mv_par05
	
	// Variaveis de Trabalho
	_nTotFret   := 0
	_nTotPeso   := 0
	_nEntr      := 0
	_nViag      := 0
	_nTotEntr   := 0
	_ntTKmpag   := 0
	_TTotFret   := 0
	_TTotPeso   := 0
	_TTotEntr   := 0
	_TtTKmpag   := 0
	_TViag	    := 0
	_nTotAcres  := 0
	_nTotDesc   := 0
	_nTotFret   := 0
	_nTotPeso   := 0
	_nTotEntr   := 0
	_ntTKmpag   := 0
	
	//+---------------------------------+
	//|Total Geral Por transportadora   |
	//+---------------------------------+
	_nTransG:={0,0,0}
	//Tota Pago,Acrecimo, desconto
	//+---------------------------------+
	//|Total Geral                      |
	//+---------------------------------+
	_nToTG:={0,0,0}
	//Tota Pago,Acrecimo, desconto
	
	//Cabec5  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"
	//Cabec6  := "|   DATA    |      TOTAL FRETE       |      PESO       |  ENTR.  |      KM      |       DESCRICAO       |     ACRESCIMO     |     DESCONTO      |"
	//Cabec7  := "|-----------------------------------------------------------------------------------------------------------------------------------------------|"
	
	//Cabec7  := "|=============================================================================================================================================|"
	//Cabec8  := "|=============================================================================================================================================|"
	//Cabec9  := "|=============================================================================================================================================***|"
	
	
	Cabec1  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
	//Cabec2  := SPACE(02)+ "Transportador: " + _cTransp + SPACE(07) +"Veiculo : " +_cVeic
	Cabec3  := "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	Cabec4  := "|            |           |      |            |             |               |                                           ** DESCONTO E ACRESCIMO **                                       |"
	Cabec5  := "|    DATA    | INTEGRADO | ENT. |     KM     |     PESO    |  TOTAL FRETE  |         DESCRICAO                    |            OBSERVAÇÃO              |    ACRESCIMO    |   DESCONTO   |"
	Cabec6  := "|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	
	Cabec9   := "Relacao dos Fretes"
	Cabec10  := "Relacao dos Descontos e Acrescimos"
	
	//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14
	//          0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234
	
	//+---------------------------------+
	//|MONTA QUERY NO SZK               |
	//+---------------------------------+
	QrySzk()
	_cFornec:=xSZK->ZK_FORNEC
	_cPlac:=xSZK->ZK_PLACAPG
	lVez:='S'
	
	//+-------------------------------------+
	//|Enquanto nao for fim de arquivo      |
	//+-------------------------------------+
	DO While !EOF ()
		//+--------------------------------+
		//|Enquanto for o mesmo fornecedor |
		//+--------------------------------+    
		_cPlacAnt := ""
		_cPlac2Ant := ""
		While !eof() .and. _cFornec=xSZK->ZK_FORNEC
							
			//+--------------------------------+
			//|Enquanto for no mesma placa     |
			//+--------------------------------+
			While !eof() .and. _cPlac==xSZK->ZK_PLACAPG
										
				If nLin > 60 .or. (_cPlacAnt <> _cPlac) 
				
					If (_nTotFret <> 0  .OR. _nTotPeso <> 0) 
						@nLin,000 PSAY "|"+ Replicate ("=",183)+ "|"
						nLin := nLin + 1
						@nLin,000 PSAY "|"
						@nLin,002 PSAY " TOTAL "
						@nLin,013 PSAY "|" 
						@nLin,025 PSAY "|"                        
						@nLin,027 PSAY _nTotEntr  Picture "@E 9999"
						@nLin,032 PSAY "|"				
						@nLin,034 PSAY _ntTKmpag   Picture "@E 999,999.99"
						@nLin,045 PSAY "|"			
						@nLin,048 PSAY _nTotPeso  Picture "@E 999,999.99"
						@nLin,059 PSAY "|"			
						@nLin,064 PSAY _nTotFret Picture "@E 999,999.99"			
						@nLin,075 PSAY "|"
						
						@nLin,114 PSAY "|"					
						@nLin,116 PSAY "TOTAL "
						@nLin,151 PSAY "|"					
						@nLin,156 PSAY _nTotAcres Picture "@E 9,999,999.99"
						@nLin,169 PSAY "|"					
						@nLin,170 PSAY _nTotDesc Picture "@E 9,999,999.99"
						@nLin,184 PSAY "|"										
				
						nLin := nLin + 1
						@nLin,000 PSAY "|"+ Replicate ("=",183)+ "|"
						nLin := nLin + 1
						@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS: "
						@nLin,021 PSAY _nViag                       					
						       
						nLin := nLin + 1
						@nLin,000 PSAY Replicate ("_",185)
						nLin := nLin + 1
						
						@nLin,002 PSAY "TOTAL A PAGAR: "
						@nLin,019 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99"	   //AB
						
						nLin := nLin + 1
						@nLin,000 PSAY Replicate ("_",185)
						nLin := nLin + 2
				
						_TTotFret  := _nTotFret
						_TTotPeso  := _nTotPeso
						_TTotEntr  := _nTotEntr
						_TtTKmpag  := _ntTKmpag
						_TViag	   := _nViag
						_nTotFret  := 0
						_nTotPeso  := 0
						_nTotEntr  := 0
						_ntTKmpag  := 0
						_nViag	   := 0
						_nTotAcres := 0
						_nTotDesc  := 0			
					Endif	
					
					DbselectArea("ZV4")
					DbSetOrder(1)
					dbseek(xFilial("ZV4")+_cPlac,.T.)
					//@nLin,000 PSAY "PLACA :" +_cPlac+" "+ZV4->ZV4_NOMFOR
					//nLin++								
					Cabec2  := SPACE(02)+ "Trans.: " + ZV4_FORNEC+" "+ZV4_LOJFOR+" "+ZV4_NOMFOR+SPACE(03) +"Veiculo : " +ZV4_PLACA            
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9  				
					DbselectArea("xSZK")			
					
					@nLin,000 PSAY CABEC9
					nLin := nLin + 1
					@nLin,000 PSAY CABEC3
					nLin := nLin + 1
					@nLin,000 PSAY CABEC4
					nLin := nLin + 1
					@nLin,000 PSAY CABEC5
					nLin := nLin + 1     
					@nLin,000 PSAY CABEC6
					nLin := nLin + 1				
				Endif
				           
				@nLin,000 PSAY "|"
				@nLin,002 PSAY stod(xSZK->ZK_DTENTR)
				@nLin,013 PSAY "|" 
				
				DbselectArea("ZV1")
	            DbSetOrder(3)
				dbGoTop()			
				If dbseek(xFilial("ZV1")+xSZK->ZK_NUMOC)      //integrado (granja) NUMOC
					@nLin,019 PSAY Alltrim(ZV1->ZV1_RGRANJ) 
				Endif
				    
				@nLin,025 PSAY "|"//integrado
				@nLin,027 PSAY xSZK->ENTREGAS 	  Picture "@E 9999"
				@nLin,032 PSAY "|" 			
				@nLin,034 PSAY xSZK->ZK_KMPAG     Picture "@E 999,999.99"  
				@nLin,045 PSAY "|" 								
				@nLin,048 PSAY xSZK->ZK_PBRUTO    Picture "@E 999,999.99"			
				@nLin,059 PSAY "|"			
				@nLin,064 PSAY xSZK->ZK_VALFRET   Picture "@E 999,999.99"  
				//@nLin,063 PSAY "|"
				//@nLin,092 PSAY "|"
				//@nLin,108 PSAY "|"	 		
				//@nLin,123 PSAY "|"			
				
				_nTotFret   += xSZK->ZK_VALFRET
				_nTotPeso   += xSZK->ZK_PBRUTO
				_ntTKmpag   += xSZK->ZK_KMPAG
				_nTotEntr   += xSZK->ENTREGAS
				_nViag      += 1
				_nEntr      := 0
				
				//imprime os desconto e acrescimos da placa
				cGuiaAnt := ""
				nLin:=QrySZI(_cPlac,nLin,stod(xSZK->ZK_DTENTR),xSZK->ZK_GUIA,xSZK->ZK_ROTEIRO)
	//			nLin:=QrySZI(_cPlac,nLin,stod(xSZK->ZK_DTENTR))
				nLin := nLin + 1			
				//@nLin,000 PSAY  "|--------------------------------------------------------------------------------------------------------------------------|"			
				//nLin := nLin + 1
				
				_cPlacAnt := _cPlac			
				
				xSZK->(DbSkip())
			End
			lVez:='N'		
			
			_cPlac:=xSZK->ZK_PLACAPG
			dbSelectArea("xSZK")
		End	                   	
		
		_cFornec:=xSZK->ZK_FORNEC
		dbSelectArea("xSZK")
		DbSkip()
	Enddo
	
	If (_nTotFret <> 0  .OR. _nTotPeso <> 0)            //ultima folha
		@nLin,000 PSAY "|"+ Replicate ("=",183)+ "|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL "
		@nLin,013 PSAY "|" 
		@nlin,025 PSAY "|"                       
		@nLin,027 PSAY _nTotEntr  Picture "@E 9999"
		@nLin,032 PSAY "|"				
		@nLin,034 PSAY _ntTKmpag   Picture "@E 999,999.99"
		@nLin,045 PSAY "|"			
		@nLin,048 PSAY _nTotPeso  Picture "@E 999,999.99"
		@nLin,059 PSAY "|"			
		@nLin,064 PSAY _nTotFret Picture "@E 999,999.99"			
		@nLin,075 PSAY "|"
		
		@nLin,114 PSAY "|"
		@nLin,116 PSAY "TOTAL "
		@nLin,151 PSAY "|"
		@nLin,156 PSAY _nTotAcres Picture "@E 9,999,999.99"
		@nLin,169 PSAY "|"
		@nLin,170 PSAY _nTotDesc Picture "@E 9,999,999.99"
		@nLin,184 PSAY "|"
				
		nLin := nLin + 1
		@nLin,000 PSAY "|"+ Replicate ("=",183)+ "|"
		nLin := nLin + 1
		@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS: "
		@nLin,021 PSAY _nViag
						
		nLin := nLin + 1
		@nLin,000 PSAY Replicate ("_",185)
		nLin := nLin + 1
						
		@nLin,002 PSAY "TOTAL A PAGAR: "
		@nLin,029 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99" //alterado de 22 a 12
						
		nLin := nLin + 1
		@nLin,000 PSAY Replicate ("_",185)
		nLin := nLin + 2
			
		_TTotFret  := _nTotFret
		_TTotPeso  := _nTotPeso
		_TTotEntr  := _nTotEntr
		_TtTKmpag  := _ntTKmpag
		_TViag	   := _nViag
		_nTotFret  := 0
		_nTotPeso  := 0
		_nTotEntr  := 0
		_ntTKmpag  := 0
		_nViag	   := 0
		_nTotAcres := 0
		_nTotDesc  := 0			
	Endif	
	
	dbCloseArea("xSZK")
	dbCloseArea("xSZI")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AD0088    ºAutor  ³DANIEL              º Data ³  03/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta query so SZK                                          º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function QrySzk()

	Local cQuery:=""
	
	cQuery+=" SELECT "
	cQuery+=" 	ZK_TIPFRT, "
	cQuery+=" 	ZK_PLACAPG, "
	cQuery+=" 	ZK_DTENTR, "
	cQuery+=" 	ZK_FORNEC, "
	cQuery+=" 	ZK_VALFRET, "
	cQuery+=" 	ZK_PBRUTO, "
	cQuery+=" 	ZK_ENTREGA-ZK_ENTRDEV AS ENTREGAS, "
	cQuery+=" 	ZK_KMPAG, "
	cQuery+=" ZK_NOMFOR, "
	cQuery+=" ZK_NUMOC, "
	cQuery+=" ZK_GUIA, "
	cQuery+=" ZK_ROTEIRO "
	cQuery+=" FROM "+RETSQLNAME("SZK")+" "
	cQuery+=" WHERE "
	cQuery+=" 	(ZK_DTENTR BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"') AND "
	cQuery+=" 	(ZK_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') AND "
	cQuery+=" 	ZK_TIPFRT='"+MV_PAR05+"' AND "
	cQuery+=" 	D_E_L_E_T_='' "
	cQuery+=" ORDER BY "
	cQuery+=" ZK_PLACAPG,ZK_DTENTR "
	
	TCQUERY cQuery NEW ALIAS "xSZK"
	dbselectArea("xSZK")
	DbgoTop()

Return()

//+-----------------------------+
//|seleciona as guias no SZI    |
//+-----------------------------+
Static Function QrySZI(cPlaca,xLin,cDataSZK,cCodGuia,cRoteiro)

	If Select("xSZI") > 0
	   DbSelectArea("xSZI")
	   DbCloseArea("xSZI")
	Endif
	
	//cQuery1 +=	" ZK_GUIA=ZI_GUIA "
	//cQuery1 +=	" AND ZK_GUIA='" + Alltrim(cCodGuia) + "' "        
	
	//alteração will
	
	IF ALLTRIM(MV_PAR05) = 'FV' //FRANGO VIVO
	
		cQuery1 := 	" SELECT ZI_GUIA, ZI_PLACA, ZI_DATALAN,ZI_TIPO, ZI_VALOR,ZI_DESCRIC,ZI_OBS "
		cQuery1 +=	" FROM "+RETSQLNAME("SZI")+", "+RETSQLNAME("SZK")+" "
		cQuery1 +=	" WHERE "
		cQuery1 +=	" ZK_GUIA='" + Alltrim(cCodGuia) + "' "
		cQuery1 +=	" AND ZK_TIPFRT='"+MV_PAR05+"' "
		cQuery1 +=	" AND (ZK_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
		cQuery1 +=	" AND ( ZK_DTENTR BETWEEN '"+DTOS(cDataSZK) +"' AND '"+DTOS(cDataSZK)+"')"
		cQuery1 +=	" AND ZI_PLACA='"+cPlaca+"' "
		cQuery1 +=	" AND ZK_DTENTR=ZI_DATALAN " //chamado 021752
		cQuery1 +=	" AND ZK_PLACA=ZI_PLACA "
		cQuery1 +=	" AND ZK_GUIA=ZI_GUIA "
		cQuery1 +=	" AND "+RetSqlName("SZK")+ ".D_E_L_E_T_ <> '*' "
		cQuery1 +=	" AND "+RetSqlName("SZI")+ ".D_E_L_E_T_ <> '*' "
		cQuery1 +=	" ORDER BY ZI_PLACA, ZI_DATALAN "
	
	ELSE  // FRETE NORMAL
	
		cQuery1 := 	" SELECT ZI_GUIA, ZI_PLACA, ZI_DATALAN,ZI_TIPO, ZI_VALOR,ZI_DESCRIC,ZI_OBS "
		cQuery1 +=	" FROM "+RETSQLNAME("SZI")+", "+RETSQLNAME("SZK")+" "
		cQuery1 +=	" WHERE "
		cQuery1 +=	" ZK_GUIA='" + Alltrim(cCodGuia) + "' "
		cQuery1 +=	" AND ZK_TIPFRT='"+MV_PAR05+"' "
		cQuery1 +=	" AND (ZK_FORNEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') "
		cQuery1 +=	" AND ( ZK_DTENTR BETWEEN '"+DTOS(cDataSZK) +"' AND '"+DTOS(cDataSZK)+"')"
		cQuery1 +=	" AND ZK_PLACA='"+cPlaca+"' "
		cQuery1 +=	" AND ZK_ROTEIRO='"+cRoteiro+"' "
		cQuery1 +=	" AND ZK_DTENTR=ZI_DATALAN " //chamado 021752
		cQuery1 +=	" AND ZK_PLACA=ZI_PLACA "
		cQuery1 +=	" AND ZK_ROTEIRO = ZI_ROTEIRO "
		cQuery1 +=	" AND "+RetSqlName("SZK")+ ".D_E_L_E_T_ <> '*' "
		cQuery1 +=	" AND "+RetSqlName("SZI")+ ".D_E_L_E_T_ <> '*' "
		cQuery1 +=	" ORDER BY ZI_PLACA, ZI_DATALAN "
	
	ENDIF
	TCQuery cQuery1 new alias "xSZI"    
	
	
	DBSELECTAREA("xSZI")
	DBGOTOP()
	         
	lEntrSZI := .F.
	lEntrAC  := .F.
	lEntrDS  := .F.
	xLinOri  := xLin
	While !eof()
		If xLin > 60
			DbselectArea("ZV4")
			DbSetOrder(1)
			dbseek(xFilial("ZV4")+cPlaca,.T.)
			//@nLin,000 PSAY "PLACA :" +_cPlac+" "+ZV4->ZV4_NOMFOR
			//nLin++		   
			Cabec1  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)						
			Cabec2  := SPACE(02)+ "Trans.: " + ZV4_FORNEC+" "+ZV4_LOJFOR+" "+ZV4_NOMFOR+SPACE(03) +"Veiculo : " +ZV4_PLACA            
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			xLin := 9  				
			DbselectArea("xSZK")				
				
			@xLin,000 PSAY CABEC9
			xLin := xLin + 1
			@xLin,000 PSAY CABEC3
			xLin := xLin + 1
			@xLin,000 PSAY CABEC4
			xLin := xLin + 1
			@xLin,000 PSAY CABEC5
			xLin := xLin + 1     
			@xLin,000 PSAY CABEC6
			xLin := xLin + 1				
			
		Endif 
		
		//Ana - 07/07/14. Criação da variavel cGuiaAnt para evitar duplicidade de acrescimo / desconto quando a consulta da SZK gera mais de um retorno
		//WIlliam Costa - 30/01/2015. chamado 021752. Foi ajustado o select acima motivo, estava com a chave da tabela errado.
		//A chave da tabela e placa + data e so estava com a data gerando o erro de duplicidade adicionado a linha 485
		//cQuery1 +=	" AND ZK_DTENTR=ZI_DATALAN " //chamado 021752
		//Apos essa alteracao como a tabela esta carregando corretamente foi retirado o if que a ana fez por motivo de nao ter mais 
		//necessidade do mesmo pois a guia nao se repete mais.
		//If Alltrim(cGuiaAnt) <> Alltrim(xSZI->ZI_GUIA) // CHAMADO 021295
			IF TRIM(xSZI->ZI_TIPO) = 'A'
				lEntrSZI := .T.
		                       
				If xLinOri <> xLin 
					@xLin,000 PSAY "|"
					@xLin,013 PSAY "|" 
					@xLin,025 PSAY "|"
					@xLin,032 PSAY "|"
					@xLin,045 PSAY "|"	//ok
					@xLin,059 PSAY "|"	
				Endif	
			
				@xLin,075 PSAY "|" 
				@xLin,077 PSAY SUBSTR(xSZI->ZI_DESCRIC,1,25)   Picture "@!" //descrição
				@xLin,114 PSAY "|"      
				@xLin,116 PSAY SUBSTR(xSZI->ZI_OBS,1,40)   Picture "@!"
				@xLin,152 PSAY "|"		//ok
				@xLin,157 PSAY xSZI->ZI_VALOR Picture "@E 9,999,999.99"
				@xLin,170 PSAY "|"    //ok
				@xLin,185 PSAY "|"
				_nTotAcres += xSZI->ZI_VALOR
				xLin := xLin + 1                     
			ELSE
				If TRIM(xSZI->ZI_TIPO) = 'D'
					lEntrSZI := .T.
			
					If xLinOri <> xLin 
						@xLin,000 PSAY "|"
						@xLin,013 PSAY "|" 
						@xLin,025 PSAY "|"
						@xLin,032 PSAY "|"
						@xLin,045 PSAY "|"//estava '+'
						@xLin,059 PSAY "|"	 	
					Endif		
				
					@xLin,075 PSAY "|"
					@xLin,077 PSAY SUBSTR(xSZI->ZI_DESCRIC,1,25)   Picture "@!"
					@xLin,114 PSAY "|"     //**************
					@xLin,116 PSAY SUBSTR(xSZI->ZI_OBS,1,40)   Picture "@!"
					@xLin,152 PSAY "|"
					@xLin,170 PSAY "|"			
					@xLin,171 PSAY xSZI->ZI_VALOR Picture "@E 9,999,999.99"
					@xLin,185 PSAY "|"
					_nTotDesc += xSZI->ZI_VALOR
	        	
					xLin := xLin + 1
	
				ENDIF
			ENDIF
	    //ENDIF
		
	//	cGuiaAnt := xSZI->ZI_GUIA    // CHAMADO 021295
		dbSelectArea("xSZI")
		Dbskip() 
			
	Enddo
	
	If xLinOri == xLin
		@xLin,075 PSAY "|"
		@xLin,114 PSAY "|"
		@xLin,151 PSAY "|"
		@xLin,169 PSAY "|"
		@xLin,184 PSAY "|"
	Endif
			          
	/*
	If _nTotAcres  <> 0 .or.  _nTotDesc  <> 0
		
		@xLin,000 PSAY "|"+ Replicate ("=",78)+ "|"
		xLin := xLin + 1
		@xLin,000 PSAY "|"
		@xLin,002 PSAY "TOTAL"
		@xLin,012 PSAY "|"
		@xLin,019 PSAY "|"
		@xLin,048 PSAY "|"
		@xLin,050 PSAY _nTotAcres   Picture "@E 9,999,999.99"
		@xLin,064 PSAY "|"
		@xLin,065 PSAY _nTotDesc    Picture "@E 9,999,999.99"
		@xLin,079 PSAY "|"
		xLin := xLin + 1
		@xLin,000 PSAY "|"+ Replicate ("=",78)+ "|"
		xLin := xLin + 1
		@xLin,000 PSAY SPACE(2)+ "TOTAL A PAGAR "
		@xLin,021 PSAY _TTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99"
		xLin := xLin + 1
		@xLin,000 PSAY Replicate ("_",79)
		
	EndIf
	If _nTotAcres +_nTotDesc =0
		xLin := xLin + 1
		@xLin,000 PSAY "|"+ Replicate ("=",78)+ "|"
		xLin := xLin + 1
		@xLin,000 PSAY SPACE(2)+ "TOTAL A PAGAR "
		@xLin,021 PSAY _TTotFret Picture "@E 999,999.99"
		xLin := xLin + 1
		@xLin,000 PSAY "|"+ Replicate ("_",78)+ "|"
	endIf
	*/
	//xLin := 65 
	
	If lEntrSZI
		xLin := xLin - 1
	Endif

Return(xLin)