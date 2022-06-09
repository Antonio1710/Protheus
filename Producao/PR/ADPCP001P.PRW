#Include "RwMake.ch"
#Include 'Protheus.ch'
#INCLUDE "TOTVS.CH"
#Include "Topconn.ch"     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ADPCP001Pบ Autor ณ Ricardo Lima - Ch:047403                             บ Data ณ  21/02/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri็ใo ณ Workflow de diferen็a de peso padrใo de produ็ใo                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ Ricardo Lima-22/02/2019-Ch:047403| altera็ใo na query                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็ใo ณ Ricardo Lima-26/02/2019-Ch:047403| altera็ใo na query                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
User Function ADPCP001P()

    Local lAutoJob := .F.
    Local cQuery   := ""
    Local cMsg     := ""
    Local cFil02   := ""
    Local cAssunto := 'Produ็ใo com peso padrใo divergente do cadastro de produtos'
    Local cPara    := ''
    Local lEnvWRK  := .F.

    If Select("SX6") == 0
	    lAutoJob := .T.
    EndIf

    if lAutoJob

        RpcClearEnv()
        RpcSetType( 3 )
	    RpcSetEnv( "01" , "01" )

        // Garanto uma ๚nica thread sendo executada - // Adoro - Chamado n. 050729 || OS 052035 || TECNOLOGIA || LUIZ || 8451 || REDUCAO DE BASE - fwnm - 30/06/2020
        If !LockByName("ADPCP001P", .T., .F.)
            ConOut("[ADPCP001P] - Existe outro processamento sendo executado! Verifique...")
            RPCClearEnv()
            Return
        EndIf

    Endif

    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Workflow de diferen็a de peso padrใo de produ็ใo')
    
    //@history Ticket 70142 	- Rodrigo Mello | Flek - 22/03/2022 - Substituicao de funcao PTInternal por FWMonitorMsg MP 12.1.33
    //FWMonitorMsg(ALLTRIM(PROCNAME()))
    
    // Ricardo Lima-26/02/2019
    //cFil01 := StrZero(Year(Date()-1),4)+"-"+StrZero(Month(Date()-1),2)+"-"+StrZero(Day(Date()-1),2) // Alltrim(SuperGetMv( "MV_#ADP011" , .F. , "2019-01-01" , ) ) 
    cFil02 := Alltrim(SuperGetMv( "MV_#ADP012" , .F. , "'BQ', 'ES', 'TU'" , ) )
    cPara  := Alltrim(SuperGetMv( "MV_#ADP013" , .F. , "" , ) )

    ConOut('Inicio - Produ็ใo com peso padrใo divergente, ' + DtoC(Date()) + ' - ' + Time() )
    // Ricardo Lima-22/02/2019
    cQuery := " SELECT Count(ID_PRODDEFIMATEEMBA) ITENS, ID_PRODDEFIMATEEMBA, NM_PRODDEFIMATEEMBA, CONVERT(VARCHAR(10),CAST(PR.DT_REGIPROD AS DATE),112) DT_REGIPROD "
    cQuery += " FROM LNKMIMS.SMART.dbo.PRODUCAO_REGISTRO PR "
    cQuery += " JOIN LNKMIMS.SMART.dbo.MATERIAL_EMBALAGEM_DEFINICAO ME ON PR.ID_PRODMATEEMBA = ME.ID_PRODDEFIMATEEMBA "
    cQuery += " WHERE PR.DT_REGIPROD >= GETDATE()-1 "
    cQuery += " AND PR.QN_PESOPADRREGIPROD <> ME. QN_CAPAPADRDEFIMATEEMBA "
    cQuery += " AND ME. QN_CAPAPADRDEFIMATEEMBA > 0 "
    cQuery += " AND PR.FL_STATREGIPROD IN ("+cFil02+") "
    cQuery += " GROUP BY ID_PRODDEFIMATEEMBA, NM_PRODDEFIMATEEMBA, CONVERT(VARCHAR(10),CAST(PR.DT_REGIPROD AS DATE),112) "
    If Select("ADPCP01D") > 0
		ADPCP01D->(DbCloseArea())
	EndIf
	TcQuery cQuery NEW Alias "ADPCP01D"

    cMsg += " <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> "
    cMsg += " <html xmlns='http://www.w3.org/1999/xhtml'> "
    cMsg += " <head> "
    cMsg += " <meta http-equiv='Content-Language' content='pt-br' /> "
    cMsg += " <meta http-equiv='Content-Type' content='text/html; charset=utf-8' /> "
    cMsg += " <title>2 sem tํtulo</title> "
    cMsg += " <style type='text/css'> "
    cMsg += " .style1 { "
    cMsg += " 	text-align: center; "
    cMsg += " 	font-family: Verdana; "
    cMsg += " 	border-style: solid; "
    cMsg += " 	border-width: 1px; "
    cMsg += " 	padding: 1px 4px; "
    cMsg += " } "
    cMsg += " .style3 { "
    cMsg += " 	border-width: 0px; "
    cMsg += " } "
    cMsg += " .style4 { "
    cMsg += " 	border-style: solid; "
    cMsg += " 	border-width: 1px; "
    cMsg += " } "
    cMsg += " </style> "
    cMsg += " </head> "
    cMsg += " <body> "
    cMsg += " <p class='style1'><strong>Ad&#39;oro - Produ็ใo com peso padrใo divergente do cadastro de produtos</strong></p> "
    cMsg += " <table style='width: 100%' class='style3'> "
    cMsg += " 	<tr> "
    cMsg += " 		<td class='style4'>Quantidade(CX)</td> "
    cMsg += " 		<td class='style4'>Produto</td> "
    cMsg += " 		<td class='style4'>Descri็ใo</td> "
    cMsg += " 		<td class='style4'>Data</td> "
    cMsg += " 	</tr> "
    While ADPCP01D->( !Eof() )
        lEnvWRK := .T.
            cMsg += " 	<tr> "
            cMsg += " 		<td class='style4'>"+Alltrim(Str(ADPCP01D->ITENS))+"</td> "
            cMsg += " 		<td class='style4'>"+Alltrim(ADPCP01D->ID_PRODDEFIMATEEMBA)+"</td> "
            cMsg += " 		<td class='style4'>"+Alltrim(ADPCP01D->NM_PRODDEFIMATEEMBA)+"</td> "
            cMsg += " 		<td class='style4'>"+DtoC(StoD(ADPCP01D->DT_REGIPROD))+"</td> "
            cMsg += " 	</tr> "
        ADPCP01D->( dbSkip() )
    End
    cMsg += " </table> "
    cMsg += " </body> "
    cMsg += " </html> "

    if !Empty(cPara) .AND. lEnvWRK
        U_F50En2WF( cPara , '' , cAssunto , cMsg , '' )
    Endif

    ConOut('Fim - Produ็ใo com peso padrใo divergente, ' + DtoC(Date()) + ' - ' + Time() )

    if lAutoJob
	
        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
        //ณDestrava a rotina para o usuแrio	    ?
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ?
        UnLockByName("ADPCP001P")

        RpcClearEnv()

    Endif

Return
