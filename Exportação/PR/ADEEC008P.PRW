#include "TOTVS.CH"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function ADEEC008'
    Workflow de previsão de embarque para os processos de exportação.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 06/04/2021
    @version 01
    @history Chamado 8465 - Leonardo P. Monteiro - 15/03/2021 - Desenvolvimento inicial do workflow.
    @history Chamado 8465 - Leonardo P. Monteiro - 16/04/2021 - Adequação do workflow as necessidades do Depto. Comex.
    @history Chamado 69624 - Leonardo P. Monteiro - 11/03/2021 - Correção nos filtros de datas para o envio correto da programação para a semana seguinte.
/*/
user function ADEEC008P(aEmpFil, cPedExp, dDtDe, dDtAte, lAutom)
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
		Qout(" JOB ADEEC008P-Protheus - 01 - Executando em modo Schedule Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		Qout(" JOB ADEEC008P-Protheus - 02 - Início da rotina...")

		PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
		lInJob := .F.
		RPCSetType(3) //não consome licença.
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC008P-Protheus - 03 - Início da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		// Executa as rotinas de WorkFlow
		execWF(.T.)
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC008P-Protheus - 04 - Fim da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		RESET ENVIRONMENT
		//PREPARE ENVIRONMENT EMPRESA "51" FILIAL "04"
		Qout(" JOB ADEEC008P-Protheus - 05 - Fim da execução...") 
	else
		// Executa as rotinas de WorkFlow
		MsAguarde({|| execWF(.F.)},"Aguarde...","Enviando previsões de embarques...")
	endIf

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Workflow de previsão de embarque para os processos de exportação')

return

Static Function execWF(lAutom)
    
    Local cFrom         := "integracao5@adoro.com.br"
    Local cTo           := Alltrim(Supergetmv("MV_XEC008A",,"leonardo.monteiro@adoro.com.br"))+";"+Alltrim(Supergetmv("MV_XEC008C",,"leonardo.monteiro@adoro.com.br"))
    //Local cTo           := "leonardo.monteiro@adoro.com.br"
    Local nDias         := Supergetmv("MV_XEC008B",,7)
    Local cBody         := ""
    Local cSubject      := ""
    Local cAttach       := ""
    Local cQuery        := ""
    Local cObsTec       := ""
    Local nTotQtd       := 0
    Local nTotQtd2      := 0
    Local nTotPQtd      := 0
    Local nTotPQtd2     := 0
    Local dDtAtual      := Stod("")
    Default cCodEmp     := ""
    Default cCodFil     := "" 
    Default cPedExp     := ""
    Default dDtDe       := fGetSeg(Date())
    Default dDtAte      := dDtDe+nDias
    Default lAutom      := .F.

    cSubject      := "Previsão de Embarque (Semana "+ RetSem(dDtDe) +")"

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
    cQuery += "         AND C9.C9_BLEST IN ('','10') AND C9.C9_BLCRED IN ('','10') AND C9.C9_BLEST='' "
    
    /*
    if lAutom
        cQuery += " AND EE7.EE7_XWFEMD='' "
    endif
    */

    if !Empty(cPedExp)
        cQuery += " AND EE7.EE7_PEDIDO='"+ cPedExp +"' "
    else
        cQuery += " AND EE8.EE8_DTENTR between '"+ Dtos(dDtDe) +"' and '"+ Dtos(dDtAte) +"' "
    endif
    cQuery += " ORDER BY C5_DTENTR, EE7.EE7_PEDIDO; "

    Tcquery cQuery ALIAS "QEXP" NEW

    TcSetField( "QEXP", "C5_DTENTR", "D", 8, 0 )
    if QEXP->(!eof())
        
        DbSelectArea("EE7")
        //EE7->(DbSetOrder(1))
        
        cBody	+= " <Strong>Para, Logística / Expedição</Strong>"
        cBody	+= " <Br><br><br>"
        cBody	+= " Favor notar os embarques, para a próxima semana:"
        cBody	+= " <br><br><br>"
        
        nTotQtd   := 0
        nTotQtd2  := 0
        nTotPQtd  := 0
        nTotPQtd2 := 0

        While QEXP->(!EOF())
            
            if dDtAtual != QEXP->C5_DTENTR

                if !Empty(dDtAtual)
                    cBody	+= "<tr>"
                    cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;' colspan='7'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
                    cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Total Parcial</h2></th> "
                    cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd,   "@E 999,999,999.99") +"</h2></th> "
                    cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd2,  "@E 999,999,999.99") +"</h2></th> "
                    //cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
                    cBody	+= "</tr>"
                    cBody	+= "</tbody>"
                    cBody	+= "</Table><br>"
                    
                    nTotPQtd  := 0
                    nTotPQtd2 := 0
                endif

                cBody   += "<ul><li><b><u>Data: " + Dtoc(QEXP->C5_DTENTR) + "</u></b></li></ul><br>"

                cBody	+= " <table style='text-align: center; width: 100%;' border='0' cellpadding='3' cellspacing='2'>"
                cBody	+= " <tbody>"
                
                cBody	+= "<tr>"
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Invoice</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Pedido/It.</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Booking</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Placa</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Transportadora</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Cliente</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>País Destino</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Produto</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade (Kg)</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade (Cx)</h2></th> "
                //cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Prev Embarque</h2></th> "
                cBody	+= "</tr> "
            endif

            if Empty(QEXP->EE7_XWFEMD)
                cTag1 := "<td valign='center' style='background-color:DodgerBlue;'><h2 style='font-size: 12px;'>"
            else
                cTag1 := "<td valign='center' style='background-color:#D8D8D8;'><h2 style='font-size: 12px;'>"
            endif
            
            cTag2 := "</h2></td>"

            cBody   += "<tr>"
            cBody	+= cTag1+ Alltrim(QEXP->EE7_PEDIDO) + cTag2 
            cBody	+= cTag1+ Alltrim(QEXP->EE7_PEDFAT)+"("+Alltrim(QEXP->C9_ITEM)+")"+ cTag2
            cBody	+= cTag1+ Alltrim(QEXP->EE7_XBOOKI) + cTag2
            cBody	+= cTag1+ Alltrim(QEXP->C5_PLACA) + cTag2
            
            cBody	+= cTag1+ iif(Empty(QEXP->C5_TRANSP), "", Alltrim(QEXP->A4_NOME)+"("+Alltrim(QEXP->C5_TRANSP)+")") + cTag2
            cBody	+= cTag1+ Alltrim(QEXP->C5_NOMECLI)+"("+QEXP->C5_CLIENTE+QEXP->C5_LOJACLI + ")" + cTag2
            cBody	+= cTag1+ Alltrim(QEXP->YA_DESCR) + cTag2
            cBody	+= cTag1+ Alltrim(QEXP->B1_COD)+"-"+Alltrim(QEXP->B1_DESCOMP) + cTag2
            cBody	+= cTag1+ Transform(QEXP->C9_QTDLIB,  "@E 999,999,999.99")  +cTag2
            cBody	+= cTag1+ Transform(QEXP->C9_QTDLIB2, "@E 999,999,999.99")  +cTag2
            //cBody	+= cTag1+ Dtoc(StoD(QEXP->C5_DTENTR)) + cTag2
            cBody   += "</tr>"

            nTotQtd   += QEXP->C9_QTDLIB
            nTotQtd2  += QEXP->C9_QTDLIB2 
            nTotPQtd  += QEXP->C9_QTDLIB
            nTotPQtd2 += QEXP->C9_QTDLIB2 
            /*
            cObsTec := AllTrim(MSMM(val(QEXP->EE7_CODOBP)))
            
            if !empty(cObsTec)
                cBody   += "<tr>" 
                cBody   += "<td valign='center' style='background-color:#D8D8D8;' colspan='3'><h2 style='font-size: 12px;'>Especificações de embarque:</h2></td>"
                cBody   += "<td valign='center' colspan='8'><h2 style='font-size: 12px;'>"+replace(cObsTec,CHR(13)+CHR(10),"<BR>")+"</h2></td>"
                cBody   += "</tr>"
            endif
            */
            
            DbSelectArea("EE7")
            if EE7->(Dbseek(xFilial("EE7")+QEXP->EE7_PEDIDO,.F.))
                If Reclock("EE7",.F.)
                    EE7->EE7_XWFEMD := dDatabase
                    EE7->EE7_XWFEMH := Time()
                    EE7->(Msunlock())
                endif
            endif
            
            
            dDtAtual := QEXP->C5_DTENTR
            
            QEXP->(DbSkip())

            if QEXP->(eof())
                cBody	+= "<tr>"
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;' colspan='7'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Total Parcial</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd,  "@E 999,999,999.99") +"</h2></th> "
                cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>"+ Transform(nTotPQtd2,  "@E 999,999,999.99") +"</h2></th> "
                //cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
                cBody	+= "</tr>"
                cBody	+= "</tbody>"
                cBody	+= "</Table><br>"
            endif

        Enddo
        
        cBody	+= "<br>"
        cBody	+= "<table style='text-align: center; width: 100%;' border='0' cellpadding='3' cellspacing='2'>"
        cBody	+= "<tbody>"
        cBody	+= "<tr>"
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;' colspan='7'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Total Geral</h2></th> "
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade(KG): "+ Transform(nTotQtd,   "@E 999,999,999.99") +"</h2></th> "
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Quantidade(Cx): "+ Transform(nTotQtd2,  "@E 999,999,999.99") +"</h2></th> "
        //cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'></h2></th> "
        cBody	+= "</tr>"
        cBody	+= "</tbody>"
        cBody	+= "</Table><br>"


        nTotQtd  := 0
        nTotQtd2 := 0

        //cBody += "<h2 style='font-size: 12px; font-family: Arial; background-color:DodgerBlue;'>* Invoices adicionadas a lista de embarques.</h2>"

        cBody	+= " <table style='text-align: center; width: 40%;' border='0' cellpadding='3' cellspacing='2'>"
        cBody	+= " <tbody>"
        cBody	+= "<tr>"
        cBody	+= " <th valign='center' colspan='2'><h2 style='font-size: 14px; font-family: Arial;'>Status</h2></th>"
        cBody	+= " </tr>"
        cBody	+= "<tr>"
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>St.</h2></th> "
        cBody	+= " <th valign='center' style='background-color: gray; font-weight: bold; color: white;'><h2 style='font-size: 12px; font-family: Arial;'>Descrição</h2></th> "
        cBody	+= " </tr>"
        cBody	+= "<tr>"
        cBody   += "<td valign='center' style='background-color:DodgerBlue;'><h2 style='font-size: 12px;'></td>"
        cBody   += "<td valign='left'><h2 style='font-size: 12px; text-align=left;'>Invoice adicionada recentemente a previsão de embarque.</td>"
        cBody	+= " </tr>"
        cBody	+= "<tr>"
        cBody   += "<td valign='center' style='background-color:#D8D8D8;'><h2 style='font-size: 12px;'></td>"
        cBody   += "<td valign='left'><h2 style='font-size: 12px; text-align=left;'>Invoice programada para entrega.</td>"
        cBody	+= " </tr>"
        cBody	+= "</tbody>"
        cBody	+= "</Table>"

        U_ENVIAEMAIL(cFrom,cTo,cBody,cSubject,cAttach)

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

Static Function fGetSeg(dData)
    Local nDiaSem := dow(dData)
    Local dRet    := dData

    if nDiaSem == 1
        dRet := dRet + 1
    Elseif nDiaSem == 2
        dRet := dRet + 7
    Elseif nDiaSem == 3
        dRet := dRet + 6
    Elseif nDiaSem == 4
        dRet := dRet + 5
    Elseif nDiaSem == 5
        dRet := dRet + 4
    Elseif nDiaSem == 6
        dRet := dRet + 3
    Elseif nDiaSem == 7
        dRet := dRet + 2
    endif

return dRet

