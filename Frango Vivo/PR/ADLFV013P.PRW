#Include "RWMAKE.CH"
#Include "TBICONN.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Topconn.ch"
/*/{Protheus.doc} User Function ADLFV013P
    Efetua o lanГamento de movimento de frete.
    @type  Function
    @author Everson
    @since 11/12/2019
    @version 01
    /*/

User Function ADLFV013P() // U_ADLFV013P()

 	Local aArea     := GetArea()
    Local aCampos   := {}
    Local oDialog   := Nil
    Local oFechar   := Nil
    Local oBrwTrb   := Nil
    Local lInverte  := .F.
    Local aCores    := {}
    Local nTotReg   := 0
    Local nTotRegL  := 0
    Local nTotRegB  := 0

    Private cMark	:= GetMark()
    Private cTemp   := ""
    Private oArq1   := Nil

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Efetua o lanГamento de movimento de frete.')
    
    //
    If ! Pergunte("ADLFV013P",.T.)
        RestArea(aArea)
        Return Nil

    EndIf

    //
    criArqTemp(@nTotReg,@nTotRegB,@nTotRegL)

    //
    Aadd(aCampos,{"TP_OK"	       , ,"",""})
    Aadd(aCampos,{"TM_FILIAL"      , ,"Filial",""})
    Aadd(aCampos,{"TM_FILORI"      , ,"Fil. Orig.",""})
    Aadd(aCampos,{"TM_NUM"         , ,"Ordem Carregamento",""})
    Aadd(aCampos,{"TM_GRAN"        , ,"Granja",""})
    Aadd(aCampos,{"TM_GALP"        , ,"GalpЦo",""})
    Aadd(aCampos,{"TM_DTABT"       , ,"Data Abate",""})
    Aadd(aCampos,{"TM_VEICUL"      , ,"VeМculo","" })
    Aadd(aCampos,{"TM_FRTVLR"      , ,"Frete","@E 999,999,999.99" } )
    Aadd(aCampos,{"TM_PESPRE"      , ,"Kg","@E 999,999,999.999" } )
    Aadd(aCampos,{"TM_TABFRT"      , ,"Tabela de frete",""})
    Aadd(aCampos,{"TM_DESFRT"      , ,"DescriГЦo tabela",""})
    Aadd(aCampos,{"TM_CODTRA"      , ,"Transportadora",""})
    Aadd(aCampos,{"TM_LJTRA"       , ,"Loja",""})
    Aadd(aCampos,{"TM_NMTRA"       , ,"Nome",""})
    Aadd(aCampos,{"TM_KM"          , ,"KM",""})
    Aadd(aCampos,{"TM_OCORR"       , ,"OcorrЙncia",""})
    Aadd(aCampos,{"TM_DOCORR"      , ,"Desc. Ocorr.",""})
    Aadd(aCampos,{"TM_TPOCO"       , ,"Tp. Ocorr.",""})
    Aadd(aCampos,{"TM_NFISCA"      , ,"Nota fiscal",""})
    Aadd(aCampos,{"TM_SERIE"       , ,"SИrie",""})

    //
    Aadd(aCores,{"(cTemp)->TM_LIB == '1'","BR_VERMELHO"	})
    Aadd(aCores,{"(cTemp)->TM_LIB == '2'","BR_VERDE"	})

    //
    oDialog			  := MsDialog():Create()
    oDialog:cName     := "oInterface"
    oDialog:cCaption  := "LanГamento de ocorrЙncia de frete de frango vivo"
	oDialog:nLeft     := 34
	oDialog:nTop      := 222
	oDialog:nWidth    := 1200
	oDialog:nHeight   := 550
	oDialog:lShowHint := .F.
    oDialog:lCentered := .T.

        //
        TGet():New(005,005,{|u| if( PCount() > 0, nTotReg  := u, nTotReg  ) } ,oDialog,50,009,"@ 999.999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotReg" ,,,,,,,"Total Registros" ,1)
        TGet():New(005,060,{|u| if( PCount() > 0, nTotRegL := u, nTotRegL ) } ,oDialog,50,009,"@ 999.999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotRegL",,,,,,,"Total Liberados" ,1)
        TGet():New(005,115,{|u| if( PCount() > 0, nTotRegB := u, nTotRegB ) } ,oDialog,50,009,"@ 999.999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"nTotRegB",,,,,,,"Total Bloqueados",1)
 
        //
        oBrwTrb := MsSelect():New(cTemp,"TP_OK","",aCampos,@lInverte,@cMark,{030,005,240,595}, , , oDialog,,aCores)

        Eval(oBrwTrb:oBrowse:bGoTop)

        //
        //TButton():New(245,005,"Atualizar"             ,oDialog,{|| Processa({|| criArqTemp(@nTotReg,@nTotRegB,@nTotRegL),oBrwTrb:oBrowse:Refresh(), oDialog:Refresh() },'Aguarde','Atualizando registros...',.F.) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        TButton():New(245,505,"Gerar Frete"           ,oDialog,{|| Processa({|| gerFrt() },'Aguarde','Processando registros...',.F.), oDialog:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
        oFechar	 := TButton():New(245,550,"Fechar"    ,oDialog,{||oDialog:End()},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
            oFechar:SetCss("QPushButton{background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #FF0000, stop: 1 #8C1717);color: white}")	

    oDialog:Activate()

    //
    (cTemp)->(DbCloseArea())

    //
    oArq1:Delete()

	//
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} gerFrt
	Gera registro de movimento de frete na tabela ZFA. Chamado 029058.
	@type  Static Function
	@author Everson
	@since 03/12/2019
	@version 01
	/*/
Static Function gerFrt()

 	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё DeclaraГЦo de variАveis.                                            |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    Local aArea     := GetArea()
    Local aError    := {}
    Local cFilBck	:= cFilAnt	
    Local nTotLn    := 0

	//
	Private oModel 		:= Nil
    Private lMsErroAuto := .F.
    
    //
    DbSelectArea(cTemp)
    (cTemp)->(DbGoTop())
    nTotLn := Contar(cTemp,"!Eof()")
    ProcRegua(nTotLn)
    (cTemp)->(DbGoTop())
    While ! (cTemp)->(Eof())

        //
        IncProc( (cTemp)->TM_NUM + " | " + (cTemp)->TM_VEICUL )

        //
        If ! Empty(Alltrim((cTemp)->TP_OK)) .And. Alltrim((cTemp)->TM_LIB) = "2"

            //
            cFilAnt := Alltrim((cTemp)->TM_FILORI)

            //
            oModel:= FwLoadModel ("ADLOG040P")
            oModel:SetOperation(MODEL_OPERATION_INSERT)
            oModel:Activate()
            oModel:SetValue("ZFAMASTER","ZFA_VA"		,"2")
            oModel:SetValue("ZFAMASTER","ZFA_TPMOV"  	,"A")
            oModel:SetValue("ZFAMASTER","ZFA_CARGA"	  	,(cTemp)->TM_NUM)
            oModel:SetValue("ZFAMASTER","ZFA_DTENTR"	,MV_PAR01)
            oModel:SetValue("ZFAMASTER","ZFA_ROTEIR"	,(cTemp)->TM_NUM)
            oModel:SetValue("ZFAMASTER","ZFA_NUMENT"	,1)
            oModel:SetValue("ZFAMASTER","ZFA_VEICUL"	,Alltrim(cValToChar((cTemp)->TM_VEICUL)))
            oModel:SetValue("ZFAMASTER","ZFA_TRANSP"	,(cTemp)->TM_CODTRA)
            oModel:SetValue("ZFAMASTER","ZFA_LOJTRA"	,(cTemp)->TM_LJTRA)
            oModel:SetValue("ZFAMASTER","ZFA_NMTRAN"	,(cTemp)->TM_NMTRA)
            oModel:SetValue("ZFAMASTER","ZFA_KMTOT"		,(cTemp)->TM_KM)
            oModel:SetValue("ZFAMASTER","ZFA_CARKG"		,(cTemp)->TM_PESPRE)
            oModel:SetValue("ZFAMASTER","ZFA_KGBT"		,(cTemp)->TM_PESPRE)
            oModel:SetValue("ZFAMASTER","ZFA_TABFRT"	,(cTemp)->TM_TABFRT)
            oModel:SetValue("ZFAMASTER","ZFA_DSCFRT"	,(cTemp)->TM_DESFRT)
            oModel:SetValue("ZFAMASTER","ZFA_TPFRT"		,"C")
            oModel:SetValue("ZFAMASTER","ZFA_DATA"	  	,MV_PAR01)
            oModel:SetValue("ZFAMASTER","ZFA_OCORRE"  	,(cTemp)->TM_OCORR)
            oModel:SetValue("ZFAMASTER","ZFA_DESCOC"  	,(cTemp)->TM_DOCORR)
            oModel:SetValue("ZFAMASTER","ZFA_DC"		,(cTemp)->TM_TPOCO)
            oModel:SetValue("ZFAMASTER","ZFA_VEICPG"   	,Alltrim(cValToChar((cTemp)->TM_VEICUL)))
            oModel:SetValue("ZFAMASTER","ZFA_TRANPA"	,(cTemp)->TM_CODTRA)
            oModel:SetValue("ZFAMASTER","ZFA_LJPPAG"  	,(cTemp)->TM_LJTRA)
            oModel:SetValue("ZFAMASTER","ZFA_NMTPAG"  	,(cTemp)->TM_NMTRA)
            oModel:SetValue("ZFAMASTER","ZFA_VALOR"  	,(cTemp)->TM_FRTVLR)
            oModel:SetValue("ZFAMASTER","ZFA_APRMOV"  	,"S")
            oModel:SetValue("ZFAMASTER","ZFA_FECHA"  	,"N")
            oModel:SetValue("ZFAMASTER","ZFA_DATAIN"  	,Date())
            oModel:SetValue("ZFAMASTER","ZFA_HORA"  	,Time())
            oModel:SetValue("ZFAMASTER","ZFA_USUARI"  	,cUserName)
            oModel:SetValue("ZFAMASTER","ZFA_TPBLQF"  	,U_ADLG40I(2)) 
            oModel:SetValue("ZFAMASTER","ZFA_ORIGEM"	,"ADLFV013P")
            
            oModel:SetValue("ZFAMASTER","ZFA_GUIA"   	,"")
            oModel:SetValue("ZFAMASTER","ZFA_HCHEG"	 	,"")
            oModel:SetValue("ZFAMASTER","ZFA_KMENT"  	,0)
            oModel:SetValue("ZFAMASTER","ZFA_KMSAI"  	,0)
            
            //
            If oModel:VldData()
                oModel:CommitData()
                
            Else
                aError := oModel:GetErrorMessage()
                Conout( DToC(Date()) + " " + Time() + " ADLFV013P - ERRO - GetErrorMessage " )
                Conout( aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION] )
                Help(Nil, Nil, "FunГЦo ADLFV013P(ADLFV013P)", Nil,  aError[MODEL_MSGERR_MESSAGE]+"/"+aError[MODEL_MSGERR_SOLUCTION], 1, 0, Nil, Nil, Nil, Nil, Nil, {""})

            EndIf 
            
            //
            oModel:DeActivate()
            oModel:Destroy()
            oModel := Nil

        EndIf

        //
        (cTemp)->(DbSkip())
    
    End

    //
    cFilAnt := cFilBck

	//
    RestArea(aArea)

Return Nil

Static Function criArqTemp(nTotReg,nTotRegB,nTotRegL)
     
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё DeclaraГЦo de variАveis.                                            |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    Local aArea     := GetArea()
    Local aEstru    := {}
    Local cQuery    := ""
    Local cOcorre	:= Alltrim(GetMv("MV_#FRETFV",,"001"))
	Local cDescOcor	:= Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre,"ZF7_DESC")
    Local cDCOcor	:= Posicione("ZF7",1,FWxFilial("ZF7") + cOcorre,"ZF7_DBCD")

    Default nTotReg := 0
    Default nTotRegB:= 0
    Default nTotRegL:= 0

    //
    nTotReg   := 0
    nTotRegL  := 0
    nTotRegB  := 0

    //
    Aadd(aEStru,{"TP_OK"     ,"C",   2,0})
    Aadd(aEStru,{"TM_FILIAL" ,"C",TamSX3("ZFC_FILIAL")[1]  ,0})
    Aadd(aEStru,{"TM_FILORI" ,"C",TamSX3("ZFC_FILIAL")[1]  ,0})
    Aadd(aEStru,{"TM_NUM"    ,"C",TamSX3("ZFC_NUMERO")[1]  ,0})
    Aadd(aEStru,{"TM_GRAN"   ,"C",TamSX3("ZFC_GRANJA")[1]  ,0})
    Aadd(aEStru,{"TM_GALP"   ,"C",TamSX3("ZFC_GALPAO")[1]  ,0})
    Aadd(aEStru,{"TM_DTABT"  ,"D",TamSX3("ZFC_DTAPRE")[1]  ,0})
    Aadd(aEStru,{"TM_VEICUL" ,"C",TamSX3("ZFC_VEICUL")[1]  ,0})
    Aadd(aEStru,{"TM_FRTVLR" ,"N",TamSX3("ZFC_FRTVLR")[1]  ,TamSX3("ZFC_FRTVLR")[2]})
    Aadd(aEStru,{"TM_PESPRE" ,"N",TamSx3("ZFC_PESPRE")[1]  ,TamSx3("ZFC_PESPRE")[2]})
    Aadd(aEStru,{"TM_TABFRT" ,"C",TamSX3("DA3_XFRET")[1]   ,0})
    Aadd(aEStru,{"TM_DESFRT" ,"C",TamSX3("ZF5_TABDES")[1]  ,0})
    Aadd(aEStru,{"TM_CODTRA" ,"C",TamSX3("A4_COD")[1]      ,0})
    Aadd(aEStru,{"TM_LJTRA"  ,"C",TamSX3("A4_LOJTRA")[1]   ,0})
    Aadd(aEStru,{"TM_NMTRA"  ,"C",TamSX3("A4_NOME")[1]     ,0})
    Aadd(aEStru,{"TM_KM"     ,"N",TamSX3("ZF4_KM")[1]      ,TamSX3("ZF4_KM")[2]})
    Aadd(aEStru,{"TM_OCORR"  ,"C",TamSX3("ZF7_CODIGO")[1]  ,0})
    Aadd(aEStru,{"TM_DOCORR" ,"C",TamSX3("ZF7_DESC")[1]    ,0})
    Aadd(aEStru,{"TM_TPOCO"  ,"C",TamSX3("ZF7_DBCD")[1]    ,0})
    Aadd(aEStru,{"TM_NFISCA" ,"C",TamSX3("ZFC_NF")[1]      ,0})
    Aadd(aEStru,{"TM_SERIE"  ,"C",TamSX3("ZFC_SERIE")[1]   ,0})
    Aadd(aEStru,{"TM_LIB"  ,"C",1  ,0})

    //
    cTemp := GetNextAlias()
    oArq1 :=  FWTemporaryTable():New(cTemp)
    oArq1:SetFields(aEStru)
    oArq1:Create()

    //
    cQuery := scriptSql()

    //
    If Select("D_ZFC") > 0
        D_ZFC->(DbCloseArea())

    EndIf

    //
    TcQuery cQuery New Alias "D_ZFC"
    DbSelectArea("D_ZFC")
    D_ZFC->(DbGoTop())
    nTotReg := Contar("D_ZFC","!Eof()")
    D_ZFC->(DbGoTop())

    //
    While ! D_ZFC->(Eof())

        //
        RecLock(cTemp,.T.)
            (cTemp)->TP_OK     := cMark
            (cTemp)->TM_FILIAL := FWxFilial("ZFC")
            (cTemp)->TM_FILORI := D_ZFC->ZFC_FILORI
            (cTemp)->TM_NUM    := D_ZFC->ZFC_NUMERO
            (cTemp)->TM_GRAN   := D_ZFC->ZFC_GRANJA
            (cTemp)->TM_GALP   := D_ZFC->ZFC_GALPAO
            (cTemp)->TM_DTABT  := SToD(D_ZFC->ZFC_DTAPRE)
            (cTemp)->TM_VEICUL := D_ZFC->ZFC_VEICUL
            (cTemp)->TM_FRTVLR := D_ZFC->ZFC_FRTVLR
            (cTemp)->TM_PESPRE := D_ZFC->ZFC_PESPRE
            (cTemp)->TM_TABFRT := D_ZFC->DA3_XFRET
            (cTemp)->TM_DESFRT := D_ZFC->ZF5_TABDES
            (cTemp)->TM_CODTRA := D_ZFC->A4_COD
            (cTemp)->TM_LJTRA  := D_ZFC->A4_LOJTRA
            (cTemp)->TM_NMTRA  := D_ZFC->A4_NOME
            (cTemp)->TM_KM     := D_ZFC->ZF4_KM
            (cTemp)->TM_OCORR  := cOcorre
            (cTemp)->TM_DOCORR := cDescOcor
            (cTemp)->TM_TPOCO  := cDCOcor
            (cTemp)->TM_NFISCA := D_ZFC->ZFC_NF 
            (cTemp)->TM_SERIE  := D_ZFC->ZFC_SERIE
            (cTemp)->TM_LIB    := Iif( Val(cValToChar(D_ZFC->ZFC_FRTVLR)) <= 0 .Or. Empty(Alltrim(D_ZFC->ZFC_NF)) .Or. Empty(Alltrim(D_ZFC->ZFC_SERIE)) ,"1","2")
        (cTemp)->(MsUnlock())

        //
        If Val(cValToChar(D_ZFC->ZFC_FRTVLR)) <= 0 .Or. Empty(Alltrim(D_ZFC->ZFC_NF)) .Or. Empty(Alltrim(D_ZFC->ZFC_SERIE)) 
            nTotRegB++
        Else 
            nTotRegL++

        EndIf

        //
        D_ZFC->(DbSkip())

    End

    //
    D_ZFC->(DbCloseArea())

    //
    RestArea(aArea)

Return Nil
/*/{Protheus.doc} scriptSql
    Script sql com os dados da carga.
    @type  Static Function
    @author Everson
    @since 03/12/2019
    @version 01
    /*/
Static Function scriptSql()

 	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё DeclaraГЦo de variАveis.                                            |
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    Local aArea     := GetArea()
    Local cQuery    := ""

    //
    cQuery := ""
    cQuery += " SELECT " 
    cQuery += " ZFC_FILORI, ZFC_NUMERO  " 
    cQuery += " ,ZFC_GRANJA, ZFC_GALPAO " 
    cQuery += " ,ZFC_DTAPRE, ZFC_VEICUL " 
    cQuery += " ,ZFC_FRTVLR, ZFC_PESPRE " 
    cQuery += " ,DA3_XFRET , ZF5_TABDES " 
    cQuery += " ,A4_COD    , A4_LOJTRA, A4_NOME  " 
    cQuery += " ,ISNULL(ZF4_KM,0) AS ZF4_KM " 
    cQuery += " ,ZFC_NF, ZFC_SERIE  "
    cQuery += " FROM  " 
    cQuery += " " + RetSqlName("ZFC") + " (NOLOCK) AS ZFC " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("DA3") + " (NOLOCK) AS DA3 ON " 
    cQuery += " ZFC_FILIAL = DA3_FILIAL " 
    cQuery += " AND ZFC_VEICUL = DA3_COD " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SA4") + " (NOLOCK) AS SA4 ON " 
    cQuery += " DA3_XTRANS = A4_COD " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("ZF5") + " (NOLOCK) AS ZF5 ON " 
    cQuery += " DA3_XFRET = ZF5_TABCOD " 
    cQuery += " INNER JOIN " 
    cQuery += " " + RetSqlName("SA2") + " (NOLOCK) AS SA2 ON " 
    cQuery += " A4_COD = A2_COD " 
    cQuery += " AND A4_LOJTRA = A2_LOJA " 
    cQuery += " LEFT OUTER JOIN " 
    cQuery += " " + RetSqlName("ZF4") + " (NOLOCK) AS ZF4 ON " 
    cQuery += " ZFC_GRANJA = ZF4_GRCOD " 
    cQuery += " LEFT OUTER JOIN "
    cQuery += " (SELECT ZFA_FILIAL, ZFA_CARGA FROM " + RetSqlName("ZFA") + " (NOLOCK) AS ZFA WHERE ZFA_VA = '2' AND D_E_L_E_T_ = '') AS ZFA ON " 
    cQuery += " ZFC_FILORI = ZFA_FILIAL "
    cQuery += " AND ZFC_NUMERO = ZFA_CARGA "
    cQuery += " WHERE " 
    cQuery += " ZFC_FILIAL = '" + FWxFilial("ZFC") + "' " 
    cQuery += " AND ZFC_DTAPRE = '" + DToS(MV_PAR01) + "' " 
    cQuery += " AND ZFA_CARGA IS NULL "
    cQuery += " AND ZFC.D_E_L_E_T_ = ''  " 
    cQuery += " AND DA3.D_E_L_E_T_ = '' " 
    cQuery += " AND SA4.D_E_L_E_T_ = '' " 
    cQuery += " AND ZF5.D_E_L_E_T_ = '' " 
    cQuery += " AND SA2.D_E_L_E_T_ = '' " 
    cQuery += " ORDER BY ZFC_NUMERO " 

    //
    Conout( DToC(Date()) + " " + Time() + " ADLFV013P - scriptSql - cQuery - cQuery " + cQuery )

    //
    RestArea(aArea)

Return cQuery