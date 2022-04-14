#INCLUDE 'Protheus.ch'
#INCLUDE 'TOPConn.ch'
#INCLUDE 'Rwmake.ch'
#include "TbiConn.ch"
#include "TbiCode.ch"
#INCLUDE "FWMVCDEF.CH"         
#INCLUDE "FWCOMMAND.CH"         
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} User Function MT100GE2
	Ponto entrada utilizado apos gravacao do documento de entrada
	@type  Function
	@author Cellvla
	@since 19/08/13
	@version version
	@Ticket T.I.   - Ricardo Lima - 08/04/09 - Tratar campos C.Contabil e Item Contabil dos titulos HC CONSYS de impostos.
	@Ticket 038613 - Ricardo Lima - 07/12/17 - Aplica Bloqueio de titulo com base nos criterio de pontuacao definidos pela politica de seguranca financeira
	@Ticket 038612 - Ricardo Lima - 05/01/18 - Se existir XML para a nota lancada, considera a data de vencimento do xml caso seja maior que a data informada.
	@Ticket 046347 - Adriana Oliv - 09/01/19 - Incluida funcao RetSqlName para atender demais empresas nas instrucoes que geram o titulo de senar+funrural.
	@Ticket 042937 - Ricardo Lima - 03/08/18 - Aplica Bloqueio de titulo a Pagar, quando o pedido de compras usar a condição de pagameto "ICM".
	@Ticket 048333 - Adriana Oliv - 25/04/19 - Inclusao de titulo referente ao SENAR quando nao tem INSS ou FUNRURAL.
	@Ticket T.I.   - Fernando     - 27/06/19 - Error log, variavel nao declarada - _lib.
	@Ticket 050131 - Adriana      - 28/06/19 - Error.log chave duplicada e correcao fornecedor tit. parcela > 1
	@Ticket 051260 - William      - 23/08/19 - Alterado o ponto de entrada para adicionar campos de banco,agencia,conta e CNPJ cadastros na tabela FIL caso contrario carrega os campos do fornecedor para todos os titulos criados           º±±
	@Ticket 051260 - William      - 26/08/19 - Identificado que existia titulos que estavam entrando sem data de liberacao quando o correto e entrar liberado no financeiro.
	@Ticket 051044 - Adriana      - 27/08/19 - SAFEGG.
	@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks no banco que impacta na perda dos registros SF1 e SD1.
	@Ticket 13688  - Leonardo Mont- 11/05/21 - Correção de error.log na integração de títulos e notas do SAG.
	@Ticket 14662  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
/*/

User Function MT100GE2()

	Local CVAR  	:= GETAREA()     
	Local CBLOQ 	:= ""
	Local _Produto 	:=  GetMV("MV_PRBLQ")              
	Local _Conta   	:=  GetMV("MV_CONTBLQ")
	Local _ItemConta:=  GetMV("MV_ITMCTBL")
	Local _CCusto   :=  GetMV("MV_CCBLQ")
	Local cQuery 	:= ""
	
	// Ricardo Lima - 07/12/17
	Local aCols      := PARAMIXB[1]
	Local nOpc       := PARAMIXB[2]
	Local aHeadSE2   := PARAMIXB[3]
	Local nPos       := Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_PARCELA'})
	Local nPosVencto := Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_VENCTO'})
	Local nTpTit     := SE2->E2_TIPO
	
	// RICARDO LIMA - 05/01/18
	Local sCnpjF    := ""
	Local sChvNfe   := ""    
	Local cRootPath := "\central xml\xml\nf-e\"
	Local oFullXML  := NIL
	Local oAuxXML   := NIL
	Local oXML      := NIL
	Local lFound    := .F.
	Local cXML      := ""
	Local cError    := ""
	Local cWarning  := ""
	Local dDtVencXML := {}
	Local sDtVenc    := ""
	Local lChkXml    := SuperGetMv( "MV_#MT1GE2" , .F. , .F. ,  )
	Local lDupXml    := SuperGetMv( "MV_#MT2GE2" , .F. , .F. ,  )
	Local lGrBlqIcm  := .F.
	Local aAreaSF1   := SF1->(GetArea())
	Local dData      := CTOD("  /  /    ")
	Local _lib 		 := cTod('') //Chamado: T.I Fernando Sigoli 27/06/2019
	
	//incluido por Adriana Chamado 048333 em 25/04/2019
	Local _aVet 	 := {}
	Local _dVencto 	 := ddatabase
	Local _cNaturINS := SuperGetMv( "MV_CSS" , .F. , "22609" ,  )
	Local _cFornINS  := SuperGetMv( "MV_FORINSS" , .F. , "INPS" ,  ) 
	Local _aAreaSA2  := SA2->(GetArea())
	
	//Chamado 035718 19/06/2017 - Fernando Sigoli
	DbSelectArea("SA2")
	If SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
		CBLOQ := SA2->A2_XBLQNFE
	EndIf
	           
	DbSelectArea("SD1")
	DbSetOrder(1)
	If dbSeek(SE2->E2_FILIAL+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
	     If (ALLTRIM(SD1->D1_COD) $ _Produto .AND. ALLTRIM(SD1->D1_CONTA) $ _Conta .AND. ALLTRIM(SD1->D1_ITEMCTA) $ _ItemConta .AND. ALLTRIM(SD1->D1_CC) $ _CCusto)
	     	_lib := cTod('')
	     
	     ElseIf CBLOQ == "1"  //1=Sim;2=Nao  //Na entrada da NF, O Titulo apagar -Chamado 035718 19/06/2017 - Fernando Sigoli
	     		_lib := cTod('')  
	     	    		
	     Else
	        _lib := DDatabase
	     End If
	EndIf
	
	// *** INICIO WILLIAM COSTA 21/08/2019 CHAMADO 051260 || OS 052577 || FINANCAS || FLAVIA || 8461 || TITULOS SAG
	
	SqlOutBanc(SA2->A2_FILIAL,SA2->A2_COD,SA2->A2_LOJA)
	
	IF TRB->(!EOF())
			
		DbSelectArea("SE2")
		RecLock("SE2",.F.)
			SE2->E2_DATALIB := DDatabase // WILLIAM COSTA 26/08/2019 - CHAMADO 051325 || OS 052642 || FINANCAS || FLAVIA || 8461 || TITULOS BLOQUEADOS		
			SE2->E2_BANCO   := TRB->FIL_BANCO
			SE2->E2_AGEN    := TRB->FIL_AGENCI
			SE2->E2_DIGAG   := TRB->FIL_DVAGE
			SE2->E2_NOCTA   := TRB->FIL_CONTA
			SE2->E2_DIGCTA  := TRB->FIL_DVCTA
			SE2->E2_CNPJ    := TRB->FIL_XCGC
	    MsUnlock()   	
	    
    ELSE
    
    	DbSelectArea("SE2")
		RecLock("SE2",.F.)
			SE2->E2_DATALIB := DDatabase // WILLIAM COSTA 26/08/2019 - CHAMADO 051325 || OS 052642 || FINANCAS || FLAVIA || 8461 || TITULOS BLOQUEADOS
	    	SE2->E2_BANCO   := SA2->A2_BANCO
			SE2->E2_AGEN    := SA2->A2_AGENCIA
			SE2->E2_DIGAG   := SA2->A2_DIGAG
			SE2->E2_NOCTA   := SA2->A2_NUMCON
			SE2->E2_DIGCTA  := SA2->A2_DIGCTA
			SE2->E2_CNPJ    := IIF(EMPTY(SA2->A2_CPF),SA2->A2_CGC,SA2->A2_CPF)
        MsUnlock()   
	ENDIF
	TRB->(dbCloseArea()) 
	
	// *** FINAL WILLIAM COSTA 21/08/2019 CHAMADO 051260 || OS 052577 || FINANCAS || FLAVIA || 8461 || TITULOS SAG
	
	IF SELECT("TMP0") > 0
		TMP0->( DBCLOSEAREA() )
	ENDIF
	
	cQuery := "SELECT E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_LOJA, E2_EMISSAO"
	// @Ticket 13688  - Leonardo Mont- 11/05/21 - Correção de error.log na integração de títulos e notas do SAG.
	// cQuery += " FROM "+retsqlname("SE2")+" "
	cQuery += " FROM "+retsqlname("SE2")+" (NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_ = '' AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND E2_NUM = '"+SE2->E2_NUM+"' AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"' " 
	cQuery += " AND E2_FORNECE = '"+SE2->E2_FORNECE+"' "

	If SD1->D1_BASEFUN = 0 .AND. SD1->D1_ALIQFUN = 0 .AND. SD1->D1_VALFUN = 0               //  23-08-2012 - Ref. Chamado 014252, gerando imposto São Carlos Bloqueado
		cQuery+= " AND E2_TITPAI LIKE '%"+SE2->E2_PREFIXO+"%%"+SE2->E2_NUM+"%' "
	Endif	
	
	TCQUERY cQuery new alias "TMP0"
	TMP0->(dbgotop())
	While TMP0->(!EOF())
		//@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
		//cQuery1	:= "UPDATE "+retsqlname("SE2")+" "
		//cQuery1	+= "   SET E2_DATALIB = '"+DtoS(_Lib)+"'"
		
		cQuery1	:= " SELECT R_E_C_N_O_ SE2REG "
		cQuery1	+= " FROM "+ RetSqlName("SE2") +" (NOLOCK) "
		cQuery1	+= " WHERE E2_FILIAL = '"+SE2->E2_FILIAL+"' AND E2_NUM = '"+SE2->E2_NUM+"' AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"'  AND E2_PARCELA = '"+TMP0->E2_PARCELA+"' "
		cQuery1	+= "   AND E2_TIPO = '"+TMP0->E2_TIPO+"' AND E2_NATUREZ = '"+TMP0->E2_NATUREZ+"' AND E2_FORNECE ='"+TMP0->E2_FORNECE+"' " 
		cQuery1	+= "   AND E2_LOJA = '"+TMP0->E2_LOJA+"' AND E2_EMISSAO = '"+TMP0->E2_EMISSAO+"' AND D_E_L_E_T_ = '' "
		
		TcQuery cQuery1 ALIAS "QE2X" NEW

		DbSelectArea("SE2")

		While QE2X->(!EOF())
			SE2->(dbgoto(QE2X->SE2REG))

			if SE2->(recno()) == QE2X->SE2REG
				if reclock("SE2",.F.)
					SE2->E2_DATALIB = _Lib

					SE2->(MsUnlock())	
				endif
			Endif
			QE2X->(Dbskip())
		enddo

		QE2X->(dbCloseArea())
		//TCSQLExec(cQuery1)
	
	TMP0->(	Dbskip())
	Enddo
	
	//Tratamento para os impostos
	//TMP0->(dbgotop())
	//While !EOF()
		
		//@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
		//cQuery1:= "UPDATE "+retsqlname("SE2")+" "
		//cQuery1 += "   SET E2_DATALIB = '"+DtoS(DDatabase)+"' "
		cQuery1	:= " SELECT R_E_C_N_O_ SE2REG "
		cQuery1	+= " FROM "+ RetSqlName("SE2") +" (NOLOCK) "
		cQuery1 += " WHERE D_E_L_E_T_ = '' AND E2_FILIAL = '"+SE2->E2_FILIAL+"' AND E2_NUM = '"+SE2->E2_NUM+"' AND E2_PREFIXO = '"+SE2->E2_PREFIXO+"' "
		cQuery1 += "   AND E2_TIPO IN ('TX','INS','ISS') " 
		cQuery1 += "   AND E2_EMISSAO = '"+DTOS(SE2->E2_EMISSAO)+"' "
		//TCSQLExec(cQuery1)

		TcQuery cQuery1 ALIAS "QE2X" NEW

		DbSelectArea("SE2")

		While QE2X->(!EOF())
			SE2->(dbgoto(QE2X->SE2REG))

			if SE2->(recno()) == QE2X->SE2REG
				if reclock("SE2",.F.)
					SE2->E2_DATALIB = DDatabase

					SE2->(MsUnlock())	
				endif
			Endif
		
			QE2X->(Dbskip())
		enddo
		
		QE2X->(dbCloseArea())

	//TMP0->(	Dbskip())
	//Enddo
	
	// RICARDO LIMA - 05/01/18
	IF (cEmpAnt = '01' .or. cEmpAnt = '02' .or. cEmpAnt = '09') .and. lChkXml //Incluido por Adriana chamado 051044 em 27/08/2019 - SAFEGG
	
		DbSelectArea("SA2")
		DbSetOrder(1)
		if DbSeek( FWxFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA )
			sCnpjF := SA2->A2_CGC
		endif
		
		IF SELECT("ADCOM011P") > 0
			ADCOM011P->( DBCLOSEAREA() )
		ENDIF
		
		cQuery := " SELECT * "
		//@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
		cQuery += " FROM RECNFXML "
		//cQuery += " FROM RECNFXML (NOLOCK) "
		cQuery += " WHERE SUBSTRING(XML_NUMNF,4,9) = '"+ SF1->F1_DOC +"' AND XML_EMIT = '"+ sCnpjF +"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		TCQUERY cQuery new alias "ADCOM011P"
		
		IF ADCOM011P->( !EOF() )	
			
			sChvNfe := ALLTRIM(ADCOM011P->XML_CHAVE)		
			cXML    := MemoRead( cRootPath + sChvNfe +'.XML' )
			if !empty(cXML)
				oFullXML := XmlParserFile( cRootPath + sChvNfe +'.XML' , "_" , @cError , @cWarning )
				oXML    := oFullXML
				oAuxXML := oXML		
			
				While !lFound
					oAuxXML := XmlChildEx(oAuxXML,"_NFE")
					If !(lFound := oAuxXML # NIL)
						For nX := 1 To XmlChildCount(oXML)
							oAuxXML  := XmlChildEx(XmlGetchild(oXML,nX),"_NFE")
							lFound := oAuxXML:_InfNfe # Nil
							If lFound
								oXML := oAuxXML
								Exit
							EndIf
						Next nX
					EndIf
				
					If lFound
						oXML := oAuxXML
						Exit
					EndIf
				EndDo
			
				IF "</COBR>" $ Upper(cXML)
					If ValType(oXML:_INFNFE:_COBR:_DUP) == "A"
				
						dDtVencXML := {oXML:_INFNFE:_COBR:_DUP}
					
						For nX := 1 To Len(dDtVencXML[1])
							sDtVenc := dDtVencXML[1][nX]:_DVENC:TEXT
							sDtVenc := StrTran( sDtVenc, "-", "" )
							IF Chr( nX + 64 ) = aCols[nPos]
								IF STOD(sDtVenc) > SE2->E2_VENCTO
								
									RecLock("SE2",.F.)
										SE2->E2_VENCTO  := STOD(sDtVenc)
										SE2->E2_VENCREA := DataValida( STOD(sDtVenc) , .T. )
									MsUnlock()
									  
								ENDIF
							ENDIF									
						Next nX				
					Else
						dDtVencXML := oXML:_INFNFE:_COBR:_DUP:_DVENC:TEXT
						dDtVencXML := StrTran( dDtVencXML , "-", "" )
						if empty( aCols[nPos] )				
					  		IF STOD(dDtVencXML) > SE2->E2_VENCTO 
					  		
					  			RecLock("SE2",.F.)
									SE2->E2_VENCTO  := STOD(dDtVencXML)
									SE2->E2_VENCREA := DataValida( STOD(dDtVencXML) , .T. )
								MsUnlock()
								  
					  		ENDIF
						endif 
					EndIf												 
				EndIf
			ENDIF									
		ENDIF
	ENDIF	
	
	// ADRIANA OLIVEIRA - 13/07/18 - PARA SOMAR FUNRURAL + SENAR NO MESMO TITULO 
	// (pelo padrao do sistema os titulos SENAR sao gerados na apuracao do ICMS, mas optamos (TI+FISCAL) por gerar com o FUNRURAL na geracao do contas a pagar)
	// Incluida instrucao RetSqlName para atender demais empresas por Adriana em 09/01/2019 Chamado 046347
	IF SF1->F1_CONTSOC > 0 .AND. SF1->F1_VLSENAR > 0 

		//@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.            
		/*
		cQuery := "UPDATE "+RetSqlName("SE2")+" SET "
        cQuery += "E2_VALOR =  F1_CONTSOC+F1_VLSENAR , "
        cQuery += "E2_SALDO =  F1_CONTSOC+F1_VLSENAR, "
        cQuery += "E2_VLCRUZ = F1_CONTSOC+F1_VLSENAR "
        */
		cQuery := "SELECT E2.R_E_C_N_O_ SE2REG, F1_CONTSOC+F1_VLSENAR F1VALOR   "
		cQuery += "FROM "+RetSqlName("SE2")+" (NOLOCK) E2 INNER JOIN "+RetSqlName("SF1")+" (NOLOCK) F1 "
        cQuery += "		ON E2.D_E_L_E_T_='' AND F1.D_E_L_E_T_='' "
        cQuery += "			AND E2_FILIAL = F1_FILIAL AND E2_NUM = F1_DOC AND E2_PREFIXO = F1_SERIE "
		cQuery += "			AND F1_FORNECE = '"+SF1->F1_FORNECE+"' AND F1_LOJA = '"+SF1->F1_LOJA+"' "
        cQuery += "			AND F1_CONTSOC > 0 AND F1_VLSENAR > 0 "
        cQuery += "WHERE "                                                                                                                          
        cQuery += "E2_FILIAL = '"+SF1->F1_FILIAL+"' AND E2_NUM = '"+SF1->F1_DOC+"' AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "
        cQuery += "AND E2_TIPO = 'TX' AND E2_FORNECE = 'INPS' AND E2.D_E_L_E_T_ = '' "             
        //TCSQLExec(cQuery)    
	    
		TcQuery cQuery ALIAS "QE2X" NEW

		DbSelectArea("SE2")

		While QE2X->(!EOF())
			SE2->(dbgoto(QE2X->SE2REG))

			if SE2->(recno()) == QE2X->SE2REG
				if reclock("SE2",.F.)
					SE2->E2_VALOR 	:= QE2X->F1VALOR
					SE2->E2_SALDO	:= QE2X->F1VALOR
					SE2->E2_VLCRUZ	:= QE2X->F1VALOR
					SE2->(MsUnlock())	
				endif
			Endif
			QE2X->(Dbskip())
		enddo
		
		QE2X->(dbCloseArea())

    //incluido por Adriana Chamado 048333 em 25/04/2019
    // Gera Título a Pagar para o SENAR - caso nao exista titulo de FUNRURAL
	ElseIF SF1->F1_CONTSOC = 0 .AND. SF1->F1_VLSENAR > 0 //incluido por Adriana Chamado 048333 em 25/04/2019
		
		//incluido por Adriana em 28/06/2019 chamado 050131
		IF SELECT("TEMSE2") > 0
			TEMSE2->( DBCLOSEAREA() )
		ENDIF

		cQuery := "SELECT R_E_C_N_O_ "
		//@Ticket 13688  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
        //cQuery += "FROM "+RetSqlName("SE2")+" "
		cQuery += "FROM "+RetSqlName("SE2")+" (NOLOCK) "
        cQuery += "WHERE "                                                                                                                          
        cQuery += "E2_FILIAL = '"+xfilial("SE2")+"' AND E2_NUM = '"+SF1->F1_DOC+"' AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "
        cQuery += "AND E2_PARCELA = '001' AND E2_TIPO = 'TX' AND E2_FORNECE = '"+_cFornINS+"' AND "+RetSqlName("SE2")+".D_E_L_E_T_ = '' "             
 		TCQUERY cQuery new alias "TEMSE2"
		
		IF TEMSE2->( EOF() )	
		//fim Adriana em 28/06/2019 chamado 050131
            
			_aVet 		:= {}
			//Calcula vencimento = dia 20 do mes subsequente
			_dVencto 	:= ctod("20/"+IIF(MONTH(SF1->F1_EMISSAO)<>12,STRZERO(MONTH(SF1->F1_EMISSAO)+1,2)+"/"+STR(YEAR(SF1->F1_EMISSAO),4),"01/"+STR(YEAR(SF1->F1_EMISSAO)+1,4)))
			
			AADD(_aVet,{"E2_FILIAL " ,xfilial("SE2")	, Nil} ) 
			AADD(_aVet,{"E2_NUM    " ,SF1->F1_DOC 		, Nil} )
			AADD(_aVet,{"E2_PREFIXO" ,SF1->F1_SERIE		, Nil} )
			AADD(_aVet,{"E2_PARCELA" ,"001"        		, Nil} )
			AADD(_aVet,{"E2_TIPO"    ,"TX "        		, Nil} ) 
			AADD(_aVet,{"E2_NATUREZ" ,_cNaturINS   		, Nil} )            
			AADD(_aVet,{"E2_FORNECE" ,_cFornINS    		, Nil} )            
			AADD(_aVet,{"E2_LOJA"    ,"00"        		, Nil} )                                   
			AADD(_aVet,{"E2_NOMFOR"  ,_cFornINS    		, Nil} )         
			AADD(_aVet,{"E2_EMISSAO" ,SF1->F1_EMISSAO   , Nil} )     
			AADD(_aVet,{"E2_VENCTO"  ,_dVencto    		, Nil} ) 
			AADD(_aVet,{"E2_VENCORI" ,_dVencto    		, Nil} ) 
			AADD(_aVet,{"E2_VENCREA" ,_dVencto    		, Nil} )
			AADD(_aVet,{"E2_VALOR"   ,SF1->F1_VLSENAR	, Nil} )            
			AADD(_aVet,{"E2_EMIS1"   ,SF1->F1_EMISSAO   , Nil} )        
			AADD(_aVet,{"E2_DATALIB" ,SF1->F1_EMISSAO   , Nil} )        
			AADD(_aVet,{"E2_LA"      ,"S"            	, Nil} )
			AADD(_aVet,{"E2_SALDO"   ,SF1->F1_VLSENAR	, Nil} )       
			AADD(_aVet,{"E2_MOEDA"   ,1              	, Nil} )       
			AADD(_aVet,{"E2_VLCRUZ"  ,SF1->F1_VLSENAR	, Nil} )       
			AADD(_aVet,{"E2_FILORIG" ,xfilial("SE2")	, Nil} )             
			AADD(_aVet,{"E2_TITPAI"  ,SF1->(F1_SERIE+F1_DOC+'   NF '+F1_FORNECE+F1_LOJA), Nil} )             
	//		AADD(_aVet,{"E2_ORIGEM"  ,"MATA100" 		, Nil} )                          
			AADD(_aVet,{"E2_BASEPIS" ,0   				, Nil} )
			AADD(_aVet,{"E2_BASECOF" ,0   				, Nil} )
			AADD(_aVet,{"E2_BASECSL" ,0 				, Nil} )
			AADD(_aVet,{"E2_BASEIR"  ,0 				, Nil} )
			AADD(_aVet,{"E2_BASEISS" ,0 				, Nil} )
			AADD(_aVet,{"E2_BASEINS" ,0 				, Nil} )
	
			FINA050(_aVet,3)                     
			         
			If lMsErroAuto			
				MsgStop(OemToAnsi("Não foi possivel gerar titulo imposto SENAR !"))		
				MostraErro()
			Else
				
				//Para manter o vinculo com o titulo principal, grava origem no titulo TX e parcela do imposto no titulo NF
				dbselectarea("SE2")
				reclock("SE2",.f.)
				SE2->E2_ORIGEM := "MATA100"   
				msUnlock()
				
				//@Ticket 14662  - Leonardo Mont- 07/05/21 - Reformulação dos updates para prevenção de Deadlocks.
				/*
				cQuery := "UPDATE "+RetSqlName("SE2")+" SET "
	        	cQuery += "E2_PARCCSS = '001' "
	        	*/
				cQuery := " SELECT R_E_C_N_O_ SE2REG "
				cQuery += " FROM "+RetSqlName("SE2")+" (NOLOCK) E2 "
	        	cQuery += " WHERE E2_FILIAL = '"+SF1->F1_FILIAL+"' AND E2_NUM = '"+SF1->F1_DOC+"' AND E2_PREFIXO = '"+SF1->F1_SERIE+"' "
	        	cQuery += "  AND E2_TIPO = 'NF' AND E2_FORNECE = '"+SF1->F1_FORNECE+"' AND E2_LOJA = '"+SF1->F1_LOJA+"' AND E2_EMISSAO = '"+DTOS(SF1->F1_EMISSAO)+"' "
	        	//@Ticket T.I    - Leonardo Mont- 25/05/21 - Correção de error.log na integração de títulos e notas do SAG.
				//cQuery += "  AND E2_PARCELA IN ('   ','A  ') AND "+RetSqlName("SE2")+".D_E_L_E_T_ = '' "
				cQuery += "  AND E2_PARCELA IN ('   ','A  ') AND E2.D_E_L_E_T_ = '' "
	        	//TCSQLExec(cQuery)    

				TcQuery cQuery ALIAS "QE2X" NEW

				DbSelectArea("SE2")

				While QE2X->(!EOF())
					SE2->(dbgoto(QE2X->SE2REG))

					if SE2->(recno()) == QE2X->SE2REG
						if reclock("SE2",.F.)
							SE2->E2_PARCCSS = '001'
							SE2->(MsUnlock())	
						endif
					Endif
					QE2X->(Dbskip())
				enddo
				
				QE2X->(dbCloseArea())
	  		Endif
	  	
	  	Endif // incluido por Adriana em 28/06/2019 chamado 050131
  		
		RestArea(CVAR)	
		RestArea(_aAreaSA2) //incluido por Adriana em 28/06/2019 chamado 050131

	//fim trecho incluido por Adriana Chamado 048333 em 25/04/2019
	ENDIF   
	
	
	// *** INICIO CHAMADO WILLIAM COSTA 18/10/2018 044433 || OS 045622 || FINANCAS || ALBERTO || 8480 || COND. PAGAMENTO  *** //
	
	IF nOpc == 1 // Inclusao
			
		IF SF1->F1_COND = '999' // Condicao de pagamento que precisa ser ajustada
			
			IF ALLTRIM(aCols[nPos])                == 'A' .AND. ; //Primeira Parcela
			   ALLTRIM(SE2->E2_PARCELA)            == 'A' .AND. ; //Primeira Parcela
			   SUBSTR(DTOC(aCols[nPosVencto]),1,2) <> '01'
			   
			   	RecLock("SE2",.F.)
					SE2->E2_VENCTO  := FirstDay(MonthSum(DDATABASE, 1))
					SE2->E2_VENCREA := DataValida(FirstDay(MonthSum(DDATABASE, 1)) , .T. )
				MsUnlock()
							    
			ENDIF
			
			IF ALLTRIM(aCols[nPos])                == 'B' .AND. ; //Segunda Parcela
			   ALLTRIM(SE2->E2_PARCELA)            == 'B' .AND. ; //Primeira Parcela
			   SUBSTR(DTOC(aCols[nPosVencto]),1,2) <> '15'
			   
			   	RecLock("SE2",.F.)
				    SE2->E2_VENCTO  := CTOD("15"+SUBSTRING(DTOC(MonthSum(DDATABASE, 1)),3,8))
					SE2->E2_VENCREA := DataValida(CTOD("15"+SUBSTRING(DTOC(MonthSum(DDATABASE, 1)),3,8)) , .T. )
				MsUnlock()
				
			ENDIF
			
		ENDIF	
	ENDIF
	// *** FINAL CHAMADO WILLIAM COSTA 18/10/2018 044433 || OS 045622 || FINANCAS || ALBERTO || 8480 || COND. PAGAMENTO  *** //
	
	RESTAREA(CVAR)

RETURN

Static Function SqlOutBanc(cFilAtu,cCodFor,cLojaFor)                          

	BeginSQL Alias "TRB"
			%NoPARSER%
			SELECT TOP(1) FIL_FORNEC,
			              FIL_LOJA,
				          FIL_BANCO,
				          FIL_AGENCI,
				          FIL_DVAGE,
				          FIL_CONTA,
				          FIL_DVCTA,
				          FIL_XCGC
			         FROM %Table:FIL% WITH (NOLOCK)
			        WHERE FIL_FILIAL  = %EXP:cFilAtu%
			          AND FIL_FORNEC  = %EXP:cCodFor%
			          AND FIL_LOJA    = %EXP:cLojaFor%
			          AND FIL_BANCO  <> ''
			          AND FIL_AGENCI <> ''
			          AND FIL_CONTA  <> ''
			          AND D_E_L_E_T_ <> '*'
			
			  ORDER BY FIL_TIPO
			
	EndSQl 
	            
RETURN(NIL) 
