#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"


/*/{Protheus.doc} ADMNT014R - Relatorio de custo de requisição de almoxarifado
    @type  Function
    @author Denis Guedes
    @since 02/06/2021
    @version 01
    @history Ticket: TI    - 11/06/2021 - ADRIANO SAVOINE - Corrigida a query da consulta para agrupar os dados.
    @history Ticket: 13556 - 25/06/2021 - LEONARDO P. MONTEIRO - Correção da rotina para execução via schedule.
    @history Ticket: 63902 - 23/11/2021 - TIAGO STOCCO - Correção da QUERY para desprezar os estornados da SD3
    @history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
    @history Ticket 76482  - 15/07/2022 - ADRIANO SAVOINE - Corrigido o programa para rodar Schedule na versão Protheus V33.
/*/

User Function ADMNT014R(aParam)
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT012R"
Local aInfoCustom 	:= {}
Local cTxtIntro	    := "Rotina responsável pela extracao EXCEL do custo de requisição de almoxarifado"
local lSetEnv       := .f.

cPara      := ""
cAssunto   := "Relação do custo de requisição de almoxarifado"
cCorpo     := "Relação do custo de requisição de almoxarifado"
aAnexos    := {}
lMostraLog := .F.
lUsaTLS    := .T.

IF !EMPTY(aParam)  //Ticket 76482  - 15/07/2022 - ADRIANO SAVOINE
                RpcClearEnv()
                RpcSetType(3)
    lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
ENDIF

Private lJob          := IsBlind()
Private oProcess
Private dMVPAR01   
Private dMVPAR02   
Private cMVPAR03   
Private cMVPAR04  
Private czEMP
Private czFIL

If lJob
	//RpcSetType(3)
	//lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
    czEMP    := aParam[1]   
    czFIL    := aParam[2]  
    
    //@history Ticket: 13556 - 25/06/2021 - LEONARDO P. MONTEIRO - Correção da rotina para execução via schedule.
    dMVPAR01	:= Stod( Left( Dtos( Date() ),6 )+"01" )
    dMVPAR02	:= Date()
    
    cMVPAR03 := czFIL
    cMVPAR04 := czFIL
    
    Qout(" JOB ADMNT-Protheus - 01 - Parametros dMVPAR01="+ Dtoc(dMVPAR01) + ", dMVPAR02=" + Dtoc(dMVPAR02) +", cMVPAR03="+ cMVPAR03 +", cMVPAR04="+cMVPAR04+" ")
    
    PREPARE ENVIRONMENT EMPRESA czEMP FILIAL czFIL MODULO "EST"
    cPara      :=  SuperGetMv('ZZ_MNT014R', .f. ,"sonia.silva@adoro.com.br;hercules.moreira@adoro.com.br;debora.silva@adoro.com.br" )
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADMNT014R","Custo de requisição",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Custo de requisição", .T. )
Endif

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Rel. de custo de requisição de almoxarifado ')

Return

Static Function Executa(oProcess)
Local cQry      := ""
Local cAlias    := GetNextAlias()

Private oExcel  	:= FwMsExcel():New()
Private dDataIni	
Private dDataFim
Private cNomArq
Private cDIRARQ
Private cDIRREDE

//@history Ticket: 13556 - 25/06/2021 - LEONARDO P. MONTEIRO - Correção da rotina para execução via schedule.
If !lJob

    dMVPAR01	:= MV_PAR01
    dMVPAR02	:= MV_PAR02
    cMVPAR03	:= MV_PAR03
    cMVPAR04	:= MV_PAR04

EndIf


oExcel:AddworkSheet("Custo") // Planilha
oExcel:AddTable ("Custo","RelCusto") // Titulo da Planilha (CabeÃ§alho)
oExcel:AddColumn("Custo","RelCusto","FILIAL"         ,1,1)
oExcel:AddColumn("Custo","RelCusto","GRUPO"	         ,1,1)
oExcel:AddColumn("Custo","RelCusto","DESCRIÇÃO"	     ,1,1)
oExcel:AddColumn("Custo","RelCusto","CUSTO"		     ,3,3,.T.)


cQry    := " SELECT "
cQry    += " D3_FILIAL,"
cQry    += " D3_GRUPO,"
cQry    += " BM_DESC,"
cQry    += " SUM(D3_CUSTO1) AS D3_CUSTO1"    // Ticket: TI - 11/06/2021 - ADRIANO SAVOINE
cQry    += " FROM "+RetSqlName("SD3")+" (NOLOCK) D3 " 
cQry    += " INNER JOIN "+RetSqlName("SBM")+" (NOLOCK) BM ON " 
cQry    += " BM_FILIAL = '"+xFilial("SBM")+"' "
cQry    += " AND D3_GRUPO = BM_GRUPO"
cQry    += " AND BM.D_E_L_E_T_ = ' ' "
cQry    += " WHERE "
cQry    += " D3_EMISSAO BETWEEN '"+DTOS(dMVPAR01)+"' AND '"+DTOS(dMVPAR02)+"' "
cQry    += " AND D3_FILIAL BETWEEN '"+cMVPAR03+"' AND '"+cMVPAR04+"' "
cQry    += " AND D3_TM = '501'
cQry    += " AND D3_CC IN ('5213','5217','5304')
cQry    += " AND D3.D_E_L_E_T_ = ' ' "
cQry    += " AND D3_ESTORNO <> 'S' " //Ticket: 63902 - 23/11/2021 - TIAGO STOCCO
cQry    += " GROUP BY D3_FILIAL,D3_GRUPO,BM_DESC "  // Ticket: TI - 11/06/2021 - ADRIANO SAVOINE
cQry    += " ORDER BY D3_FILIAL,D3_GRUPO "

/*
MemoWrite("c:\TEMP\cQry.txt", cQry)
*/

IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
DbGotop()

If (cAlias)->(!EOF())
	While (cAlias)->(!EOF())
        oExcel:AddRow("Custo","RelCusto",{	(cAlias)->D3_FILIAL,;
                                            (cAlias)->D3_GRUPO     ,;
                                            (cAlias)->BM_DESC	   ,;
                                            (cAlias)->D3_CUSTO1	    ;
                                         })	
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If !(lJob)
        cDIRARQ := "c:\temp\"
        cNomArq := "REL_CUSTO_"+cEmpAnt+"_"+cFilAnt+".XLS" 
    Else
        cDIRARQ := "\DATA\"
        cNomArq := "REL_CUSTO_"+czEMP+"_"+czFIL+".XLS" 
    EndIf
	
    oExcel:Activate()
	
    If !(lJob)
        MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRARQ+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
	Else
        oExcel:GetXMLFile(cDIRARQ+cNomArq)
     	/*
        cDIRREDE := "\RELATORIO\"
        nStatus  := __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 
		If FError() == 25 //Arquivo jÃ¡ existe na pasta destino
			FERASE(cDIRREDE+cNomArq) 
            nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 
		EndIf
        */

    Endif

	oExcelApp:=MsExcel():New()                                         
	
    If !(lJob)
        oExcelApp:WorkBooks:Open( cDIRARQ+cNomArq ) // Abre uma planilha
        oExcelApp:SetVisible(.T.)
        /*
        cDIRARQ := "\DATA\"
        cNomArq := "REL_CUSTO_"+cEmpAnt+"_"+cFilAnt+".XLS" 
        aAdd(aAnexos, cDIRARQ+cNomArq)
        oExcel:GetXMLFile(cDIRARQ+cNomArq)
        cPara      :=  SuperGetMv('ZZ_MNT014R', .f. ,"denis.guedes@dtmit.com.br" ) 
        fEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
        */
    Else
        aAdd(aAnexos, cDIRARQ+cNomArq)
        fEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
	EndIf
       
EndIf
Return

Static Function fEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lMostraLog := .F.
    Default lUsaTLS    := .F.
 
    //Se tiver em branco o destinatÃ¡rio, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
 
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
 
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo existir
            If File(aAnexos[nAtual])
 
                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
 
            //Senao, acrescenta no log
            Else
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
 
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
 
        //Define se irÃ¡ utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conexÃ£o
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
 
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
 
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
 
            If lRet
                //Realiza a autenticaÃ§Ã£o do usuÃ¡rio e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
 
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
 
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel disconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
 
    //Se tiver log de avisos/erros
    If !Empty(cLog)
        cLog := "fEnvMail - "+dToC(Date())+ " " + Time() + CRLF + ;
            "Funcao - " + FunName() + CRLF + CRLF +;
            "Existem mensagens de aviso: "+ CRLF +;
            cLog
        ConOut(cLog)
 
        //Se for para mostrar o log visualmente e for processo com interface com o usuÃ¡rio, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
 
    RestArea(aArea)
Return lRet

/*/{Protheus.doc} u_MNT014A0
Ticket 70142 - Substituicao de funcao Static Call por User Function MP 12.1.33
@type function
@version 1.0
@author Edvar   / Flek Solution
@since 16/03/2022
@history Ticket 70142  - Edvar   / Flek Solution - 23/03/2022 - Substituicao de funcao Static Call por User Function MP 12.1.33
/*/
Function u_MNT014A0( uPar1, uPar2, uPar3, uPar4, uPar5, uPar6 )
Return( fEnvMail( uPar1, uPar2, uPar3, uPar4, uPar5, uPar6 ) )
