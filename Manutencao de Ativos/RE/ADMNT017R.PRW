#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"


/*/{Protheus.doc} ADMNT017R - Relatorio de Custo por solicitante / Eqto Exporta Excel
    @type  Function
    @author Tiago Stocco
    @since 23/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @history Ticket 64237 - 08/12/2021 - Adriano Savoine - Alterado o Relatorio para ser enviado via Schedule.
    /*/

User Function ADMNT017R(aParam)
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT011R"
Local aInfoCustom 	:= {}
Local cTxtIntro	    := "Rotina respons�vel pela extracao EXCEL dos Valores da OS por solicitante"
local lSetEnv       := .f.

cPara      := ""
cAssunto   := "Rotina respons�vel pela extracao EXCEL dos Valores da OS por solicitante"
cCorpo     := "Rotina respons�vel pela extracao EXCEL dos Valores da OS por solicitante"
aAnexos    := {}
lMostraLog := .F.
lUsaTLS    := .T.

Private lJob  := IsBlind()
Private oProcess
Private dMVPAR01   
Private dMVPAR02   


If lJob
	RpcSetType(3)
	lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
    czEMP    := aParam[1]   
    czFIL    := aParam[2]  
    
    dMVPAR01	:= Stod( Left( Dtos( Date() ),6 )+"01" )
    dMVPAR02	:= Date()
    

    Qout(" JOB ADMNT-Protheus - 01 - Parametros dMVPAR01="+ Dtoc(dMVPAR01) + ", dMVPAR02=" + Dtoc(dMVPAR02) +" ")
    
    PREPARE ENVIRONMENT EMPRESA czEMP FILIAL czFIL MODULO "EST"
    cPara      :=  SuperGetMv('ZZ_MNT017R', .f. ,"adm.manutencao@adoro.com.br" )
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADMNT017R","Custo OS Solicitante",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Custo OS Solicitante", .T. )
Endif



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

If !lJob

    dMVPAR01	:= MV_PAR01
    dMVPAR02	:= MV_PAR02

EndIf


oExcel:AddworkSheet("Custo_Solicit") // Planilha
oExcel:AddTable ("Custo_Solicit","Custo_x_Solicitante") // Titulo da Planilha (Cabe�alho)
oExcel:AddColumn("Custo_Solicit","Custo_x_Solicitante","Solicitante"    ,1,1)
oExcel:AddColumn("Custo_Solicit","Custo_x_Solicitante","Custo"		    ,3,3)

cQry    := " SELECT "
cQry    += " CP_USER,"
cQry    += " SUM(TL_CUSTO) AS CUSTO "
cQry    += " FROM "+RetSqlName("STL")+" TL WITH (NOLOCK) " 
cQry    += " INNER JOIN "+RetSqlName("SCP")+" SCP WITH (NOLOCK) ON "
cQry    += " CP_FILIAL = TL_FILIAL "
cQry    += " AND CP_NUM = TL_NUMSA "
cQry    += " AND CP_PRODUTO = TL_CODIGO "
cQry    += " AND CP_ITEM = TL_ITEMSA "
cQry    += " AND SCP.D_E_L_E_T_ = '' "
cQry    += " WHERE "
cQry    += " TL_DTINICI BETWEEN '"+DTOS(dMVPAR01)+"' AND '"+DTOS(dMVPAR02)+"' "
cQry    += " AND TL.D_E_L_E_T_ = '' "
cQry    += " AND TL_SEQRELA <> '0' "
cQry    += " AND TL_FORNEC = '' "
cQry    += " AND TL_TIPOREG = 'P' "
cQry    += " AND TL_FILIAL = '"+xFilial("STL")+"' "
cQry    += " GROUP BY CP_USER,TL_FILIAL "
cQry    += " ORDER BY CP_USER"


IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
DbGotop()

If (cAlias)->(!EOF())
	While (cAlias)->(!EOF())
        cSolicit    :=  UsrRetName((cAlias)->CP_USER)
        oExcel:AddRow("Custo_Solicit","Custo_x_Solicitante",{	cSolicit		    ,;
                                            (cAlias)->CUSTO                         })	
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If !(lJob)
        cDIRARQ := "c:\temp\"
        cNomArq := "CUST_SOLICIT.XLS" 
    Else
        cDIRARQ := "\DATA\"
        cNomArq := "CUST_SOLICIT.XLS" 
    EndIf
	
    oExcel:Activate()
	
    If !(lJob)
        MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRARQ+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
	Else
        oExcel:GetXMLFile(cDIRARQ+cNomArq)
     	
    Endif

	oExcelApp:=MsExcel():New()                                         
	
    If !(lJob)
        oExcelApp:WorkBooks:Open( cDIRARQ+cNomArq ) // Abre uma planilha
        oExcelApp:SetVisible(.T.)
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
 
    //Se tiver em branco o destinatário, o assunto ou o corpo do email
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
 
        //Define se irá utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conexão
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
                //Realiza a autenticação do usuário e senha
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
 
        //Se for para mostrar o log visualmente e for processo com interface com o usuário, mostra uma mensagem na tela
        If lMostraLog .And. ! IsBlind()
            Aviso("Log", cLog, {"Ok"}, 2)
        EndIf
    EndIf
 
    RestArea(aArea)
Return lRet
