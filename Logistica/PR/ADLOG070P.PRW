#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "FwMvcDef.ch"
/*/{Protheus.doc} User Function ADLOG070P
    Rotina para lançamento e estorno de desconto de co-participação no seguro de carga.
	Chamado 058332.
    @type  Function
    @author Everson
    @since 25/06/2020
    @version 01
	@history Everson, 02/09/2020, Chamado 798. Tratamento para error log referente ao campo ZFA_IDABAS.
    /*/
User Function ADLOG070P(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    //Variáveis.
    Local aArea := GetArea()

    //
    If nOpc == 1
        lancaDes(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    ElseIf nOpc == 2
        estorDes(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    EndIf

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} lancaDes
    Processo lançamento do desconto.
    @type  Static Function
    @author Everson
    @since 25/06/2020
    @version 01
    /*/
Static Function lancaDes(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    //Variáveis.
	Local aArea		:= GetArea()
	Local cQuery   	:= ""
    Local cOcorSg   := GetMv("MV_#DESSEG",,"118")
	Local cDscOcos	:= ""
	Local cTpOcorr	:= ""
	Local cPlaca	:= ""
	Local nVlrT		:= 0
	Local nTotReg	:= 0
    Local cTpBlq    := U_ADLG40I(nTpFrtS)

	//
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	//
	If ! estorDes(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)
		MsgStop("Não foi possível realizar os estornos dos lançamentos de desconto de seguro de carga.","Função lancaDes(ADLOG070P)")
		RestArea(aArea)
		Return Nil

	EndIf

	//
	cDscOcos := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorSg, "ZF7_DESC" )))
	cTpOcorr := Alltrim(cValToChar(Posicione("ZF7",1, FWxFilial("ZF7") + cOcorSg, "ZF7_DBCD" )))

	//
	cQuery := sqlInSeg(dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

	//
	If Select("DESCSEG") > 0
		DESCSEG->(DbCloseArea())

	EndIf

	//Everson - 06/12/2019 - Chamado 029058.
	TcQuery cQuery New Alias "DESCSEG"
	DbSelectArea("DESCSEG")
	DESCSEG->(DbGoTop())
	nTotReg := Contar("DESCSEG","!Eof()")
	If nTotReg <= 0
		MsgInfo("Não há registros seguro a serem importados.","Função lancaDes(ADLOG070P)")
		DESCSEG->(DbCloseArea())
		RestArea(aArea)
		Return Nil
		
	EndIf
	DESCSEG->(DbGoTop())

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG070P - lancaDes - " + cValToChar(nTotReg) )

	//
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função lancaDes(ADLOG070P)")
		final()

	EndIf  

    //
    DbSelectArea("SA4")
    SA4->(DbSetOrder(1))

	//
	Begin Transaction

		//	
		While ! DESCSEG->(Eof())

			//
			IncProc() 

			//
			cPlaca := DESCSEG->F2_PLACA
			nVlrT  := Round(DESCSEG->F2_XVLCOPA,2)

            //
            SA4->(DbGoTop())
            If ! SA4->(DbSeek( FWxFilial("SA4") + DESCSEG->F2_TRANSP ))
				Conout( DToC(Date()) + " " + Time() + " ADLOG070P - lancaDes - transportadora " + cValToChar(DESCSEG->F2_TRANSP) + " não encontrada no cadastro de transportadoras.")
                MsgStop("Transportadora " + cValToChar(DESCSEG->F2_TRANSP) + " não encontrada no cadastro de transportadoras.","Função lancaDes(ADLOG070P)")
                DESCSEG->(DbSkip())
                Loop

            EndIf

            //
            cTransp := SA4->A4_COD
            cLoja   := SA4->A4_LOJTRA
            cNmTrp  := SA4->A4_NOME

			//
			Conout( DToC(Date()) + " " + Time() + " ADLOG070P - lancaDes - " + cPlaca + " " + cTransp + " " + cLoja + " " + cNmTrp + " " + cValToChar(nVlrT))

			//
			oModel:= FwLoadModel ("ADLOG040P")
			oModel:SetOperation(MODEL_OPERATION_INSERT)
			oModel:Activate()
				
			//
			oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,dDtAte)
			oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,cOcorSg)
			oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,cDscOcos)
			oModel:SetValue("ZFAMASTER","ZFA_DC"		,cTpOcorr)
			oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,cPlaca)
			oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,cTransp)
			oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,cLoja)
			oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,cNmTrp)
			oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,nVlrT)
			oModel:SetValue("ZFAMASTER","ZFA_OBSERV"  	,"Desconto de co-participação de seguro de carga de " + DToC(dDtDe) + " até " + DToC(dDtAte))
			oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
			oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N") 
			oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
			oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
			oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
			oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,RetCodUsr ())
			oModel:SetValue("ZFAMASTER","ZFA_VA"		,Alltrim(cValToChar( nTpFrtS )))
			oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,cTpBlq) 
			oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLOG070P")

			//
			If oModel:VldData()
				oModel:CommitData()

			Else
				aError := oModel:GetErrorMessage()
				Help(Nil, Nil, "Função lancaDes(ADLOG070P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] + ;
								cValToChar(DESCSEG->F2_PLACA), 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
				DisarmTransaction()
				Break

			EndIf					

            //
			oModel:DeActivate()
			oModel:Destroy()
			oModel := Nil

			//
			DESCSEG->(DbSkip())

		End

	//
	End Transaction

	//
	DESCSEG->(DbCloseArea())

	//
	RestArea(aArea)

Return Nil
/*/{Protheus.doc} sqlInSeg
    Script sql com os valores de desconto.
    @type  Static Function
    @author Everson
    @since 25/06/2020
    @version 01
    /*/
Static Function sqlInSeg(dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    //Variáveis.
    Local cQuery := ""

    //
    cQuery += " SELECT F2_TRANSP, F2_PLACA, " 
    cQuery += " SUM(F2_XVLCOPA) AS F2_XVLCOPA, " 
    cQuery += " CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END AS F2_XCC " 
    cQuery += " FROM " 
    cQuery += " " + RetSqlName("SF2") + " (NOLOCK) AS SF2 " 
    cQuery += " WHERE  " 
    cQuery += " F2_FILIAL = '" + FWxFilial("SF2") + "' " 
    cQuery += " AND F2_EMISSAO BETWEEN '" + DToS(dDtDe) + "' AND '" + DToS(dDtAte) + "' " 
    cQuery += " AND F2_PLACA  BETWEEN '" + cPlacDe + "' AND '" + cPlacAte + "' " 
	cQuery += " AND F2_TRANSP BETWEEN '" + cTranDe + "' AND '" + cTranAte + "' "
    cQuery += " AND F2_PLACA   <> '' " 
    cQuery += " AND F2_TPFRETE  = 'C' " 
    cQuery += " AND F2_TIPO    <> 'D' " 
    cQuery += " AND D_E_L_E_T_ <> '*' " 
    cQuery += " GROUP BY  " 
    cQuery += " F2_TRANSP, F2_PLACA, " 
    cQuery += " CASE WHEN F2_EST = 'SP' THEN '6110' ELSE '6210' END " 
    cQuery += " ORDER BY F2_PLACA "

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG070P - sqlInSeg - cQuery " + cQuery ) 

Return cQuery 
/*/{Protheus.doc} estorDes
    Estorna lançamentos 
    @type  Static Function
    @author Everson
    @since 25/06/2020
    @version 01
    /*/
Static Function estorDes(nTpFrtS,nOpc,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte)

    //Variáveis.
	Local aArea		:= GetArea()
	Local cOcorSg   := GetMv("MV_#DESSEG",,"118")
	Local lRet 		:= .T.
	Local cQuery	:= ""
	Local nTotReg	:= 0

	//
	Private oModel 		:= Nil
	Private lMsErroAuto := .F.
	Private aRotina 	:= {}

	//
	If nOpc == 2 .And. ! MsgYesNo("Deseja realizar o estorno dos registros de desconto de seguro?","Função estorDes(ADLOG070P)")
		RestArea(aArea)
		Return .F.

	EndIf

	//
	cQuery := sqlExSeg(nTpFrtS,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte,cOcorSg)

	//
	Conout( DToC(Date()) + " " + Time() + " ADLOG070P - estorDes - cQuery " + cQuery )

	//
	If Select("D_ESTSG") > 0
		D_ESTSG->(DbCloseArea())

	EndIf

	//
	TcQuery cQuery New Alias "D_ESTSG"
	DbSelectArea("D_ESTSG")
	D_ESTSG->(DbGoTop())
	nTotReg := Contar("D_ESTSG","!Eof()")

	//
	If nTotReg <= 0

		//
		If nOpc == 2
			MsgInfo("Não há registros de desconto a serem estornados.","Função estorDes(ADLOG070P)")
			
		EndIf
		D_ESTSG->(DbCloseArea())
		RestArea(aArea)
		Return .T.

	EndIf

	//
	D_ESTSG->(DbGoTop())
	DbSelectArea("ZFA")
	ZFA->(DbSetOrder(13))
	ZFA->(DbGoTop())

	//
	If InTransact() .Or. FwInTTSBreak()
		MsgStop("Sistema está em transação ou TTSBreak - abortando operação.","Função estorDes(ADLOG070P)")
		final()

	EndIf                                                                                                                                                                                                                                                                                                                    

	//
	Begin Transaction

		//
		While ! D_ESTSG->(Eof())

			//
			If ZFA->( DbSeek( FWxFilial("ZFA") + Alltrim(D_ESTSG->ZFA_COD) ) )

				//
				oModel:= FwLoadModel ("ADLOG040P")
				oModel:SetOperation( MODEL_OPERATION_DELETE )
				oModel:Activate()

				//
				If oModel:VldData()
					oModel:CommitData()

				Else
					lRet := .F.
					aError := oModel:GetErrorMessage()
					Help(Nil, Nil, "Função estorDes(ADLOG070P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""}) //Everson - 02/09/2020. Chamado 798.
					DisarmTransaction()
					Break

				EndIf					

				oModel:DeActivate()
				oModel:Destroy()
				
				oModel := Nil

			EndIf 

			D_ESTSG->(DbSkip())

		End

	End Transaction

	//
	D_ESTSG->(DbCloseArea())

	//
	RestArea(aArea)

Return lRet
/*/{Protheus.doc} sqlExSeg
	Script sql com os valores de desconto.
	@type  Static Function
	@author Everson
	@since 25/06/2020
	@version 01
	/*/
Static Function sqlExSeg(nTpFrtS,dDtDe,dDtAte,cTranDe,cTranAte,cPlacDe,cPlacAte,cOcorSg)

	//Variáveis
	Local cQuery := ""

	//
	cQuery += " SELECT ZFA_COD " 
	cQuery += " FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA " 
	cQuery += " WHERE " 
	cQuery += " ZFA_FILIAL = '" + FWxFilial("ZFA") + "' " 
	cQuery += " AND ZFA_DATA   BETWEEN '" + DToS(dDtDe)	     + "' AND '" + DToS(dDtAte)	     + "' "
	cQuery += " AND ZFA_TRANPA BETWEEN '" + Alltrim(cTranDe) + "' AND '" + Alltrim(cTranAte) + "' "
	cQuery += " AND ZFA_VEICPG BETWEEN '" + Alltrim(cPlacDe) + "' AND '" + Alltrim(cPlacAte) + "' " 
	cQuery += " AND ZFA_OCORRE = '" + cOcorSg + "' AND ZFA_FECHA <> 'S' AND ZFA_TPMOV = 'A' " 
	cQuery += " AND RTRIM(LTRIM(ZFA_VA)) = '" + Alltrim(cValToChar(nTpFrtS)) + "' "
	cQuery += " AND D_E_L_E_T_ = '' ORDER BY ZFA_COD "

Return cQuery
