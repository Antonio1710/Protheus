#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TOTVS.CH"
#Include "Topconn.ch"
#Include "FWMVCDef.ch"
/*/{Protheus.doc} User Function ADLOG047P
	Função gera movimento de desconto de frete a partir de lançamentos de ocorrências de frete.
	@type  Function
	@author Ricardo Lima
	@since 16/11/2018
	@version 01
	@history 21/03/2019, Everson, Chamado 044314, refeita rotina de lançamento de desconto por devolução.
	@history 09/04/2019, Everson, Chamado 044314, alterada data do movimento para que seja igual a data de lançamento.
	@history 24/07/2019, Everson, Chamado 044314, incluída placa do cavalo mecânico.
	@history 28/10/2019, Everson, Chamado 029058, incluído flag para definir o tipo de frete.
	@history 05/11/2019, Everson, Chamado 029058, tratamento para utilizar a rotina automática para inclusão de registro.
	@history 27/11/2019, Everson, Chamado 029058, tratamento para utilizar a rotina automática para inclusão de registro.
	/*/  
User Function ADLOG047P( cNota , cSerie ) // MsAguarde({|| U_ADLOG047P("001543336","01") },"Aguarde","Lançando desconto de frete...")
	
	//Everson - 21/03/2019. Chamado 044314.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	Local aArea		:= GetArea() 
	Local cQuery	:= ""
	Local cCarga	:= ""
	Local cPlaca	:= ""
	Local nVlr		:= 0
	Local cObs		:= ""
	Local cMemoDv	:= ""
	Local xPula		:= Chr(13) + Chr(10)
	Local nTotReg	:= 0
	Local nAux		:= 0
	Local cTpDev	:= ""
	Local nQtdDev	:= 0
	Local cCliente	:= ""
	Local cDtEntO	:= ""
	
	//
	Private sDscOcos := ""
    Private sTpOcorr := ""
    Private nPercDes := 0
	Private sCodOdev := ""
	
	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Função gera movimento de desconto de frete a partir de lançamentos de ocorrências de frete.')
	
	//Verifica se já há lançamento de desconto por devolução referente às notas fiscais de saída vinculadas.
	Begin Transaction //Everson - 05/11/2019. Chamado 029058.

		//
		DbSelectArea("ZFA")
		ZFA->(DbSetOrder(8))
		ZFA->(DbGoTop())
		If ZFA->(DbSeek( FwFilial("ZFA") + cNota +  cSerie ))

			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG047P - DbSeek(ZFA) - Encontrou nota fiscal " + cNota + cSerie )

			//
			While ! ZFA->(Eof()) .And. ZFA->ZFA_FILIAL = FwFilial("ZFA") .And. ZFA->ZFA_NNFDEV = cNota .And. ZFA->ZFA_SNFDEV = cSerie

				//Everson - 28/10/2019. Chamado 029058.
				oModel:= FwLoadModel ("ADLOG040P")
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()
	
				//
				If oModel:VldData()
					oModel:CommitData()
	
				Else
					aError := oModel:GetErrorMessage()
					Conout( DToC(Date()) + " " + Time() + " ADLOG047P - Erro exclusão de registro - aError ")
					Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
					Help(Nil, Nil, "Função estAdianta(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
					DisarmTransaction()
					Break	
	
				EndIf					
				
				//
				oModel:DeActivate()
				oModel:Destroy()
				oModel := Nil		
				
				//
				ZFA->(DbSkip())
				
			End

		Else 
			
			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG047P - DbSeek(ZFA) - Não Encontrou nota fiscal " + cNota + cSerie )

		EndIf
			
		//Obtém os dados da ocorrência de devolução (tabela SZD - ocorrências do monitoramento da logística).
		cQuery := getQuery(cNota, cSerie)
		Conout( DToC(Date()) + " " + Time() + " ADLOG047P - getQuery - cQuery " + cQuery )
		If Select("D_DEV") > 0
			D_DEV->(DbCloseArea())
			
		EndIf
		
		//
		TcQuery cQuery New Alias "D_DEV"
		DbSelectArea("D_DEV")
		nTotReg	:= Contar("D_DEV","!Eof()")
		
		//
		If nTotReg > 0
		
			D_DEV->(DbGoTop())
			While ! D_DEV->(Eof())
				
				//
				cTpDev := Alltrim(cValToChar(D_DEV->ZD_DEVTOT))
				
				//
				If cTpDev = "T"
					sCodOdev := Alltrim(GetMv( "MV_#ADL471" ,, '016') )
					
				Else
					sCodOdev := Alltrim(GetMv( "MV_#ADL472" ,, '065') )
					
				EndIf
			
				//Busca informações da tabela de ocorrências.
				DbSelectArea("ZF7")
				ZF7->(DbSetOrder(1))
				ZF7->(DbSeek( FWxFilial("ZF7") + sCodOdev ))
				
				//
				sDscOcos := ZF7->ZF7_DESC
				sTpOcorr := ZF7->ZF7_DBCD
				nPercDes := ZF7->ZF7_PERDSC
					
				//
				nAux++
				
				cCliente := Alltrim(cValToChar(Posicione("SC5",1,xFilial("SC5") + Alltrim(cValToChar(D_DEV->D2_PEDIDO)) ,"C5_NOMECLI")))
				cDtEntO	 := Alltrim(cValToChar(DToC( Posicione("SC5",1,xFilial("SC5") + Alltrim(cValToChar(D_DEV->D2_PEDIDO)) ,"C5_DTENTR") )))
				
				//Calcula o valor a ser descontado.
				If cTpDev = "T"
					nVlr := Val(cValToChar(D_DEV->F2_VALMERC))*(nPercDes/100)
					cObs := cCliente + "-" + cDtEntO + " NF " + cNota + " " + cSerie
					
				Else
					nVlr += Val(cValToChar(D_DEV->VLR_TOTQ))
					cObs := cCliente + "-" + cDtEntO + " NF " + cNota + " " + cSerie
					
				EndIf
				
				//Cria memo da devolução.
				cMemoDv += "Devolução: "      + Iif( cTpDev = "T","Total","Quebra" )	+ xPula
				cMemoDv += "Responsável: "    + Alltrim(cValToChar(D_DEV->ZD_RESPNOM)) 	+ xPula
				cMemoDv += "Motivo: "         + Alltrim(cValToChar(D_DEV->ZD_DESCMOT)) 	+ xPula
				cMemoDv += "Pedido: "         + Alltrim(cValToChar(D_DEV->D2_PEDIDO))  	+ xPula
				cMemoDv += "Produto: "        + Alltrim(cValToChar(D_DEV->D2_COD))     	+ "-" + Alltrim(cValToChar(D_DEV->ZX_DESCRIC)) + xPula
				
				nQtdDev := Iif( cTpDev = "T",D_DEV->ZX_QTDE,D_DEV->ZX_QUEBRA)
				cMemoDv += "Quantidade: "     + Transform(Val(cValToChar( nQtdDev )),"@E 999,999,999.99")  + xPula
				cMemoDv += "Preço unitário: " + Transform(Val(cValToChar(D_DEV->D2_PRCVEN)),"@E 999,999,999.99") + xPula
				If cTpDev = "Q"
					cMemoDv += "Desconto item " + Transform(Val(cValToChar(D_DEV->VLR_TOTQ)),"@E 999,999,999.99")  + xPula
					
				EndIf
				
				cMemoDv += Replicate("-",100) + xPula + xPula
				
				//
				If nTotReg = nAux
					cMemoDv += xPula+ "Valor da nota " + Transform(Val(cValToChar(D_DEV->F2_VALMERC)),"@E 999,999,999.99")  + xPula
				
				EndIf
				
				//
				cCarga := D_DEV->ZFD_COD
				cPlaca := D_DEV->ZD_PLACA
				
				D_DEV->(DbSkip())
				
			End
			
			//Lança o novo registro de ocorrência.
			grvZFA(cNota,cSerie,cCarga,cPlaca,nVlr,cObs,nPercDes,cMemoDv,cTpDev)
		
		EndIf
		
		//
		D_DEV->(DbCloseArea())

	End Transaction

    //
    RestArea(aArea)
    
Return Nil
/*/{Protheus.doc} grvZFA
	Função Grava/Altera regisro de movimento de frete.
	@type  Static Function
	@author Everson
	@since 19/03/2019
	@version 01
	/*/  
Static Function grvZFA(cNota,cSerie,cCarga,cPlaca,nVlr,cObs,nPercDes,cMemoDv,cTpDev)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local nVlrEnt	:= 0
	Local cTransPa	:= ""
	Local cLojaPa	:= ""
	Local cNmTpa
	Local cTabFrt	:= ""

	//
	Local dDTEntr	:= SToD("")
	Local cRoteir	:= ""
	Local nNumEnt	:= 0
	Local cTpCarga	:= ""
	Local cVeiculo	:= ""
	Local cTransp	:= ""
	Local cLjTran	:= ""
	Local cNmTran	:= ""
	Local nTotKm	:= 0
	Local nVlrPdg	:= 0
	Local nTotKg	:= 0
	Local nTotCx	:= 0
	Local nTotBr	:= 0
	Local cTbFrt	:= ""
	Local cDscFrt	:= ""
	Local cTpFrt	:= ""
	Local nVlrLnc	:= 0
	Local cPlcCV	:= "" //Everson - 24/07/2019. Chamado 044314.
	Local aError	:= {} //Everson - 05/11/2019 - Chamado 029058.

	//Everson - 05/11/2019 - Chamado 029058.
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}	

	//Everson - 05/11/2019. Chamado 029058.
	cTransPa  := Posicione("ZV4",1,FWxFilial("ZV4")  + cPlaca,"ZV4_FORNEC")
	cLojaPa	  := Posicione("ZV4",1,FWxFilial("ZV4")  + cPlaca,"ZV4_LOJFOR")
	cNmTpa    := Posicione("ZV4",1,FWxFilial("ZV4")  + cPlaca,"ZV4_NOMFOR")
	cTabFrt	  := Posicione("ZV4",1,FWxFilial("ZV4") + cPlaca,"ZV4_XFRET")

	//
    nVlrEnt   := Posicione("ZF5",1,FWxFilial("ZF5") + cTabFrt,"ZF5_VLDVEN")
	
	//Verifica se a carga lançada.
	DbSelectArea("ZFA")
	If ! Empty(cCarga)
		ZFA->(DbSetOrder(1))
		ZFA->(DbGoTop())
		If ZFA->(DbSeek( xFilial("ZFA") + cCarga ))
			
			//
			dDTEntr	:= ZFA->ZFA_DTENTR
			cRoteir	:= ZFA->ZFA_ROTEIR
			nNumEnt	:= ZFA->ZFA_NUMENT
			cTpCarga:= ZFA->ZFA_VA
			cVeiculo:= ZFA->ZFA_VEICUL
			cTransp	:= ZFA->ZFA_TRANSP
			cLjTran	:= ZFA->ZFA_LOJTRA
			cNmTran	:= ZFA->ZFA_NMTRAN
			nTotKm	:= ZFA->ZFA_KMTOT
			nVlrPdg	:= ZFA->ZFA_VLRPDG
			nTotKg	:= ZFA->ZFA_CARKG
			nTotCx	:= ZFA->ZFA_CARCX
			nTotBr	:= ZFA->ZFA_KGBT	
			cTbFrt	:= ZFA->ZFA_TABFRT
			cDscFrt	:= ZFA->ZFA_DSCFRT
			cTpFrt	:= ZFA->ZFA_TPFRT
			cPlcCV	:= ZFA->ZFA_PLCCAV //Everson - 24/07/2019. Chamado 044314.
			
		EndIf
		
	EndIf
	
	//
	nVlrLnc := nVlr + Iif(cTpDev = "T", nVlrEnt,0)

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG047P - cCarga - grvZFA " + cValToChar(cCarga) )

	//
	Begin Transaction

		//Everson - 05/11/2019. Chamado 029058.
		oModel:= FwLoadModel ("ADLOG040P")
		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue("ZFAMASTER","ZFA_VA"		,"1") //Everson - 27/11/2019 - Chamado 029085.
		oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A") //Everson - 27/11/2019 - Chamado 029085.
		oModel:SetValue("ZFAMASTER","ZFA_CARGA"	  	,cCarga)
		oModel:SetValue("ZFAMASTER","ZFA_DTENTR"	,dDTEntr)
		oModel:SetValue("ZFAMASTER","ZFA_ROTEIR"	,cRoteir)
		oModel:SetValue("ZFAMASTER","ZFA_NUMENT"	,nNumEnt)
		oModel:SetValue("ZFAMASTER","ZFA_VA"		,cTpCarga)
		oModel:SetValue("ZFAMASTER","ZFA_VEICUL"	,cVeiculo)
		oModel:SetValue("ZFAMASTER","ZFA_TRANSP"	,cTransp)
		oModel:SetValue("ZFAMASTER","ZFA_LOJTRA"	,cLjTran)
		oModel:SetValue("ZFAMASTER","ZFA_NMTRAN"	,cNmTran)
		oModel:SetValue("ZFAMASTER","ZFA_KMTOT"		,nTotKm)
		oModel:SetValue("ZFAMASTER","ZFA_VLRPDG"	,nVlrPdg)
		oModel:SetValue("ZFAMASTER","ZFA_CARKG"		,nTotKg)
		oModel:SetValue("ZFAMASTER","ZFA_CARCX"		,nTotCx)
		oModel:SetValue("ZFAMASTER","ZFA_KGBT"		,nTotBr)
		oModel:SetValue("ZFAMASTER","ZFA_TABFRT"	,cTbFrt)
		oModel:SetValue("ZFAMASTER","ZFA_DSCFRT"	,cDscFrt)
		oModel:SetValue("ZFAMASTER","ZFA_TPFRT"		,cTpFrt)

		//
		oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,Date())
		oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,sCodOdev)
		oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,sDscOcos)
		oModel:SetValue("ZFAMASTER","ZFA_DC"		,sTpOcorr)
		oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,cPlaca)
		oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,cTransPa)
		oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,cLojaPa)
		oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,cNmTpa)		
		oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlrLnc)
		oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,cObs)

		//
		oModel:SetValue("ZFAMASTER","ZFA_PORDES"  	,nPercDes)
		oModel:SetValue("ZFAMASTER","ZFA_DESDEV"  	,cMemoDv)
		oModel:SetValue("ZFAMASTER","ZFA_VLDVEN"  	,Iif(cTpDev = "T", nVlrEnt,0))
		oModel:SetValue("ZFAMASTER","ZFA_NNFDEV"  	,cNota)
		oModel:SetValue("ZFAMASTER","ZFA_SNFDEV"  	,cSerie)
		
		//
		oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"N")
		oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
		oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
		oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
		oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
		oModel:SetValue("ZFAMASTER","ZFA_PLCCAV"	,cPlcCV)
		oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(1)) 
		oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"  	,"ADLOG047P")
			
		//
		If oModel:VldData()
			oModel:CommitData()

			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG047P - grvZFA - cCarga " + Alltrim(cValToChar(oModel:GetValue( "ZFAMASTER" , "ZFA_CARGA"    ))) )
			
		Else
			aError := oModel:GetErrorMessage()
			Conout( DToC(Date()) + " " + Time() + " ADLOG047P - grvZFA - Erro gravação de registro - aError ")
			Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
			Help(Nil, Nil, "Função IMPARQ(ADLOG040P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
			DisarmTransaction()
			MsUnlockAll()
			Break 

		EndIf      
	
	End Transaction
	
	//
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
	
	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} getQuery
	Script sql com os registros de lançamento de devolução. 
	@type  Static Function
	@author Everson
	@since  19/03/2019
	@version  01
	/*/ 
Static Function getQuery(cNota, cSerie)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaração de variáveis.                                            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	
	//
	cQuery := ""	
	cQuery += " SELECT   " 
	cQuery += " ZD_FILIAL, ZFD_COD, ZD_PLACA,  ZD_NUMNF, ZD_SERIE, ZD_DEVTOT, ZD_RESPNOM, ZD_DESCMOT, F2_VALMERC, D2_PEDIDO, D2_COD, ZX_DESCRIC, ZX_QTDE, D2_PRCVEN, ZX_QUEBRA, ZX_QUEBRA*D2_PRCVEN AS VLR_TOTQ " 
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("SZD") + "  (NOLOCK) AS SZD   " 
	cQuery += " INNER JOIN   " 
	cQuery += " (   " 
	cQuery += " SELECT  " 
	cQuery += " ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, ZX_DESCRIC, SUM(ZX_QUEBRA) AS ZX_QUEBRA, SUM(ZX_QTDE) AS ZX_QTDE, SUM(ZX_QTDEV2U) AS ZX_QTDEV2U    " 
	cQuery += " FROM    " 
	cQuery += " " + RetSqlName("SZX") + " (NOLOCK) AS SZX   " 
	cQuery += " WHERE     " 
	cQuery += " SZX.D_E_L_E_T_ = ''   " 
	cQuery += " GROUP BY   " 
	cQuery += " ZX_FILIAL, ZX_NF, ZX_SERIE, ZX_CODPROD, ZX_DESCRIC  " 
	cQuery += " ) AS SZX ON   " 
	cQuery += " ZD_FILIAL = SZX.ZX_FILIAL   " 
	cQuery += " AND ZD_NUMNF = SZX.ZX_NF   " 
	cQuery += " AND ZD_SERIE = SZX.ZX_SERIE   " 
	cQuery += " INNER JOIN  "
	cQuery += " " + RetSqlName("SF2") + " AS SF2 ON  " 
	cQuery += " ZD_FILIAL = F2_FILIAL  " 
	cQuery += " AND ZD_NUMNF = F2_DOC  " 
	cQuery += " AND ZD_SERIE = F2_SERIE  " 
	cQuery += " AND ZD_CODCLI = F2_CLIENTE  " 
	cQuery += " AND ZD_LOJA = F2_LOJA  " 
	cQuery += " LEFT OUTER JOIN " 
	cQuery += " " + RetSqlName("ZFD") + " AS ZFD ON " 
	cQuery += " ZD_FILIAL = ZFD_FILIAL " 
	cQuery += " AND ZD_NUMNF = ZFD_NUMNF " 
	cQuery += " AND ZD_SERIE = ZFD_SERIE " 
	cQuery += " AND ZD_PEDIDO = ZFD_PEDIDO " 
	cQuery += " INNER JOIN " 
	cQuery += " " + RetSqlName("SD2") + " (NOLOCK) AS SD2 ON " 
	cQuery += " ZX_FILIAL = D2_FILIAL " 
	cQuery += " AND ZX_NF = D2_DOC " 
	cQuery += " AND ZX_SERIE = D2_SERIE " 
	cQuery += " AND ZX_CODPROD = D2_COD " 
	cQuery += " WHERE    " 
	cQuery += " ZD_FILIAL = '" + FwFilial("SZD") + "'   " 
	cQuery += " AND ZD_NUMNF = '" + cNota + "'   " 
	cQuery += " AND ZD_SERIE = '" + cSerie + "'   " 
	cQuery += " AND ZD_DEVTOT IN ('Q','T')    " 
	cQuery += " AND ZD_RESPONS = '08' "
	cQuery += " AND SZD.D_E_L_E_T_ = ''   " 
	cQuery += " AND SF2.D_E_L_E_T_ = ''  " 
	cQuery += " AND ZFD.D_E_L_E_T_ = '' " 

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG047P - getQuery - cQuery " + cQuery )
	
	//
	RestArea(aArea)

Return cQuery