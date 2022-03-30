#include "TOTVS.CH"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} User Function U_ADEEC014P()
    Workflow de notificação e autorização para o faturamento.
    Chamado 8465
    @type  Function
    @author Leonardo P. Monteiro
    @since 13/01/2022
    @version 01
    @history Chamado 18301 - Leonardo P. Monteiro - 13/01/2022 - Desenvolvimento inicial do workflow.
    @history Chamado 18301 - Leonardo P. Monteiro - 19/01/2022 - Conversão da rotina para execução em schedule.
/*/
user function ADEEC014P(aEmpFil)
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
		Qout(" JOB ADEEC014P-Protheus - 01 - Executando em modo Schedule Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		Qout(" JOB ADEEC014P-Protheus - 02 - Início da rotina...")

		PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
		lInJob := .F.
		RPCSetType(3) //nÃ£o consome licenÃ§a.
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC014P-Protheus - 03 - Início da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		// Executa as rotinas de WorkFlow
		execWF(.T.)
		Qout(DtoC(dDatabase) + "-" + Time() + " JOB ADEEC014P-Protheus - 04 - Fim da rotina na Empresa "+ aEmpFil[1] + " e Filial " +aEmpFil[2] +"...")
		RESET ENVIRONMENT
		//PREPARE ENVIRONMENT EMPRESA "51" FILIAL "04"
		Qout(" JOB ADEEC014P-Protheus - 05 - Fim da execução...") 
	else
		// Executa as rotinas de WorkFlow
		MsAguarde({|| execWF(.F.)},"Aguarde...","Enviando notificação de embarques...")
	endIf

    //
    U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Workflow de notificação e autorização para o faturamento')

return

Static Function execWF(lAutom)
    
    Local cFrom         := "integracao5@adoro.com.br"
    Local cToInt        := Alltrim(Supergetmv("MV_#EC014A",,"leonardo.monteiro@adoro.com.br"))+";"+Alltrim(Supergetmv("MV_#EC014B",,"leonardo.monteiro@adoro.com.br"))
    Local cTo           := ""
    Local nDias         := Supergetmv("MV_#EC014C",,0)
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


    //LPM
    cQuery := " SELECT EE7.EE7_PEDIDO, EE7.EE7_PEDFAT, EE7.EE7_XBOOKI, EE7.EE7_ESTUFA, EE7.EE7_XWFEMD, EE7.EE7_CODOBP, EE7_XWFNED, EE7_XWFNEE,"+cEOL
    cQuery += " cast(cast(EE7.EE7_XESPEM AS VARBINARY(3000)) AS VARCHAR(3000) ) EE7_XESPEM, "+cEOL
    cQuery += "         C5_DTENTR, C5.C5_NOMECLI, C5.C5_CLIENTE, C5.C5_LOJACLI, C5.C5_PLACA, C5.C5_TRANSP, C5.C5_CONTAIN, C5.C5_NLACRE1, C5.C5_NLACRE2, C5.C5_TEMPERA, C5.C5_DTPROD, "+cEOL
    cQuery += "         ZEX.ZEX_CONTAI, ZEX.ZEX_LACRE1, ZEX.ZEX_LACRE2, ZEX.DT_MIN, ZEX.DT_MAX, "+cEOL
    cQuery += "         YA_DESCR, A4_NOME  "+cEOL
    cQuery += " FROM "+ RetSqlName("EE7") +" (NOLOCK) EE7 "+cEOL
    cQuery += " 					 INNER JOIN "+ RetSqlName("SC5") +" (NOLOCK)  C5  ON C5.D_E_L_E_T_=''  AND C5.C5_FILIAL='02' AND EE7.EE7_FILIAL='' AND C5.C5_NUM=EE7.EE7_PEDFAT "+cEOL
	cQuery += " LEFT JOIN  "+cEOL
    cQuery += " (SELECT ZEX_FILIAL, ZEX_NUMERO, ZEX_PLACA,ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2, MIN(ZEX_DTFABR) DT_MIN, MAX(ZEX_DTFABR) DT_MAX  "+ cEOL
    cQuery += "  FROM "+ RetSqlName("ZEX") +" (NOLOCK) ZEX "+ cEOL
    cQuery += "  WHERE ZEX.D_E_L_E_T_='' "+ cEOL
	cQuery += "  GROUP BY ZEX_FILIAL, ZEX_NUMERO, ZEX_PLACA,ZEX_CONTAI, ZEX_LACRE1, ZEX_LACRE2) ZEX ON ZEX.ZEX_FILIAL=C5.C5_FILIAL AND ZEX.ZEX_NUMERO=C5.C5_NUM "
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SYA") +" (NOLOCK)  YA  ON YA.D_E_L_E_T_=''  AND YA.YA_CODGI =EE7.EE7_PAISET "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA4") +" (NOLOCK)  A4  ON A4.D_E_L_E_T_=''  AND A4.A4_COD =C5.C5_TRANSP "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("ZV4") +" (NOLOCK)  ZV4 ON ZV4.D_E_L_E_T_='' AND ZV4.ZV4_PLACA=C5.C5_PLACA "+cEOL
    cQuery += " 					 LEFT  JOIN "+ RetSqlName("SA2") +" (NOLOCK)  A2  ON A2.D_E_L_E_T_='' AND A2.A2_COD=ZV4.ZV4_FORNEC AND A2.A2_LOJA=ZV4.ZV4_LOJFOR "+cEOL
    cQuery += " WHERE EE7.D_E_L_E_T_='' AND EE7_FILIAL='"+ xFilial("EE7") +"' AND EE7.EE7_XFATDN ='' AND C5.C5_NOTA='' "+cEOL
    //cQuery += " WHERE EE7.D_E_L_E_T_='' AND EE7_FILIAL='"+ xFilial("EE7") +"' "+cEOL
    cQuery += " AND C5.C5_DTENTR BETWEEN '"+ Dtos(dDtIni) +"' AND '"+ Dtos(dDtFim) +"' "+cEOL
    
    cQuery += " AND C5.C5_XFLAGE ='2' AND C5.C5_XINSQLD='1' "+cEOL
    cQuery += " AND EXISTS ( SELECT C9_PEDIDO "+cEOL
    cQuery += "              FROM "+ RetSqlName("SC9") +" (NOLOCK) C9 "+cEOL
    cQuery += "              WHERE C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=C5.C5_NUM AND C9.C9_NFISCAL='') "+cEOL
    cQuery += " AND NOT EXISTS ( SELECT C9_PEDIDO "+cEOL
    cQuery += "                  FROM "+ RetSqlName("SC9") +" (NOLOCK) C9 "+cEOL
    cQuery += "                  WHERE C9.D_E_L_E_T_='' AND C9.C9_FILIAL=C5.C5_FILIAL AND C9.C9_PEDIDO=C5.C5_NUM AND C9.C9_NFISCAL='' "+cEOL
    cQuery += "                     AND (C9.C9_BLEST NOT IN ('','10') OR C9.C9_BLCRED NOT IN ('','10')) ) "+cEOL
    
    cQuery += " ORDER BY C5_DTENTR, EE7.EE7_PEDIDO; "

    Tcquery cQuery ALIAS "QEXP" NEW

    TcSetField( "QEXP", "C5_DTENTR", "D", 8, 0 )
    
    if QEXP->(!eof())
               
        nTotQtd   := 0
        nTotQtd2  := 0
 
        While QEXP->(!EOF())
            
            cSubject      := "Notifição de Liberação p/ Faturamento PV "+QEXP->EE7_PEDFAT+" (INVOICE "+Alltrim(QEXP->EE7_PEDIDO)+")"

            cBody	:= " <Strong>Para, Comex / Faturamento</Strong>"
            cBody	+= " <Br><br><br>"
            cBody   += " Liberado para faturamento por EXPORT: "
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
            // ZEX.ZEX_CONTAI, ZEX.ZEX_LACRE1, ZEX.ZEX_LACRE2, ZEX.DT_MIN, ZEX.DT_MAX
            if Empty(QEXP->ZEX_CONTAI)
                cBody	+= " <strong>Número do container:</strong> "+ Alltrim(QEXP->C5_CONTAIN) +" "
            else
                cBody	+= " <strong>Número do container:</strong> "+ Alltrim(QEXP->ZEX_CONTAI) +" "
            endif
            /*
            cBody	+= " <br>"
            if Empty(QEXP->ZEX_LACRE1)
                cBody	+= " <strong>Número do Lacre Container:</strong> "+ Alltrim(QEXP->C5_NLACRE1) +" "
            else
                cBody	+= " <strong>Número do Lacre Container:</strong> "+ Alltrim(QEXP->ZEX_LACRE1) +" "
            endif
            */
            cBody	+= " <br>"
            if Empty(QEXP->ZEX_LACRE2)
                cBody	+= " <strong>Número do Lacre Oficial:</strong> "+ Alltrim(QEXP->C5_NLACRE2) +" "
            else
                cBody	+= " <strong>Número do Lacre Oficial:</strong> "+ Alltrim(QEXP->ZEX_LACRE2) +" "
            endif
            cBody	+= " <br>"
            cBody	+= " <strong>Temperatura de Embarque:</strong> "+ Alltrim(QEXP->C5_TEMPERA) +" "
            cBody	+= " <br>"
            if Empty(QEXP->DT_MIN) .or. Empty(DT_MAX)
                cBody	+= " <strong>Data de Produção:</strong> "+ Alltrim(QEXP->C5_DTPROD) +" "
            else
                cBody	+= " <strong>Data de Produção:</strong> "+ Dtoc(Stod(QEXP->DT_MIN)) +" A "+ Dtoc(Stod(QEXP->DT_MAX)) +" "
            endif
            cBody	+= " <br>"
            cBody	+= " <br><br><br>"
            
            nTotQtd  := 0
            nTotQtd2 := 0
            
            //cBody   += "<ul><li><b><u>Data: " + Dtoc(QEXP->C5_DTENTR) + "</u></b></li></ul><br>"

            //cBody   += fGetItem(QEXP->EE7_PEDIDO)

            DbSelectArea("EE7")
            if EE7->(Dbseek(xFilial("EE7")+QEXP->EE7_PEDIDO,.F.))
                If Reclock("EE7",.F.)
                    EE7->EE7_XFATDN := dDatabase
                    //EE7->EE7_XWFNEH := Time()
                    EE7->EE7_XFATHN := time()
                    EE7->(Msunlock())
                endif
            endif
            
            cBody   += "<br><br><br>"
            cBody   += "E-mail enviado automaticamente."
            
            cTo := cToInt
            
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
