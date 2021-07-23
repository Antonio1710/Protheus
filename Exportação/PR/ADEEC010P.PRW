#include "TOTVS.CH"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function U_ADEEC010P()
    Workflow de previsão de embarque para os processos de exportação.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 06/04/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 18/05/2021 - Desenvolvimento inicial do workflow.
/*/
user function ADEEC010P(aEmpFil)
	//local aEmpIni := {}
	Local cCodEmp := ""
	Local cCodFil := ""

	if valType(aEmpFil) == "A"
		if len(aEmpFil) >= 2
			cCodEmp := aEmpFil[1]
			cCodFil := aEmpFil[2]
		endIf
	endIf

	if (!Empty(cCodEmp) .and. !Empty(cCodFil)) .AND. SELECT("SX2") == 0
		Qout(" JOB ADEEC010P-Protheus - 01 - Executando em modo Schedule Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		Qout(" JOB ADEEC010P-Protheus - 02 - Início da rotina...")

		PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
		lInJob := .F.
		RPCSetType(3) //nÃ£o consome licenÃ§a.
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC010P-Protheus - 03 - Início da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		// Executa as rotinas de WorkFlow
		execWF(.T.)
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC010P-Protheus - 04 - Fim da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		RESET ENVIRONMENT
		//PREPARE ENVIRONMENT EMPRESA "51" FILIAL "04"
		Qout(" JOB ADEEC010P-Protheus - 05 - Fim da execução...") 
	else
		// Executa as rotinas de WorkFlow
		MsAguarde({|| execWF(.F.)},"Aguarde...","Enviando notificação de embarques...")
	endIf
return

Static Function execWF(lAutom)
    
    Local cFrom         := "integracao5@adoro.com.br"
    Local cToInt        := Alltrim(Supergetmv("MV_#EC010A",,"leonardo.monteiro@adoro.com.br"))+";"+Alltrim(Supergetmv("MV_#EC010B",,"leonardo.monteiro@adoro.com.br"))
    Local cTo           := ""
    Local lEnvTra       := Supergetmv("MV_#EC010D",,.F. )
    //Local cTo           := "leonardo.monteiro@adoro.com.br"
    Local nDias         := Supergetmv("MV_#EC010C",,3)
    Local cBody         := ""
    Local cSubject      := ""
    Local cAttach       := ""
    Local cQuery        := ""
    Local nTotQtd       := 0
    Local nTotQtd2      := 0
    Local cEOL          := Chr(13)+Chr(10)
    Default cCodEmp     := ""
    Default cCodFil     := "" 
    Default cPedExp     := ""
    Default dDtIni       := dDatabase
    Default dDtFim      := dDatabase+nDias
    Default lAutom      := .F.

    //Domingo
    if dow(Date()) == 1
        //nDias := nDias+0
    //Sexta-feira
    elseif dow(Date()) == 6
        nDias := nDias+2
    //SÃ¡bado
    elseif dow(Date()) == 7
        nDias := nDias+1
    endif

    //LPM
    cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_PEDFAT, EE7.EE7_XBOOKI, EE7.EE7_ESTUFA, EE7.EE7_XWFEMD, EE7.EE7_CODOBP, EE7_XWFNED, EE7_XWFNEE,"+cEOL
    cQuery += " cast(cast(EE7.EE7_XESPEM AS VARBINARY(3000)) AS VARCHAR(3000) ) EE7_XESPEM, "+cEOL
    cQuery += "         C5_DTENTR, C5.C5_NOMECLI, C5.C5_CLIENTE, C5.C5_LOJACLI, C5.C5_PLACA, C5.C5_TRANSP, "+cEOL
    cQuery += "         YA.YA_DESCR, A4.A4_NOME, A4.A4_XEMAILN, "+cEOL
    cQuery += "         A2.A2_EMAIL "+cEOL
    cQuery += " FROM "+ RetSqlName("EE7") +" (NOLOCK) EE7 "+cEOL
	cQuery += " 					 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK)  C5  ON C5.D_E_L_E_T_=''  AND C5.C5_FILIAL='02' AND EE7.EE7_FILIAL='' AND C5.C5_NUM=EE7.EE7_PEDFAT "+cEOL
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SYA") +" (NOLOCK)  YA  ON YA.D_E_L_E_T_=''  AND YA.YA_CODGI =EE7.EE7_PAISET "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA4") +" (NOLOCK)  A4  ON A4.D_E_L_E_T_=''  AND A4.A4_COD =C5.C5_TRANSP "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("ZV4") +" (NOLOCK)  ZV4 ON ZV4.D_E_L_E_T_='' AND ZV4.ZV4_PLACA=C5.C5_PLACA "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA2") +" (NOLOCK)  A2  ON A2.D_E_L_E_T_='' AND A2.A2_COD=ZV4.ZV4_FORNEC AND A2.A2_LOJA=ZV4.ZV4_LOJFOR "+cEOL
    cQuery += " WHERE EE7.D_E_L_E_T_='' AND EE7_FILIAL='"+ xFilial("EE7") +"' AND EE7.EE7_XWFNEE!='S' AND C5.C5_NOTA='' AND C5.C5_ROTEIRO !='' AND C5.C5_PLACA !='' AND "+cEOL
    //cQuery += " WHERE EE7.D_E_L_E_T_='' AND EE7_FILIAL='"+ xFilial("EE7") +"' AND C5.C5_NOTA='' AND "+cEOL
    
    cQuery += " C5.C5_DTENTR BETWEEN '"+ Dtos(dDtIni) +"' AND '"+ Dtos(dDtFim) +"' AND "+cEOL
    cQuery += " EXISTS ( SELECT C9_PEDIDO "+cEOL
    cQuery += "          FROM "+ RetSqlName("SC9") +" (NOLOCK) C9 "+cEOL
    cQuery += "          WHERE C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=C5.C5_NUM AND C9.C9_NFISCAL='') "+cEOL
    cQuery += " AND "+cEOL
    cQuery += " NOT EXISTS ( SELECT C9_PEDIDO "+cEOL
    cQuery += "              FROM "+ RetSqlName("SC9") +" (NOLOCK) C9 "+cEOL
    cQuery += "              WHERE C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=C5.C5_NUM AND C9.C9_NFISCAL='' "+cEOL
    cQuery += "                     AND (C9.C9_BLEST NOT IN ('','10') OR C9.C9_BLCRED NOT IN ('','10')) ) "+cEOL
    cQuery += " ORDER BY C5_DTENTR, EE7.EE7_PEDIDO; "

    Tcquery cQuery ALIAS "QEXP" NEW

    TcSetField( "QEXP", "C5_DTENTR", "D", 8, 0 )
    
    if QEXP->(!eof())
               
        nTotQtd   := 0
        nTotQtd2  := 0
 
        While QEXP->(!EOF())
            
            cSubject      := iiF(!Empty(EE7_XWFNED),"[Alteração]-","")+"Notifição de Embarque (INVOICE "+Alltrim(QEXP->EE7_PEDIDO)+")"

            cBody	:= " <Strong>Para, Logística / Crédito / Expedição / GCL</Strong>"
            cBody	+= " <Br><br><br>"
            cBody   += " Favor notar os dados do pedido EXPORT: "
            cBody	+= " <Br><br><br>"
            cBody	+= " <strong>Invoice(PV):</strong> "+QEXP->EE7_PEDIDO +"("+ QEXP->EE7_PEDFAT +") "
            cBody	+= " <br>"
            cBody	+= " <strong>Cliente:</strong> "+ Alltrim(QEXP->C5_NOMECLI) +"("+ QEXP->C5_CLIENTE +"/"+ QEXP->C5_LOJACLI +") "
            cBody	+= " <br>"
            cBody	+= " <strong>País:</strong> "+ Alltrim(QEXP->YA_DESCR) +" "
            cBody	+= " <br>"
            cBody	+= " <strong>Transportadora:</strong> "+iif(Empty(QEXP->C5_TRANSP), "", Alltrim(QEXP->A4_NOME)+"("+Alltrim(QEXP->C5_TRANSP)+")")
            cBody	+= " <br>"
            cBody	+= " <strong>Placa:</strong> "+Alltrim(QEXP->C5_PLACA) +""
            cBody	+= " <br>"
            cBody	+= " <strong>Booking:</strong> "+ Alltrim(QEXP->EE7_XBOOKI) +" "
            cBody	+= " <br>"
            cBody	+= " <strong>Data Estufagem:</strong> "+ Dtoc(QEXP->C5_DTENTR) +" "
            cBody	+= " <br>"
            cBody	+= " <strong>Especificação de Embarque:</strong> <br>"
            cBody	+= " "+ Replace(QEXP->EE7_XESPEM,chr(13)+chr(10),"<br>") +" "
            cBody	+= " <br><br><br>"
             
            nTotQtd  := 0
            nTotQtd2 := 0
            
            //cBody   += "<ul><li><b><u>Data: " + Dtoc(QEXP->C5_DTENTR) + "</u></b></li></ul><br>"

            cBody   += fGetItem(QEXP->EE7_PEDIDO)

            DbSelectArea("EE7")
            if EE7->(Dbseek(xFilial("EE7")+QEXP->EE7_PEDIDO,.F.))
                If Reclock("EE7",.F.)
                    EE7->EE7_XWFNED := dDatabase
                    //EE7->EE7_XWFNEH := Time()
                    EE7->EE7_XWFNEE := "S"
                    EE7->(Msunlock())
                endif
            endif
            
            cBody   += "<br><br><br>"
            cBody   += "E-mail enviado automaticamente."
            
            if lEnvTra
                cTo := cToInt + iif(right(cToInt,1) ==";","",";") + Alltrim(QEXP->A4_XEMAILN)
            else
                cTo := cToInt
            endif

            U_ENVIAEMAIL(cFrom, cTo, cBody, cSubject, cAttach)
            
            QEXP->(DbSkip())

        Enddo

        nTotQtd  := 0
        nTotQtd2 := 0

        

        if !lAutom
            msginfo("Workflow enviado com sucesso!")
        endif
    else
        if !lAutom
            msginfo("Não há Pedidos de Exportação pendentes!")
        endif
    endif
    
    QEXP->(DbCloseArea())
Return .T.

Static Function fGetItem(cPedExp)
    Local cRet      := ""
    Local cQuery    := ""
    Local nTotPQtd  := 0
    Local nTotPQtd2 := 0

    cRet	+= " <table style='text-align: center; width: 100%;' border='0' cellpadding='3' cellspacing='2'>"
    cRet	+= " <tbody>"

    cRet	+= "<tr>"
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Produto</h2></th> "
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade (Kg)</h2></th> "
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade (Cx)</h2></th> "
    cRet	+= "</tr> "


    cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_PEDFAT, EE7.EE7_XBOOKI, EE7.EE7_ESTUFA, EE7.EE7_XWFEMD, EE7.EE7_CODOBP, "
    cQuery += "   C5_DTENTR, C5.C5_NOMECLI, C5.C5_CLIENTE, C5.C5_LOJACLI, C5.C5_PLACA, C5.C5_TRANSP, "
    cQuery += "   C9.C9_QTDLIB, C9.C9_QTDLIB2, C9.C9_ITEM,"
    cQuery += "   B1.B1_COD, B1.B1_DESCOMP, B1.B1_UM, "
    cQuery += "   YA.YA_DESCR, A4.A4_NOME "
    //cQuery += " cast(cast(EE7.EE7_OBSPED AS VARBINARY(1000)) AS VARCHAR(1000)) EE7_OBSPED "
    cQuery += " FROM "+ RetSqlName("EE7") +" (NOLOCK) EE7 INNER JOIN "+ RetSqlName("EE8") +" (NOLOCK) EE8 ON EE8.EE8_FILIAL=EE7.EE7_FILIAL AND EE8.EE8_PEDIDO=EE7.EE7_PEDIDO
	cQuery += " 					 INNER JOIN "+ RetSqlName("SB1") +" (NOLOCK)  B1 ON B1.D_E_L_E_T_='' AND B1.B1_COD=EE8.EE8_COD_I
	cQuery += " 					 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK)  C5 ON C5.D_E_L_E_T_='' AND C5.C5_FILIAL='02' AND EE7.EE7_FILIAL='' AND C5.C5_PEDEXP=EE7.EE7_PEDIDO
	cQuery += " 					 INNER JOIN "+ RetSqlName("SC9") +" (NOLOCK)  C9 ON C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=EE7.EE7_PEDFAT AND C9.C9_ITEM=EE8.EE8_FATIT
	cQuery += " 					 LEFT  JOIN "+ RetSqlName("SYA") +" (NOLOCK)  YA ON YA.D_E_L_E_T_=''  AND YA.YA_CODGI =EE7.EE7_PAISET
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA4") +" (NOLOCK)  A4 ON A4.D_E_L_E_T_=''  AND A4.A4_COD =C5.C5_TRANSP
    cQuery += " WHERE EE7.D_E_L_E_T_='' AND EE7_FILIAL='"+ xFilial("EE7") +"' AND C9.C9_NFISCAL='' "
    cQuery += " AND EE7.EE7_PEDIDO='"+ cPedExp +"' "
    
    Tcquery cQuery ALIAS "QITE" NEW

    TcSetField( "QEXP", "C5_DTENTR", "D", 8, 0 )

    while QITE->(!eof())

        //if Empty(QEXP->EE7_XWFEMD)
            //cTag1 := "<td valign='center' style='background-color:DodgerBlue;'><h2 style='font-size: 12px;'>"
        //else
            cTag1 := "<td valign='center' style='background-color:#D8D8D8;'><h2 style='font-size: 12px;'>"
        //endif
        
        cTag2 := "</h2></td>"

        cRet   += "<tr>"
        cRet	+= cTag1+ Alltrim(QITE->B1_COD)+"-"+Alltrim(QITE->B1_DESCOMP) + cTag2
        cRet	+= cTag1+ Transform(QITE->C9_QTDLIB,  "@E 999,999,999.99")  +cTag2
        cRet	+= cTag1+ Transform(QITE->C9_QTDLIB2, "@E 999,999,999.99")  +cTag2
        cRet   += "</tr>"

        nTotPQtd  += QITE->C9_QTDLIB
        nTotPQtd2 += QITE->C9_QTDLIB2 

        QITE->(DbSkip())
    enddo
    QITE->(DbCloseArea())

    cRet	+= "<tr>"
    //cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;' colspan='7'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Total Parcial</h2></th> "
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd,   "@E 999,999,999.99") +"</h2></th> "
    cRet	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd2,  "@E 999,999,999.99") +"</h2></th> "
    cRet	+= "</tr>"
    cRet	+= "</tbody>"
    cRet	+= "</Table><br>"

return cRet
