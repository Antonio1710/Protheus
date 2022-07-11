#Include "Protheus.ch"
#Include "Topconn.ch" 
#Include "Apwizard.ch" 
#Include "Fileio.ch"  
#Include "Tbiconn.ch"

/*/{Protheus.doc} User Function ADFIS032P
	Lançamento de documento de entrada (CT-e) por xml. Chamado 044314. 
	@type  Function
	@author Everson
	@since 29/07/2019
	@version 01
	@history Everson-30/07/2019-Chamado 044314. Incluído envio do DACTE no e-mail de aviso de inclusão de documento.
	@history Everson-31/07/2019-Chamado 044314. Tratamento para enviar o erro de execauto por e-mail.
	@history Everson-05/08/2019-Chamado 044314. Removida função SetFunName.
	@history Everson-11/09/2019-Chamado 051692. Checa conta contábil.
	@history Everson-02/10/2019-Chamado 052277. Tratamento para checar se o CT-e existe na Central XML.
	@history Everson-11/11/2019-Chamado 029058. Parâmetros incluídos para lançamento de frete de frango vivo.
	@history Everson-12/11/2019-Chamado 029058. Adicionada filial 03 para entrada de CT-e automática.
	@history Everson-06/03/2020-Chamado 054941. Tratamento de parâmetros por empresa.
	@history Everson-18/03/2020-Chamado 054941. Tratamento de parâmetros por empresa e filial.
	@history Everson-18/03/2020-Chamado 054941. Tratamento para vincular a natureza correta ao CT-e.
	@history Leon	-22/07/2020-Chamado TI.		Comentar LockByName para contornar falta de execução de rotinas de agendamento;
	@history Everson-05/08/2020-Chamado TI. Validação Pedido de compra x CT-e.
	@history Ticket 70142   - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
	@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
	@history Abel   -25/04/2022-Ticket 69574.   Projeto FAI
	@history Everson-29/04/2022-Ticket 70593.   Projeto FAI
	/*/
User Function ADFIS032P(aXEmpFil) // U_ADFIS032P() //Everson-29/04/2022-Ticket 70593.

	//Declaracao de Variaveis.
	Local cEmail:= ""

	Default aXEmpFil :={ "01", "02" } //Everson-29/04/2022-Ticket 70593.

	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(aXEmpFil[1],aXEmpFil[2],,,,GetEnvServer(),{ }) //Everson-29/04/2022-Ticket 70593.

		// @history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
		//FWMonitorMsg(ALLTRIM(PROCNAME()))

		U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Lançamento de documento de entrada (CT-e) por xml')
		
		logZBN("1") //Log início.

			//Everson - 11/11/2019. Chamado 029058.
			cEmail	:= GetMv("MV_#AUTCTE",,"")
			
			Conout( DToC(Date()) + " " + Time() + " ADFIS032P - Início " + cFilAnt )

				processa(cEmail)

			Conout( DToC(Date()) + " " + Time() + " ADFIS032P - Fim " + cFilAnt )
		
		logZBN("2")

	RpcClearEnv()

Return Nil

/*/{Protheus.doc} processa
	Lançamento de documento de entrada (CT-e) por xml. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 16/07/2019
	@version 01
	/*/
Static Function processa(cEmail)
	//Declaracao de Variaveis
	//Local aArea 	:= GetArea()
	//Local cQuery	:= ""
	Local aParam	:= paramFis() //Everson - 21/10/2019. Chamado 029058.

	//
	MsAguarde({|| incDocN(aParam,cEmail) },"Aguarde...","Processando CT-e...")
Return Nil

/*/{Protheus.doc} incluiDoc
	Lançamento de documento de entrada - CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 16/07/2019
	@version 01
	/*/
Static Function incDocN(aParam,cEmail) 
	//Declaracao de Variaveis
	Local aArea	   	:= GetArea()
	Local aCab 		:= {}
	Local aItem 	:= {}
	Local aItens 	:= {}
	Local nPosPrd	:= 0
	Local xPula		:= Chr(13) + Chr(10)
	Local cNumDoc 	:= ""
	Local cSerDoc	:= ""
	Local cForne	:= ""
	Local cLoja		:= ""
	Local cNmFor	:= ""
	Local cChave	:= ""
	Local cChvCTe	:= ""
	Local cTes		:= ""
	Local cHash		:= ""
	Local cNmArq	:= ""
	Local lRetPdf	:= .F.
	Local cPFis		:= ""
	Local cRetCamin	:= ""
	Local aAreaExec := {}
	Local cErro		:= ""
	Local aErroLog	:= {}
	Local k			:= 1
	Local cUserEx	:= Alltrim(GetMv("MV_#USINCT",,""))
	Local cUpt		:= ""
	Local cCNPJ		:= ""
	
	Private lAutoErrNoFile 	:= .T. //Everson-31/07/2019-Chamado 044314.
	Private lMsErroAuto    	:= .F.
	Private lMsHelpAuto   	:= .T.
	Private cNaturez	    := ""
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - Início" )

	//
	cQuery := scriptSql("N")

	//
	If Select("D_CTEN") > 0
		D_CTEN->(DbCloseArea())
	EndIf

	//
	TcQuery cQuery New Alias "D_CTEN"
	DbSelectArea("D_CTEN")
	D_CTEN->(DbGoTop())

	//
	If ! D_CTEN->(Eof())
		//
		DbSelectArea("SF1")
		SF1->(DbSetOrder(1))
		SF1->(DbGoTop())

		//
		DbSelectArea("SC7")
		SC7->(DbSetOrder(24))
		SC7->(DbGoTop())

		//
		While ! D_CTEN->(Eof())
			//
			cNumDoc := Padl(Alltrim(D_CTEN->ZFK_NUMDOC),9,"0") 
			cSerDoc	:= Padr(Alltrim(cValToChar(D_CTEN->ZFK_SERDOC)),TamSX3("F1_SERIE")[1]," ")
			cForne	:= Alltrim(D_CTEN->ZFK_TRANSP)
			cLoja	:= Alltrim(D_CTEN->ZFK_LOJA)
			cChave  := FWxFilial("SF1") + cNumDoc + cSerDoc + cForne  +  cLoja
			cChvCTe	:= Alltrim(D_CTEN->ZFK_CHAVE)
			cNmFor  := Posicione("SA2",1, FWxFilial("SA2") + cForne + cLoja, "A2_NOME" )
			cCNPJ	:= Posicione("SA2",1, FWxFilial("SA2") + cForne + cLoja, "A2_CGC" )
		
			//
			SF1->(DbGoTop())
			If SF1->( DbSeek( cChave ) )
				//
				If Alltrim(SF1->F1_ESPECIE) = "CTE"
					//
					fechReg(cChvCTe,cNumDoc,cSerDoc,cForne,cLoja)
					
					//
					Conout( DToC(Date()) +;
					" " + Time() +;
					" ADFIS032P - incDocN - CT-e já consta na base " +;
					cChave )
					D_CTEN->(DbSkip())
					Loop
				EndIf
			EndIf
			
			//
			Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - processando - filial/chave " + cFilAnt + " " + cChave )

			//Everson - 02/09/2019. Chamado 
			If ! U_ExistXML(cNumDoc, Alltrim(cValToChar(cSerDoc)), cCNPJ, "CTE")
				Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - não localizado Central XML - filial/chave " + cFilAnt + " " + cChave )
				D_CTEN->(DbSkip())
				Loop
			EndIf

			//Cabeçalho
			aCab 	:= {}
			aItens 	:= {}
			aItem 	:= {}
			   
			//
			nPosPrd := Ascan(aParam,{|x| Alltrim(cValToChar(x[1])) == Alltrim(cValToChar(D_CTEN->C7_PRODUTO)) })
			
			//
			Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - nPosPrd " + cValToChar(nPosPrd) )
	
			//
			If nPosPrd <= 0
				//
				Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - nPosPrd - produto não localizado - filial/produto " + cFilAnt + " " + Alltrim(cValToChar(D_CTEN->C7_PRODUTO)) )
				
				//				
				fechReg(cChvCTe,cNumDoc,cSerDoc,cForne,cLoja)
				MsgAlert("Para o CT-e " + Alltrim(D_CTEN->ZFK_NUMDOC) + "/" + Alltrim(D_CTEN->ZFK_SERDOC) + " do fornecedor " + Alltrim(D_CTEN->ZFK_TRANSP) + "-" + Alltrim(D_CTEN->ZFK_LOJA) + " e produto " + Alltrim(SC7->C7_PRODUTO) + ", não foi localizado parâmetro fiscal.","Função incDocN(ADFIS03P)")
				D_CTEN->(DbSkip())
				Loop				
			EndIf

			//Everson - 05/08/2020. Chamado TI.
			If D_CTEN->ZFK_VALOR <> D_CTEN->C7_TOTAL
				MsgAlert("Valores divergente CT-e " + cValToChar(cNumDoc) + " x Pedido de Compra " + cValToChar(D_CTEN->C7_ITEM) + ".","Função incDocN(ADFIS03P)")
				D_CTEN->(DbSkip())
				Loop

			EndIf
			//
			
			//
			VarInfo("aParam",aParam)
						
			//
			Aadd(aCab,{"F1_TIPO" 	,"N" 					 ,Nil})
			Aadd(aCab,{"F1_FORMUL"	,"N" 					 ,Nil})
			Aadd(aCab,{"F1_DOC" 	,cNumDoc                 ,Nil})
			Aadd(aCab,{"F1_SERIE" 	,cSerDoc          		 ,Nil})
			Aadd(aCab,{"F1_EMISSAO"	,SToD(D_CTEN->ZFK_DTEMIS),Nil})
			Aadd(aCab,{"F1_DTDIGIT"	,dDataBase 				 ,Nil})
			Aadd(aCab,{"F1_FORNECE"	,cForne         		 ,Nil})
			Aadd(aCab,{"F1_LOJA" 	,cLoja          		 ,Nil})
			Aadd(aCab,{"F1_ESPECIE"	,"CTE" 					 ,Nil})
			Aadd(aCab,{"F1_COND" 	,D_CTEN->C7_COND 		 ,Nil})
			Aadd(aCab,{"F1_MOEDA" 	, 1 					 ,Nil})
			Aadd(aCab,{"F1_TXMOEDA"	, 1 					 ,Nil})
			Aadd(aCab,{"F1_STATUS"	,"A" 					 ,Nil})
			Aadd(aCab,{"F1_CHVNFE"	,Alltrim(D_CTEN->ZFK_CHAVE),Nil})  
			//Aadd(aCab,{"F1_NATUREZ"	,aParam[nPosPrd][4]  	 ,Nil})
			Aadd(aCab,{"F1_TPNOTA"	,"FRETE"              	 ,Nil})
			Aadd(aCab,{"F1_UFORITR"	,D_CTEN->ZFK_ESTORI      ,Nil})
	 		Aadd(aCab,{"F1_MUORITR"	,D_CTEN->ZFK_MUNORI		 ,Nil})
	 		Aadd(aCab,{"F1_UFDESTR"	,D_CTEN->ZFK_ESTCLI		 ,Nil})
	 		Aadd(aCab,{"F1_MUDESTR"	,D_CTEN->ZFK_CODMUN 	 ,Nil})
	 		Aadd(aCab,{"E2_NATUREZ"	,aParam[nPosPrd][4]	 	 ,Nil}) //(2)Everson-18/03/2020-Chamado 054941.
			//Aadd(aCab,{"F1_NATUREZ"	,aParam[nPosPrd][4]	 	 ,Nil})
	 		
	 		//
	 		Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - ICMS " + Alltrim(cValToChar(D_CTEN->ZFK_ICMS)) )
	 		Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - TES " + Iif(Alltrim(cValToChar(D_CTEN->ZFK_ICMS)) = "2",aParam[nPosPrd][3],aParam[nPosPrd][2]) )
	 		cTes := Iif(Alltrim(cValToChar(D_CTEN->ZFK_ICMS)) = "2",aParam[nPosPrd][3],aParam[nPosPrd][2])
	 		cHash:= Alltrim(cValToChar(D_CTEN->ZFK_HASH))
	 		
			//
			Aadd(aItem,{"D1_ITEM" 	,"0001" 			,Nil})
			Aadd(aItem,{"D1_COD" 	,D_CTEN->C7_PRODUTO ,Nil})
			Aadd(aItem,{"D1_UM" 	,D_CTEN->C7_UM 		,Nil})
			Aadd(aItem,{"D1_QUANT"	,D_CTEN->C7_QUANT 	,Nil}) 
			Aadd(aItem,{"D1_VUNIT"	,D_CTEN->ZFK_VALOR	,Nil}) 
			Aadd(aItem,{"D1_TOTAL"	,D_CTEN->ZFK_VALOR	,Nil})
			
			Aadd(aItem,{"D1_PEDIDO"	,D_CTEN->C7_NUM		,Nil})
			Aadd(aItem,{"D1_ITEMPC"	,D_CTEN->C7_ITEM 	,Nil})

			//Everson - 18/03/2020. Chamado 054941.
			If ! Empty(Alltrim(D_CTEN->C7_ITEMCTA))
				Aadd(aItem,{"D1_ITEMCTA"	,D_CTEN->C7_ITEMCTA 	,Nil})
			EndIf

			Aadd(aItem,{"D1_TES"	,cTes               ,Nil})

			//
			Aadd(aItens,aItem)
			
			//
			aCab   := FWVetByDic(aCab  ,"SF1",.F.,1)
			//aItens := FWVetByDic(aItens,"SD1",.T.,1)

			//
			cNaturez := aParam[nPosPrd][4]
			
			//
			DbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			
			//
			If ! SC7->( DBSeek( FWxFilial("SC7") + Alltrim(D_CTEN->C7_NUM) ) )
				MsgStop("Não foi possível localizar o pedido de compra " + Alltrim(D_CTEN->C7_NUM) + ". CT-e | Fornecedor " + cNumDoc + "-" + cSerDoc +;
				        " | " + cForne + "-" + cLoja + " não poderá ser lançado.","Função incDocN(ADFIS032P)")
				D_CTEN->(DbSkip())
				Loop
			EndIf
			
			//
			While ! SC7->(Eof()) .And. SC7->C7_FILIAL = FWxFilial("SC7") .And. SC7->C7_NUM = Alltrim(D_CTEN->C7_NUM)
				//
				If Alltrim(SC7->C7_TES) <> cTes
					RecLock("SC7",.F.)
						Replace C7_TES With cTes
					SC7->(MsUnlock())
				EndIf
			
				SC7->(DbSkip())
			End
			
			//
			VarInfo("aCab",aCab)
			VarInfo("aItens",aItens)
			//SetFunName("MATA103") //Everson-05/08/2019-Chamado 044314.
			
			//
			If ! Empty(cUserEx)
				__cUserId := cUserEx
			EndIf
			
			//
			lMsErroAuto := .F.
			lMsHelpAuto := .T.
			
			//
			Begin Transaction
				//
				aAreaExec := GetArea()
				MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,3)
				RestArea(aAreaExec)

				//
				If ! lMsErroAuto
					//
					If ! SF1->( DbSeek( cChave ) )
						//
						Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - cChave " + cChave )
						
						MsgStop("CT-e abaixo não pode integrado:" + xPula +;
								"CT-e: " + cNumDoc + "/" + cSerDoc + xPula +;
								"Fornecedor: " + cForne + "-" + cLoja,"Função incDocN(ADFIS032P)")
					Else
						//Everson-11/09/2019-Chamado 051692.
						DbSelectArea("SD1")
						SD1->(DbSetOrder(1))
						SD1->(DbGoTop())
						If SD1->( DbSeek( FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + D_CTEN->C7_PRODUTO + "0001" ) )
								Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - SD1 " + FWxFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + D_CTEN->C7_PRODUTO + "0001"  )
								Conout( SD1->D1_ITEM )
								Conout( SD1->D1_CONTA )

								//
								cUpt := " UPDATE " + RetSqlName("SFT") + " SET FT_CONTA = '" + cValToChar(SD1->D1_CONTA) + "', FT_ITEM = '" + cValToChar(SD1->D1_ITEM) + "' " 
								cUpt += " WHERE FT_FILIAL = '" + FWxFilial("SFT") + "' "
								cUpt += " AND FT_CLIEFOR = '" + cValToChar(SF1->F1_FORNECE) + "' AND FT_LOJA = '" + cValToChar(SF1->F1_LOJA) + "' AND FT_NFISCAL = '" + cValToChar(SF1->F1_DOC) + "' "
								cUpt += " AND FT_SERIE = '" + cValToChar(SF1->F1_SERIE) + "' AND FT_PRODUTO = '" + cValToChar(SD1->D1_COD) + "' AND FT_TIPOMOV = 'E' AND D_E_L_E_T_ = '' "

								//
								Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - cUpt -  " + cUpt )

								//
								If TCSqlExec(cUpt) < 0
									Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - ERRO TCSqlExec -  " + TCSQLError() )
								EndIf
						EndIf 
	
						//				
						fechReg(cChvCTe,cNumDoc,cSerDoc,cForne,cLoja)
						
						//Everson-30/07/2019-Chamado 044314.
						cPFis  := "\cte_log\"
						cNmArq := cNumDoc+cSerDoc+cForne+cLoja+"_ADFIS032P"
						//lRetPdf:= Static CAll(ADLOG057P,pdfCTEdow,cHash,cPFis,"",.F.,cNmArq,@cRetCamin)
						//@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
						lRetPdf:= u_LOG057A0(cHash,cPFis,"",.F.,cNmArq,@cRetCamin)
						
						//
						Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - lRetPdf " + cValToChar(lRetPdf) )
						//
						envEmail(cEmail,cForne,cLoja,cNmFor,cNumDoc,cSerDoc,Iif(lRetPdf,cRetCamin,""))
					EndIf
				Else
					//
					aErroLog := {}
					aErroLog := GetAutoGrLog()
					cErro    := ""
					
					//
					For k := 1 to Len(aErroLog)
						//If "INVALIDO" $ UPPER (aErroLog[k])
							cErro+= "<p>" + Alltrim(aErroLog[k]) + "</p>" + Chr(13) + Chr(10)
						//EndIf
					Next
					
					envEmail(cEmail,cForne,cLoja,cNmFor,cNumDoc,cSerDoc,"",2,cErro)
					Conout( DToC(Date()) + " " + Time() + " ADFIS032P - incDocN - nPosPrd - lMsErroAuto " )
					//MostraErro()
					
					//
					MsgStop("Ocorreu erro na inclusão do CT-e " + Alltrim(cNumDoc) + "-" + Alltrim(cSerDoc) + " | " + Alltrim(cForne) + "-" + Alltrim(cLoja) + " " + Alltrim(cNmFor) + "." + Chr(13) + Chr(10) + cErro ,"Função incDocN(ADFIS032P)")
					
					//
					DisarmTransaction()
					Break
				EndIf
			End Transaction

			//
			D_CTEN->(DbSkip())
		End
	EndIf

	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} envEmail
	Envia e-mail de inclusão de CT-e. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 29/07/2019
	@version 01
	/*/
Static Function envEmail(cEmail,cForne,cLoja,cNmFor,cNumDoc,cSerDoc,cAttach,nOPc,cErro)
	//Declaracao de Variaveis
	Local aArea	   	:= GetArea()
	Local cMensagem	:= ""
	
	Default nOPc	:= 1
	Default cErro	:= ""

	//
	cMensagem := " "
	cMensagem += "<html>"
	cMensagem += "<body> "
	cMensagem += "<p>Inclusão automática de CT-e (ADFIS032P)</p> "
	
	//
	If nOPc == 1
		cMensagem += "<p>Por favor, verifique se o documento abaixo foi lançado corretamente.</p> "
	Else
		cMensagem += "<p>Ocorreu erro na inclusão do CT-e abaixo.</p> "
		cMensagem += "<p>" + cErro + "</p> 
	EndIf
	
	//
	cMensagem += "<div style='text-align: left;'> "
		cMensagem += "<p>Fornecedor: " + cForne  + "/" + cLoja   + "-" + cNmFor + "</p>"
		cMensagem += "<p>CT-e: "       + cNumDoc + "/" + cSerDoc + "</p>"
	cMensagem += "</div> "
	
	cMensagem += "<div style='text-align: left;'> "
		cMensagem += "<span style='font-size:14px;'><span style='font-family:verdana,geneva,sans-serif;'>Sistema de Frete - Ad&#39;oro - e-mail enviado automaticamente. Por favor, não responda. " + cValToChar(ThreadId()) + "</span></span>" 
	cMensagem += "</div> "
	
	cMensagem += "</body>"
	cMensagem += "</html>"
	
	//
	U_F50En2WF(cEmail,"","Inclusão automática de CT-e.",cMensagem,cAttach)
	
	//
	Sleep(1000)
	If ! Empty(cAttach)
		FErase(cAttach)
	EndIf
					
	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} fechReg
	Fecha registro na tabela ZFK. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 26/07/2019
	@version 01
	/*/
Static Function fechReg(cChvCTe,cNumDoc,cSerDoc,cForne,cLoja)
	//Declaracao de Variaveis
	Local aArea	   	:= GetArea()
	Local cUpdate	:= ""
	Local xPula		:= Chr(13) + Chr(10)
	
	Default cChvCTe	:= ""
	
	//
	If Empty(cChvCTe)
		RestArea(aArea)
		Return Nil
	EndIf
	
	//
	cUpdate := " UPDATE " + RetSqlName("ZFK") + " SET ZFK_ENTRAD = '2' WHERE ZFK_FILIAL = '" + FWxFilial("ZFK") + "' AND ZFK_CHAVE = '" + cChvCTe + "' AND D_E_L_E_T_ = '' "
	
	//
	If TcSqlExec(cUpdate) < 0
		Conout( DToC(Date()) + " " + Time() + " ADFIS032P - fechReg - TCSQLError " + TCSQLError() )
	EndIf
	
	//
	If TCSqlExec(cUpdate) < 0
		MsgStop("Não foi possível atualizar a tabela ZFK para o documento abaixo."  + xPula +;
		"CT-e: " + Alltrim(cNumDoc) + "/" + Alltrim(cSerDoc)  + xPula +;
		"Fornecedor: " + Alltrim(cForne) + "-" + Alltrim(cLoja) ,"Função fechReg(ADFIS0327)")
	EndIf
	
	//
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} scriptSql
	Script sql com os CT-es pendentes de entrada. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 16/07/2019
	@version 01
	/*/
Static Function scriptSql(cTpEmiss)
	//Declaracao de Variaveis
	Local aArea	   	:= GetArea()
	Local nNumAnt	:= GetMv("MV_#DTITCT")
	
	//
	cQuery := ""
	cQuery += " SELECT " 
	cQuery += " BASE.*, " 
	cQuery += " SZFK.ZFK_CODMUN, " 
	cQuery += " SZFK.ZFK_ESTCLI, " 
	cQuery += " SZFK.ZFK_MUNORI, " 
	cQuery += " SZFK.ZFK_ESTORI " 
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " SELECT    " 
	cQuery += " ZFK.ZFK_FILIAL, ZFK.ZFK_PEDCOM, ZFK.ZFK_TRANSP, ZFK.ZFK_LOJA, ZFK.ZFK_DTEMIS,  " 
	cQuery += " ZFK.ZFK_NUMDOC, ZFK.ZFK_SERDOC, ZFK.ZFK_ICMS, C7_PRODUTO, C7_COND, C7_UM,  " 
	cQuery += " C7_QUANT, C7_PRECO, C7_TOTAL, C7_NUM, C7_ITEM, C7_ITEMCTA, " //Everson - 18/03/2020. Chamado 054941.
	cQuery += " ZFK_TPCARG, SUM(ZFK.ZFK_VALOR) AS ZFK_VALOR, MAX(ZFK.ZFK_SEQENT) AS ZFK_SEQENT, ZFK.ZFK_CHAVE, ZFK.ZFK_CTECOM, ZFK.ZFK_SERCOM, ZFK.ZFK_HASH " //Everson - 11/11/2019. Chamado 029058.
	cQuery += " FROM   " 
	cQuery += " " + RetSqlName("ZFK") + " (NOLOCK) AS ZFK   " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SC7") + " (NOLOCK) AS SC7 ON " 
	cQuery += " ZFK_FILIAL     = C7_FILIAL " 
	cQuery += " AND ZFK_PEDCOM = C7_NUM " 
	cQuery += " AND ZFK_TRANSP = C7_FORNECE " 
	cQuery += " AND ZFK_LOJA   = C7_LOJA " 
	cQuery += " AND RIGHT('000000000' + RTRIM(LTRIM(ZFK_NUMDOC)),9) = C7_XNUMCTE " 
	cQuery += " AND RIGHT('000' + RTRIM(LTRIM(ZFK_SERDOC)),3) = C7_XNUSCTE " 
	cQuery += " WHERE   " 
	cQuery += " ZFK.ZFK_FILIAL     = '" + FWxFilial("ZFK") +"'   " 
	cQuery += " AND ZFK.ZFK_TPDOC  = '1' " 
	cQuery += " AND ZFK.ZFK_STATUS = '1' " 
	cQuery += " AND ZFK.ZFK_TMEMIS = '" + cTpEmiss + "' " 
	cQuery += " AND ZFK.ZFK_ENTRAD = '1' " 
	cQuery += " AND ZFK.ZFK_PEDCOM <> '' " 
	cQuery += " AND ZFK.D_E_L_E_T_ = ''  " 
	cQuery += " AND CAST(ZFK.ZFK_DATA AS DATE)  >= CAST(GETDATE() -" + cValToChar(nNumAnt) + " AS DATE)  "
	cQuery += " AND C7_CONAPRO     = 'L' " 
	cQuery += " AND SC7.D_E_L_E_T_ = ''  " 
	cQuery += " GROUP BY   " 
	cQuery += " ZFK.ZFK_FILIAL, ZFK.ZFK_PEDCOM, ZFK.ZFK_TRANSP, ZFK.ZFK_LOJA, ZFK.ZFK_DTEMIS,  " 
	cQuery += " ZFK.ZFK_NUMDOC, ZFK.ZFK_SERDOC, ZFK.ZFK_ICMS, C7_PRODUTO, C7_COND, C7_UM, C7_ITEMCTA, " //Everson - 18/03/2020. Chamado 054941.
	cQuery += " C7_QUANT, C7_PRECO, C7_TOTAL, C7_NUM, C7_ITEM, ZFK.ZFK_CHAVE, ZFK.ZFK_CTECOM, ZFK.ZFK_SERCOM, ZFK.ZFK_HASH, ZFK.ZFK_TPCARG " //Everson - 11/11/2019. Chamado 029058.
	cQuery += " )AS BASE " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " ( " 
	cQuery += " SELECT  " 
	cQuery += " ZFK_FILIAL, ZFK_PEDCOM, " 
	cQuery += " ZFK_TRANSP, ZFK_LOJA,   " 
	cQuery += " ZFK_NUMDOC, ZFK_SERDOC, " 
	cQuery += " ZFK_SEQENT, ZFK_CODMUN, " 
	cQuery += " ZFK_ESTCLI, ZFK_MUNORI, " 
	cQuery += " ZFK_ESTORI " 
	cQuery += " FROM " + RetSqlName("ZFK") + " (NOLOCK) AS SUBZFK " 
	cQuery += " WHERE  " 
	cQuery += " ZFK_FILIAL = '" + FWxFilial("ZFK") +"' AND ZFK_TPDOC = '1' AND ZFK_TMEMIS = 'N' AND ZFK_STATUS = '1' AND ZFK_ENTRAD = '1' AND SUBZFK.D_E_L_E_T_ = '' " 
	cQuery += "  ) AS SZFK ON " 
	cQuery += " BASE.ZFK_FILIAL = SZFK.ZFK_FILIAL " 
	cQuery += " AND BASE.ZFK_PEDCOM = SZFK.ZFK_PEDCOM " 
	cQuery += " AND BASE.ZFK_TRANSP = SZFK.ZFK_TRANSP " 
	cQuery += " AND BASE.ZFK_LOJA   = SZFK.ZFK_LOJA   " 
	cQuery += " AND BASE.ZFK_NUMDOC = SZFK.ZFK_NUMDOC " 
	cQuery += " AND BASE.ZFK_SERDOC = SZFK.ZFK_SERDOC " 
	cQuery += " AND BASE.ZFK_SEQENT = SZFK.ZFK_SEQENT " 		
	cQuery += " ORDER BY    " 
	cQuery += " BASE.ZFK_TPCARG, BASE.ZFK_PEDCOM, BASE.ZFK_SERDOC, BASE.ZFK_NUMDOC " //Everson - 11/11/2019. Chamado 029058.
	
	//
	Conout( DToC(Date()) + " " + Time() + " ADFIS032P - scriptSql - cTpEmiss/cQuery " + cTpEmiss + " " + cQuery )

	//
	RestArea(aArea)
Return cQuery

/*/{Protheus.doc} paramFis
	Parâmetros para entrada de documento fiscal. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/11/2019
	@version 01
	/*/
Static Function paramFis() //Everson - 21/10/2019. Chamado 029058.
	//Declaracao de Variaveis
	Local aArea	   	:= GetArea()
	Local aDados	:= {}

	//Produto,TES sem ICMS, TES com ICMS, Natureza da operação.
	//Everson - 06/03/2020. Chamado 054941.
	If cEmpAnt == "01" //Everson - 18/03/2020. Chamado 054941.
		//
		//Abel   -25/04/2022-Ticket 69574.   Projeto FAI
		If Alltrim(cFilAnt) $ "02|0B"
			Aadd(aDados,{"800922","03E","405","22003"}) //Longo percurso.
			Aadd(aDados,{"800923","03E","405","22003"}) //Frete varejo.
			Aadd(aDados,{"808360","03E","405","22003"}) //Frete exportação
			Aadd(aDados,{"800925","054","054","22007"}) //Frete armazenagem.
			Aadd(aDados,{"801607","054","054","22007"}) //Frete diversos/Transf.
			Aadd(aDados,{"891695","03E","405","22003"}) //Frete subproduto.
			Aadd(aDados,{"843888","355","355","22007"}) //Frete Guarantã.
			Aadd(aDados,{"844372","054","054","22007"}) //Armazenagem Arfrio.
			Aadd(aDados,{"843887","142","142","22007"}) //Frete Rosaves.
			Aadd(aDados,{"800924","07Q","07Q","22004"}) //Frete Frango Vivo. Everson - 11/11/2019. Chamado 029058.
		ElseIf cFilAnt == "03"
			Aadd(aDados,{"801607","07Q","07Q","22007"}) //Frete diversos/Transf.
			Aadd(aDados,{"854206","07Q","07Q","22007"}) //Frete diversos/Transf.
		EndIf
	ElseIf cEmpAnt == "02"
		//
		Aadd(aDados,{"","","",""})
	ElseIf cEmpAnt == "07"
		//
		Aadd(aDados,{"801607","054","054","22007"}) //Frete diversos/Transf. Everson - 05/03/2020. Chamado 054941.
		Aadd(aDados,{"800923","054","054","22007"}) //Frete Varejo. Everson - 05/03/2020. Chamado 054941.
	ElseIf cEmpAnt == "09"
		//
		Aadd(aDados,{"","","",""})
	EndIf

	//
	RestArea(aArea)
Return aDados

/*/{Protheus.doc} logZBN
	Gera log na ZBN. Chamado 044314.
	@type  Static Function
	@author Everson
	@since 06/11/2019
	@version 01
	/*/
Static Function logZBN(cStatus)
	//Declaração de variávies
	Local aArea	:= GetArea()
	
	DbSelectArea("ZBN") 
	ZBN->(DbSetOrder(1))
	ZBN->(DbGoTop()) 
	If ZBN->(DbSeek(xFilial("ZBN") + 'ADFIS032P'))
		RecLock("ZBN",.F.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS032P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 
	Else
		RecLock("ZBN",.T.)
			ZBN_FILIAL  := xFilial("ZBN")
			ZBN_DATA    := Date()
			ZBN_HORA    := cValToChar(Time())
			ZBN_ROTINA	:= 'ADFIS032P'
			ZBN_STATUS	:= cStatus
		MsUnlock() 	
	EndIf
	
	ZBN->(dbCloseArea())
		
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} u_FIS032A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_FIS032A0()
Return( paramFis() )

/*/{Protheus.doc} u_FIS032A1
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_FIS032A1( uPar1 )
Return( processa( uPar1) )
