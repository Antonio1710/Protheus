#Include "Protheus.ch"
#Include "Topconn.ch"
#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} User Function ADCON020R
    Relatório AgriStats.
    @type  Function
    @author Antonio Florêncio
    @since 17/05/2022
    @version 01
    @Ticket 7290  - 18/05/2022 -Solicitado por Danielle Meira .
/*/
User Function ADCON020R() // U_ADCON020R()

    //Variáveis.
    Local aArea := GetArea()
    Local aPergs:= {}
    Local aRet  := {}

    //
    Aadd(aPergs,{1,"Data de",ddatabase,"" ,'.T.',,'.T.',80,.F.})
    Aadd(aPergs,{1,"Data Ate",ddatabase,"" ,'.T.',,'.T.',80,.T.})
	Aadd(aPergs,{1,"Cta Debito de" ,Space(TAMSX3("CT2_DEBITO")[1]),"" ,'.T.',"CT1",'.T.',50,.F.})
	Aadd(aPergs,{1,"Cta Debito Ate" ,Space(TAMSX3("CT2_DEBITO")[1]),"" ,'.T.',"CT1",'.T.',50,.T.})
	Aadd(aPergs,{1,"Cta Credito de" ,Space(TAMSX3("CT2_CREDIT")[1]),"" ,'.T.',"CT1",'.T.',50,.F.})
	Aadd(aPergs,{1,"Cta Credito Ate" ,Space(TAMSX3("CT2_CREDIT")[1]),"" ,'.T.',"CT1",'.T.',50,.T.})
    Aadd(aPergs,{1,"CCusto Debito de" ,Space(TAMSX3("CT2_CCD")[1]),"" ,'.T.',"CTT",'.T.',50,.F.})
	Aadd(aPergs,{1,"CCusto Debito Ate" ,Space(TAMSX3("CT2_CCD")[1]),"" ,'.T.',"CTT",'.T.',50,.T.})
    Aadd(aPergs,{1,"CCusto Credito de" ,Space(TAMSX3("CT2_CCC")[1]),"" ,'.T.',"CTT",'.T.',50,.F.})
	Aadd(aPergs,{1,"CCusto Credito Ate" ,Space(TAMSX3("CT2_CCC")[1]),"" ,'.T.',"CTT",'.T.',50,.T.})
	Aadd(aPergs,{1,"Lote de" ,Space(TAMSX3("CT2_XLTXCC")[1]),"" ,'.T.',,'.T.',50,.F.})
	Aadd(aPergs,{1,"Lote Ate" ,Space(TAMSX3("CT2_XLTXCC")[1]),"" ,'.T.',,'.T.',50,.T.})
    Aadd(aPergs,{6,"Local de Gravação",Space(50),"","","",50,.T.,"Todos os arquivos (*.*) |*.*","C:\TEMP\",GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE})
    //

    If ParamBox(aPergs ,"Parâmetros ",aRet,,,,,,,,.T.,.T.)
        Processa({|| geraRel(aRet[1],aRet[2],aRet[3],aRet[4],aRet[5],aRet[6],aRet[7],aRet[8],aRet[9],aRet[10],aRet[11],aRet[12],aRet[13]) },"Função ADCON020R(ADCON020R)","Gerando relatório",.F.)
    EndIf

    //
    RestArea(aArea)

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),' Relatório Razão por Lote')


Return Nil
/*/{Protheus.doc} processa
    Processa o relatório.
    @type  Static Function
    @author Antonio Florêncio
    @since 17/05/2022
    @version 01
    /*/
Static Function geraRel(dDataDe,dDataAte,cCta_DebDe,cCta_DebAte,cCta_CredDe,cCta_CredAte,cCC_DebDe,cCC_DebAte,cCC_CredDe,cCC_CredAte,cLoteDe,cLoteAte,cDiret)

    //Variáveis.
    Local aArea     := GetArea()
    Local oExcel    := objExcel()
    Local cAliasD   := GetNextAlias()
    Local cArq      := "rel_Raz_lote_" + RetCodUsr() + "_" + DToS(Date()) + "_" + StrTran(Time(),":","_") + "_.xml"
    Local cDCDEB    := "1"
    Local cDCCRE    := "2"
    LOCAL cDCDOB    := "3"
    Local oExcelApp := Nil

     If Select(cAliasD) > 0
      (cAliasD)->(dbCloseArea())
    Endif
    cAliasD:=GetNextAlias()

    BeginSQL  Alias cAliasD
		SELECT 
            CT2_DATA,CT2_DEBITO AS CONTA,CT2_CCD AS CC , CT2_ITEMD AS ITEM, CT2_HIST, 
			CT2_XLTXCC, CT2_XDLXCC, 
			CT2_VALOR AS VALOR, 
            CT1_DESC01, CTD_DESC01, CTT_DESC01
        FROM 
        %TABLE:CT2% CT2D
        LEFT OUTER JOIN %TABLE:CT1% CT1
            ON CT1.CT1_FILIAL = %xFilial:CT1%
            AND CT1_CONTA = CT2D.CT2_DEBITO
            AND CT1.%notDel%
        LEFT OUTER JOIN %TABLE:CTT% CTT
            ON CTT.CTT_FILIAL = %xFilial:CTT%
            AND CTT_CUSTO = CT2D.CT2_CCD
            AND CTT.%notDel%
        LEFT OUTER JOIN %TABLE:CTD% CTD
            ON CTD.CTD_FILIAL = %xFilial:CTD%
            AND CTD_ITEM = CT2D.CT2_ITEMD
            AND CTD.%notDel%
        WHERE 
            CT2D.CT2_FILIAL = %xFilial:CT2%
            AND CT2D.CT2_DATA >= %Exp:dDataDe%
            AND CT2D.CT2_DATA <= %Exp:dDataAte%
            AND CT2D.CT2_DEBITO >= %Exp:cCta_DebDe%
            AND CT2D.CT2_DEBITO <= %Exp:cCta_DebAte%
            AND CT2D.CT2_CCD >= %Exp:cCC_DebDe%
            AND CT2D.CT2_CCD <= %Exp:cCC_DebAte%
            AND CT2D.CT2_XLTXCC >= %Exp:cLoteDe%
            AND CT2D.CT2_XLTXCC <= %Exp:cLoteAte%
            AND (CT2D.CT2_DC = %Exp:cDCDEB% OR CT2D.CT2_DC = %Exp:cDCDOB%)
            AND CT2D.%notDel%
        UNION ALL
		SELECT 
            CT2_DATA,CT2_CREDIT AS CONTA,CT2_CCC AS CC , CT2_ITEMD AS ITEM, CT2_HIST, 
			CT2_XLTXCC, CT2_XDLXCC, 
			(CT2_VALOR*-1) AS VALOR, 
            CT1_DESC01, CTD_DESC01, CTT_DESC01
        FROM 
        %TABLE:CT2% CT2C
        LEFT OUTER JOIN %TABLE:CT1% CT1
            ON CT1.CT1_FILIAL = %xFilial:CT1%
            AND CT1_CONTA = CT2C.CT2_CREDIT
            AND CT1.%notDel%
        LEFT OUTER JOIN %TABLE:CTT% CTT
            ON CTT.CTT_FILIAL = %xFilial:CTT%
            AND CTT_CUSTO = CT2C.CT2_CCC
            AND CTT.%notDel%
        LEFT OUTER JOIN %TABLE:CTD% CTD
            ON CTD.CTD_FILIAL = %xFilial:CTD%
            AND CTD_ITEM = CT2C.CT2_ITEMC
            AND CTD.%notDel%
        WHERE 
            CT2C.CT2_FILIAL = %xFilial:CTD%
            AND CT2C.CT2_DATA >= %Exp:dDataDe%
            AND CT2C.CT2_DATA <= %Exp:dDataAte%
            AND CT2C.CT2_CREDIT >= %Exp:cCta_CredDe%
            AND CT2C.CT2_CREDIT <= %Exp:cCta_CredAte%
            AND CT2C.CT2_CCC >= %Exp:cCC_CredDe%
            AND CT2C.CT2_CCC <= %Exp:cCC_CredAte%
            AND CT2C.CT2_XLTXCC >= %Exp:cLoteDe%
            AND CT2C.CT2_XLTXCC <= %Exp:cLoteAte%
            AND (CT2C.CT2_DC = %Exp:cDCCRE% OR CT2C.CT2_DC = %Exp:cDCDOB%)
            AND CT2C.%notDel%
    EndSQL

    DbSelectArea(cAliasD)
    If !(cAliasD)->(Eof())
        (cAliasD)->(DbGoTop())
        While !(cAliasD)->(eof())

            //
            IncProc("Conta "+(cAliasD)->CONTA)

            If (cAliasD)->VALOR < 0
                oExcel:SetCelFrColor("#FF0000")

            Else
                oExcel:SetCelFrColor("#000000")

            EndIf

            //Data	Conta	DescrCta	CCusto	DescrCC	Item	DescrItem	Histórico	Lote X CC	Descrição Lote	Valor
            cData := dtoc(stod((cAliasD)->CT2_DATA))
            oExcel:AddRow("Dados","Movimentos", {cData,;
                                                (cAliasD)->CONTA,;
                                                (cAliasD)->CT1_DESC01,;
                                                (cAliasD)->CC,;
                                                (cAliasD)->CTT_DESC01,;
                                                (cAliasD)->ITEM,;
                                                (cAliasD)->CTD_DESC01,;
                                                (cAliasD)->CT2_HIST,;
                                                (cAliasD)->CT2_XLTXCC,;
                                                (cAliasD)->CT2_XDLXCC,;
                                                (cAliasD)->VALOR},;
                                                {11})
            (cAliasD)->(DbSkip())
        
        End

        //
        (cAliasD)->(DbCloseArea())

        //
        oExcel:Activate()

        //
        oExcel:GetXmlFile(cDiret + cArq)
        FreeObj(oExcel)
        oExcel := Nil 

        //
        If apOleCliente("MsExcel")
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open(cDiret + cArq)
            oExcelApp:SetVisible(.T.)
            oExcelApp:Destroy()

        Else 
            WinExec("Explore.exe " + cDiret )

        EndIf

        //
        MsgInfo("Relatório gerado.","Função processa(ADCON020R)")
    else
        MsgInfo("Não há dados para gerar o relatório.","Função processa(ADCON020R)")        
    EndIf
    //
    RestArea(aArea)

Return Nil

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 17/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function objExcel()

    //Variáveis.
    Local oExcel := FWMsExcelEx():New()

    //
    oExcel:AddWorkSheet("Dados")
    oExcel:AddTable("Dados","Movimentos")
    oExcel:AddColumn("Dados","Movimentos","Data",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Conta",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","DescrCta",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","CCusto",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","DescrCC",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Item",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","DescrItem",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Histórico",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Lote X CC",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Descrição Lote",1,1,.F.)	
    oExcel:AddColumn("Dados","Movimentos","Valor",3,2,.F.)

Return oExcel
