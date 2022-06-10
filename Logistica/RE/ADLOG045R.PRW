#Include "Rwmake.ch"
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADLOG045R
	Relatório de movimentação de lançamentos de frete. Chamado 044314.
	@type  Function
	@author Everson
	@since 23/04/2019
	@version 01
	@history 24/05/2019, Everson, Ch 044314. Alterado script sql. 
	@history 25/07/2019, Everson, Ch 044314. Removidas ocorrencias de fechamento de período de frete do relatório.
	@history 01/08/2019, Everson, Ch 044314. Tratamento para que as ocorrências de fechamento não saiam no relatório de fechamento.
	@history 14/08/2019, Everson, Ch 044314. Tratamento no script sql para que o relatório de fechamento considere apenas os registros fechados.
	@history 28/10/2019, Everson, Ch 044314. Tratamento para desconsiderar lançamentos rejeitados.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	/*/                                                                                       
User Function ADLOG045R()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
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
	aOrd 		 := {}
	cPerg   	 := "ADLOG045R"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatório de movimentação de lançamentos de frete')

	//
	Pergunte(cPerg,.F.)
	
	//
	Private lEnd      	:= .F.
	Private lAbortPrint:= .F.
	Private CbTxt     	:= ""
	Private limite    	:= 132
	Private tamanho  	:= "G"
	Private nomeprog	:= "ADLOG045R" //Coloque aqui o nome do programa para impressão no cabecalho.
	Private nTipo     	:= 18
	Private aReturn  	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey  	:= 0
	Private cbtxt    	:= Space(10)
	Private cbcont    	:= 00
	Private CONTFL    	:= 01
	Private m_pag     	:= 01      
	Private wnrel     	:= "ADLOG045R" //Coloque aqui o nome do arquivo usado para impressão em disco.
	Private cGuiaAnt	:= ""
	Private cString		:= "ZFA"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	//
	If nLastKey == 27
		Return Nil
		
	Endif
	
	SetDefault(aReturn,cString)
	
	//
	If nLastKey == 27
		Return Nil
		
	Endif
	
	//
	nTipo := If(aReturn[4]==1,15,18)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Return Nil
/*/{Protheus.doc} RunReport
	Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
	monta a janela com a regua de processamento.
	@type  Static Function
	@author Everson
	@since 23/04/2019
	@version 01
	/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local nOrdem	:= 0
	Local cOcorr	:= GetMv("MV_#ADL461",,"011")
	
	//
	DbSelectArea(cString)
	(cString)->(DbSetOrder(1))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetRegua(RecCount())
	
	//Parâmetros.
	_dDtEntr  := mv_par01
	_dDtEntr2 := mv_par02
	_cTransp  := mv_par03
	_cTransp2 := mv_par04
	_cTipFrt  := mv_par05
	
	//Variáveis de Trabalho.
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
	
	//
	Cabec1  := SPACE(02)+ "Periodo de : " + substr(DTOS(_dDtEntr),7,2)+ "/" + substr(DTOS(_dDtEntr),5,2)+ "/" + substr(DTOS(_dDtEntr),1,4)+ SPACE(5) +  "Ate : " + substr(DTOS(_dDtEntr2),7,2)+ "/" + substr(DTOS(_dDtEntr2),5,2)+ "/" + substr(DTOS(_dDtEntr2),1,4)
	Cabec3  := "|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	Cabec4  := "|            |           |      |            |             |               |                                                 ** DESCONTO E ACRESCIMO **                                           |"
	Cabec5  := "|    DATA    | INTEGRADO | ENT. |     KM     |     PESO    |  TOTAL FRETE  |         DESCRICAO                    |                  OBSERVAÇÃO                  |    ACRESCIMO    |   DESCONTO   |"
	Cabec6  := "|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|"
	
	Cabec9   := "Relacao dos Fretes"
	Cabec10  := "Relacao dos Descontos e Acrescimos"
	
	//          0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20
	//          012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	//+---------------------------------+
	//|MONTA QUERY NO SZK               |
	//+---------------------------------+
	QryZFA(.F.) //Everson - 14/08/2019. Chamado 044314.
	_cFornec:= xZFA->ZFA_TRANPA
	_cPlac	:= xZFA->ZFA_VEICPG
	lVez:='S'
	
	//+-------------------------------------+
	//|Enquanto nao for fim de arquivo      |
	//+-------------------------------------+
	Do While ! xZFA->(Eof())
	
		//+--------------------------------+
		//|Enquanto for o mesmo fornecedor |
		//+--------------------------------+    
		_cPlacAnt := ""
		_cPlac2Ant := ""
		While ! xZFA->(Eof()) .And. _cFornec = xZFA->ZFA_TRANPA
							
			//+--------------------------------+
			//|Enquanto for no mesma placa     |
			//+--------------------------------+
			While ! xZFA->(Eof()) .And. _cPlac == xZFA->ZFA_VEICPG
										
				If nLin > 60 .or. (_cPlacAnt <> _cPlac) 
				
					If (_nTotFret <> 0  .OR. _nTotPeso <> 0) 
					
						@nLin,000 PSAY "|"+ Replicate ("=",193)+ "|"
						nLin := nLin + 1
						@nLin,000 PSAY "|"
						@nLin,002 PSAY " TOTAL "
						@nLin,013 PSAY "|" 
						@nLin,025 PSAY "|"                        
						@nLin,027 PSAY _nTotEntr  	Picture "@E 9999"
						@nLin,032 PSAY "|"				
						@nLin,034 PSAY _ntTKmpag	Picture "@E 999,999.99"
						@nLin,045 PSAY "|"			
						@nLin,048 PSAY _nTotPeso  	Picture "@E 999,999.99"
						@nLin,059 PSAY "|"			
						@nLin,064 PSAY _nTotFret 	Picture "@E 999,999.99"			
						@nLin,075 PSAY "|"
						
						@nLin,114 PSAY "|"					
						@nLin,116 PSAY "TOTAL "
						@nLin,161 PSAY "|"
						@nLin,166 PSAY _nTotAcres 	Picture "@E 9,999,999.99"
						@nLin,179 PSAY "|"
						@nLin,181 PSAY _nTotDesc 	Picture "@E 9,999,999.99"
						@nLin,194 PSAY "|"									
				
						nLin := nLin + 1
						@nLin,000 PSAY "|"+ Replicate ("=",193)+ "|"
						nLin := nLin + 1
						@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS: "
						@nLin,021 PSAY _nViag                       					
						       
						nLin := nLin + 1
						@nLin,000 PSAY Replicate ("_",195)
						nLin := nLin + 1
						
						@nLin,002 PSAY "TOTAL A PAGAR: "
						@nLin,019 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99"	   //AB
						
						nLin := nLin + 1
						@nLin,000 PSAY Replicate ("_",195)
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
								
					EndIf	
					
					//
					DbselectArea("ZV4")
					ZV4->(DbSetOrder(1))
					ZV4->(Dbseek(xFilial("ZV4") + _cPlac ,.T.))
													
					Cabec2 := SPACE(02)+ "Trans.: " + ZV4_FORNEC+" "+ZV4_LOJFOR+" "+ZV4_NOMFOR+SPACE(03) +"Veiculo : " +ZV4_PLACA            
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9  				
					DbselectArea("xZFA")			
					
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
									
				EndIf
				           
				@nLin,000 PSAY "|"
				@nLin,002 PSAY SToD(xZFA->ZFA_DATA)
				@nLin,013 PSAY "|" 
				@nLin,025 PSAY "|"
				
				//
				If Alltrim(cValToChar(xZFA->ZF7_TOTCOD)) == "S" //Everson - 24/05/2019. Chamado 044314.
				
					@nLin,027 PSAY xZFA->ZFA_NUMENT		Picture "@E 9999"
					@nLin,032 PSAY "|" 			
					@nLin,034 PSAY xZFA->ZFA_KMTOT    	Picture "@E 999,999.99"  
					@nLin,045 PSAY "|" 								
					@nLin,048 PSAY xZFA->ZFA_KGBT     	Picture "@E 999,999.99"			
					@nLin,059 PSAY "|"			
					@nLin,064 PSAY xZFA->ZFA_VALOR   	Picture "@E 999,999.99"  
					@nLin,075 PSAY "|"
					@nLin,076 PSAY Alltrim(cValToChar(xZFA->ZFA_OCORRE)) +"-"+ Alltrim(cValToChar(xZFA->ZFA_DESCOC))
					@nLin,114 PSAY "|"
					//@nLin,161 PSAY "|"
					//@nLin,179 PSAY "|"
					
					_nTotFret   += xZFA->ZFA_VALOR
					_nTotPeso   += xZFA->ZFA_KGBT
					_ntTKmpag   += xZFA->ZFA_KMTOT
					_nTotEntr   += xZFA->ZFA_NUMENT
					_nViag      += 1
				
				Else
					
					@nLin,032 PSAY "|"
					@nLin,045 PSAY "|" 
					@nLin,059 PSAY "|"	
					@nLin,075 PSAY "|"
					@nLin,076 PSAY Alltrim(cValToChar(xZFA->ZFA_OCORRE)) +"-"+ Alltrim(cValToChar(xZFA->ZFA_DESCOC))
					@nLin,114 PSAY "|"
					@nLin,115 PSAY Alltrim(cValToChar(xZFA->OBS))
					//@nLin,161 PSAY "|"
				
					If ZFA_DC == "C"
						_nTotAcres += xZFA->ZFA_VALOR 
						@nLin,168 PSAY xZFA->ZFA_VALOR Picture "@E 999,999.99"  
						//@nLin,179 PSAY "|"
						
					Else
						_nTotDesc  += xZFA->ZFA_VALOR
						//@nLin,179 PSAY "|"
						@nLin,183 PSAY xZFA->ZFA_VALOR Picture "@E 999,999.99"  
						
					EndIf
					
				EndIf
				
				@nLin,194 PSAY "|"
				
				_nEntr      := 0
				
				//
				nLin := nLin + 1			
				_cPlacAnt := _cPlac			
				
				xZFA->(DbSkip())
				
			End
			
			//
			lVez := 'N'				
			_cPlac := xZFA->ZFA_VEICPG
			DbSelectArea("xZFA")
			
		End	                   	
		
		//
		_cFornec := xZFA->ZFA_TRANPA
		xZFA->(DbSkip())
		
	Enddo
	
	//
	If (_nTotFret <> 0  .OR. _nTotPeso <> 0)            //ultima folha
	
		@nLin,000 PSAY "|"+ Replicate ("=",193)+ "|"
		nLin := nLin + 1
		@nLin,000 PSAY "|"
		@nLin,002 PSAY " TOTAL "
		@nLin,013 PSAY "|" 
		@nlin,025 PSAY "|"                       
		@nLin,027 PSAY _nTotEntr	Picture "@E 9999"
		@nLin,032 PSAY "|"				
		@nLin,034 PSAY _ntTKmpag   	Picture "@E 999,999.99"
		@nLin,045 PSAY "|"			
		@nLin,048 PSAY _nTotPeso  	Picture "@E 999,999.99"
		@nLin,059 PSAY "|"			
		@nLin,064 PSAY _nTotFret 	Picture "@E 999,999.99"			
		@nLin,075 PSAY "|"
		
		@nLin,114 PSAY "|"
		@nLin,116 PSAY "TOTAL "
		@nLin,161 PSAY "|"
		@nLin,166 PSAY _nTotAcres 	Picture "@E 9,999,999.99"
		@nLin,179 PSAY "|"
		@nLin,181 PSAY _nTotDesc 	Picture "@E 9,999,999.99"
		@nLin,194 PSAY "|"
				
		nLin := nLin + 1
		@nLin,000 PSAY "|"+ Replicate ("=",193)+ "|"
		nLin := nLin + 1
		@nLin,000 PSAY SPACE(2)+ "TOTAL DE VIAGENS: "
		@nLin,021 PSAY _nViag
						
		nLin := nLin + 1
		@nLin,000 PSAY Replicate ("_",195)
		nLin := nLin + 1
						
		@nLin,002 PSAY "TOTAL A PAGAR: "
		@nLin,019 PSAY _nTotFret+(_nTotAcres -_nTotDesc) Picture "@E 999,999.99" //alterado de 22 a 12
						
		nLin := nLin + 1
		@nLin,000 PSAY Replicate ("_",195)
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
			
	EndIf	
	
	xZFA->(DbCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If aReturn[5] == 1
		DbCommitAll()
		SET PRINTER To
		OurSpool(wnrel)
		
	Endif
	
	//
	MS_FLUSH()
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} QryZFA
	Script sql para gerar o relatório. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 23/04/2019
	@version 01
	/*/
Static Function QryZFA(lFech) //Everson - 14/08/2019. Chamado 044314.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//Everson - 25/07/2019. Chamado 044314.
	Local aOcFech	:= StrToKarr(Alltrim(GetMv("MV_#OCFHFT",,"106/107")),"/")
	Local cOcFAcr	:= Alltrim(aOcFech[1])
	Local cOcFDes	:= Alltrim(aOcFech[2])
	//
	
	//
	cQuery += " SELECT " 
	cQuery += " RTRIM(LTRIM(ZFA_OBSERV)) + ' ' +  RTRIM(LTRIM(ZFA_OBS)) AS OBS, "
	cQuery += " ZFA_TABFRT, " 
	cQuery += " ZFA_VEICPG, " 
	cQuery += " ZFA_DATA, " 
	cQuery += " ZFA_TRANPA, " 
	cQuery += " ZFA_LJPPAG, " 
	cQuery += " ZFA_VALOR, " 
	cQuery += " ZFA_KGBT, " 
	cQuery += " ZFA_NUMENT, " 
	cQuery += " ZFA_KMTOT, " 
	cQuery += " ZFA_NMTPAG, " 
	cQuery += " ZFA_OCORRE, " 
	cQuery += " ZFA_DESCOC, " 
	cQuery += " ZFA_ROTEIR, " 
	cQuery += " ZFA_DC, "
	cQuery += " ZF7_TOTCOD "
	cQuery += " FROM " 
	cQuery += " " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA INNER JOIN " + RetSqlName("ZF7") + " (NOLOCK) AS ZF7 ON ZFA_OCORRE = ZF7_CODIGO " //Everson - 24/05/2019. Chamado 044314.
	cQuery += " WHERE " 
	cQuery += " (ZFA_DATA BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "') " 
	cQuery += " AND ZFA_TRANPA BETWEEN '" + cValToChar(MV_PAR03) + "' AND '" + cValToChar(MV_PAR04) + "' " 
	cQuery += " AND ZFA.D_E_L_E_T_ = '' " 
	cQuery += " AND ZF7.D_E_L_E_T_ = '' " 
	cQuery += " AND ZFA_APRMOV <> 'R' " //Everson - 28/10/2019. Chamado 029058. 
	
	//Everson - 14/08/2019. Chamado 044314.
	If lFech
		cQuery += " AND ZFA_FECHA = 'S' "
		
	EndIf 
	
	//Everson-01/08/2019.Ch 044314.
	cQuery += " AND ZFA_OCORRE <> '" + cOcFAcr + "' AND ZFA_OCORRE <> '" + cOcFDes + "' " //Everson - 25/07/2019. Chamado 044314.
	cQuery += " ORDER BY " 
	cQuery += " ZFA_TRANPA, ZFA_VEICPG, ZFA_DATA, ZFA.R_E_C_N_O_ " 
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG045P - QryZFA " + cQuery )
	
	//
	TCQUERY cQuery NEW ALIAS "xZFA"
	DbselectArea("xZFA")
	xZFA->(DbgoTop())

Return Nil

/*/{Protheus.doc} u_LOG045A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_LOG045A0( uPar1 )
Return( QryZFA( uPar1 ) )
