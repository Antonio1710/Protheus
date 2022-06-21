#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#include 'fwbrowse.ch'   
#INCLUDE "topconn.ch"
 #define CRLF Chr(13)+Chr(10)
/*/{Protheus.doc} ADMNT012R - Relatorio de Custo por OS / Eqto Exporta Excel
)
    @type  Function
    @author Tiago Stocco..
    @since 20/07/2020
    @version TKT - 7571
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    @see (links_or_references) u_ADMNT012R()
    @Ticket 11502, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
	@Ticket 13241, Data 10/05/2021, TIAGO STOCCO, adição do solicitante
    @Ticket 13242, Data 26/05/2021, DENIS GUEDES, Compatibilizado o relatório para ser envia por email através de Schedule
    @Ticket 13242, Data 26/05/2021, DENIS GUEDES, Incluído a coluna ST1.T1_NOME no relatório
    @Ticket 13242, Data 02/06/2021, DENIS GUEDES, Incluído funcionalidade para copiar a planilha gerada para a pasta "Relatorio"
    @Ticket 69385, Data 25/04/2022, Everson     , Inclusão de OS em SS.
    @Ticket 69385, Data 03/062022, Antonio Domingos, otimização da Query.
    @Ticket 74549, Data 10/06/2022, Antonio Domingos, Otimização da emissão do relaotorio (Módulo no protheus não abre).
    @Ticket 74594, Data 10/062022, Antonio Domingos, Desmembramento do relatorio.
    @Ticket 74929, Data 20/06/2022, Antonio Domingos, Correção do Erro em Relação SS/OS Base de dados Ceres.
    @Ticket 75147, Data 21/06/2022, Antonio Domingos, RELATORIO S.S demora na emissão do relatorio.
/*/

User Function ADMNT012R(aParam)
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT012R "
Local aInfoCustom 	:= {}
Local cTxtIntro	    := "Rotina responsável pela extracao EXCEL da relação das SS"
local lSetEnv       := .f.

cPara      := ""
cAssunto   := "Relação das OS´s em Excel"
cCorpo     := "Relação das OS´s em Excel"
aAnexos    := {}
lMostraLog := .F.
lUsaTLS    := .T.

//Local cEmp 		:= "01"
//Local cFil 		:= "02"

		//RPCClearEnv()
		//RPCSetType(3)
		//RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })		

Private lJob          := IsBlind()
Private oProcess
Private dMVPAR01   
Private dMVPAR02   
Private cMVPAR03   
Private cMVPAR04  
Private nMVPAR05
Private czEMP
Private czFIL


//Aadd(aInfoCustom,{"Visualizar",{|oCenterPanel| visualiza(oCenterPanel)},"WATCH" })
//Aadd(aInfoCustom,{"Relatorio" ,{|oCenterPanel| Relat(oCenterPanel) },"RELATORIO"})

If lJob
	RpcSetType(3)
	lSetEnv  := RpcSetEnv(aParam[1],aParam[2],,,"")
    czEMP    := aParam[1]   
    czFIL    := aParam[2]   
    
    PREPARE ENVIRONMENT EMPRESA czEMP FILIAL czFIL MODULO "EST"
    cPara      :=  SuperGetMv('ZZ_MNT012R', .f. ,"antonio.filho@adoro.com.br" ) 
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADMNT012R","Relação SS",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Relação SS", .T. )
Endif

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Custo por OS ')

Return

Static Function Executa(oProcess)
Local cQry      := ""
Local cAlias    := GetNextAlias()
Local _cHrTot    := ""
Local _cCodExec  := ""
Local _cNmExec   := ""
Local cTimeNow  := ""
Local cDirLocal := "C:\TEMP\"
Local _cPlanilha := "SS"
Local _cTitulo   := "RelaçãoSS"
Local _nCount

Private oExcel  	:= FwMsExcel():New()
Private dDataIni	
Private dDataFim
Private cNomArq
Private cDIRARQ
Private cDIRREDE


If lJob
    //Solicitado pelo usuário que sem venha listado 2 anos de OS.
    //dMVPAR01	:= ctod("01/01/2019")
    dMVPAR01	:= YearSub(Date(), 2)
    dMVPAR02	:= date()
    cMVPAR03    := czFIL
    cMVPAR04    := czFIL
Else
    dMVPAR01	:= MV_PAR01
    dMVPAR02	:= MV_PAR02
    cMVPAR03	:= MV_PAR03
    cMVPAR04	:= MV_PAR04
EndIf

oExcel:AddworkSheet(_cPlanilha) // Planilha
oExcel:AddTable (_cPlanilha,_cTitulo) // Titulo da Planilha (Cabeçalho)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Filial"         ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"NUMSOL"		    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"TIPOOS"	        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"CODBEM"	        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"NOMEBL"		    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"CCUSTO"		    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"CENTRA"		    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"DATABER"	    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"HORABER"        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"DATAFEC"        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"HORAFEC"        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"ORDEM"          ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"TEMPOAT"		,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"CODEXEC"	    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"EXECUT"		    ,1,1)
//@Ticket 13241 , Data 10/05/2021, TIAGO STOCCO adição do solicitante
oExcel:AddColumn(_cPlanilha,_cTitulo,"CODSOLI"	    ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"NOMSOLI"	    ,1,1)

//@Ticket 11502, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
oExcel:AddColumn(_cPlanilha,_cTitulo,"STATUS"         ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"DESCATIV"       ,1,1)

//@Ticket 13242, Data 26/05/2021, Denis Guedes, Adição do nome do técnico;
oExcel:AddColumn(_cPlanilha,_cTitulo,"TECNICO"        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"SERVICO"        ,1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"NOMESER"        ,1,1)

    cQry    := " SELECT "
    //cQry    += " DISTINCT"+CRLF
    cQry    += " TQB_FILIAL AS FILIAL,"+CRLF
    cQry    += " TQB_SOLICI AS SOLICI,"+CRLF
    cQry    += " TQB_TIPOSS AS TIPOSS,"+CRLF
    cQry    += " TQB_CODBEM AS CODBEM,"+CRLF
    cQry    += " TQB_CCUSTO AS CCUSTO,"+CRLF
    cQry    += " TQB_CENTRA AS CENTRA,"+CRLF
    cQry    += " TQB_DTABER AS DTABER,"+CRLF
    cQry    += " TQB_HOABER AS HOABER,"+CRLF
    cQry    += " TQB_DTFECH AS DTFECH,"+CRLF
    cQry    += " TQB_HOFECH AS HOFECH,"+CRLF
    cQry    += " TQB_ORDEM  AS ORDEM,"+CRLF
    cQry    += " TQB_TEMPO  AS TEMPO,"+CRLF
    cQry    += " TQB_CDSOLI AS CDSOLI,"+CRLF
    cQry    += " TQB_CDEXEC AS CDEXEC,"+CRLF
    cQry    += " TQ3_NMSERV AS NMEXEC,"+CRLF
    //@Ticket 11502, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
    cQry    += " ISNULL("+CRLF
    cQry    += "     CONVERT(VARCHAR(400), ("+CRLF
    cQry    += "     SELECT"+CRLF
    cQry    += "     RTRIM(SYP.YP_TEXTO)"+CRLF
    cQry    += " FROM"+CRLF
    cQry    += "     SYP010 SYP"+CRLF
    cQry    += "     WHERE"+CRLF
    cQry    += "     SYP.YP_CHAVE = TQB_CODMSS"+CRLF
    cQry    += "     AND SYP.YP_CAMPO = 'TQB_CODMSS'"+CRLF
    cQry    += "     AND SYP.D_E_L_E_T_ = ' '"+CRLF
    cQry    += "     ORDER BY"+CRLF
    cQry    += "     YP_SEQ"+CRLF
    cQry    += "     FOR XML PATH ('')"+CRLF
    cQry    += "     )),"+CRLF
    cQry    += " '') AS CODMSS,"+CRLF
    cQry    += " CASE WHEN TQB_SOLUCA='A' THEN 'A=Aguardando Analise' WHEN TQB_SOLUCA='D' THEN 'D=Distribuida' WHEN TQB_SOLUCA='E' THEN 'E=Encerrada' WHEN TQB_SOLUCA='C' THEN 'C=Cancelada' ELSE TQB_SOLUCA+'=NA' END AS SOLUCA, "+CRLF
    cQry    += " T1_NOME AS NOME, "+CRLF
    cQry    += " TQB_CDSERV AS SERVICO, "+CRLF
    cQry    += " TQ3.TQ3_NMSERV AS NOMESER, "+CRLF
    cQry    += " ST9.T9_NOME AS NOMBEM "+CRLF
    cQry    += " FROM "+RetSqlName("TQB")+" (NOLOCK) TQB " +CRLF
    cQry    += " INNER JOIN "+RetSqlName("TQ4")+" (NOLOCK) TQ4 ON " +CRLF
    cQry    += " TQB_FILIAL = TQ4_FILIAL "+CRLF
    cQry    += " AND TQB_CDEXEC = TQ4_CDEXEC "+CRLF
    cQry    += " AND TQ4.D_E_L_E_T_ = ' ' "+CRLF
    //cQry    += " LEFT JOIN "+RetSqlName("ST1")+" (NOLOCK) ST1 ON " 
    //cQry    += " TQB_FILIAL = T1_FILIAL "
    //cQry    += " AND TQB_CDEXEC = T1_CODFUNC "
    //cQry    += " AND ST1.D_E_L_E_T_ = ' ' "
    cQry    += " LEFT JOIN "+RetSqlName("STL")+" (NOLOCK) STL ON "+CRLF // Inicio Ticket TI   , Data 10/06/2021, ADRIANO SAVOINE
    cQry    += " TQB_FILIAL = TL_FILIAL "+CRLF
    cQry    += " AND TL_ORDEM = TQB_ORDEM "+CRLF
    cQry    += " AND STL.D_E_L_E_T_ = '' "+CRLF
    cQry    += " LEFT JOIN "+RetSqlName("ST1")+" (NOLOCK) ST1 ON  "+CRLF
    cQry    += " T1_FILIAL = TL_FILIAL "+CRLF
    cQry    += " AND T1_CODFUNC = TL_CODIGO "+CRLF
    cQry    += " AND ST1.D_E_L_E_T_ = ' '  "+CRLF                        // Fim    Ticket TI   , Data 10/06/2021, ADRIANO SAVOINE
    cQry += " LEFT JOIN " + RetSqlName("TQ3") + " (NOLOCK) AS TQ3  "+CRLF
	cQry += " ON TQ3.TQ3_FILIAL = TQB_FILIAL "+CRLF
	cQry += " AND TQ3.TQ3_CDSERV = TQB_CDSERV "+CRLF
	cQry += " AND TQ3.D_E_L_E_T_ = ' ' "+CRLF
    cQry += " LEFT JOIN " + RetSqlName("ST9") + " (NOLOCK) AS ST9 "+CRLF
	cQry += " ON T9_FILIAL = TQB_FILIAL "+CRLF
	cQry += " AND T9_CODBEM = TQB_CODBEM "+CRLF
    cQry += " AND ST9.D_E_L_E_T_ = '' " +CRLF
    cQry    += " WHERE "+CRLF
    cQry    += " TQB_DTABER BETWEEN '"+DTOS(dMVPAR01)+"' AND '"+DTOS(dMVPAR02)+"' "+CRLF
    cQry    += " AND TQB_FILIAL BETWEEN '"+cMVPAR03+"' AND '"+cMVPAR04+"' "+CRLF
    //cQry    += " TQB_DTABER BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
    //cQry    += " AND TQB_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
    cQry    += " AND TQB.D_E_L_E_T_ = ' ' "+CRLF
    //Everson - 25/04/2022. Chamado 69385.

    MemoWrite("c:\TEMP\cQry_"+_cPlanilha+".sql", cQry)

IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
(cAlias)->(DbGotop())
        
If (cAlias)->(!EOF())
	
    While (cAlias)->(!EOF())

        //Everson - 25/04/2022. Chamado 69385.
        oExcel:AddRow(_cPlanilha,_cTitulo,{	(cAlias)->FILIAL,;
                                            (cAlias)->SOLICI,;
                                            (cAlias)->TIPOSS,;
                                            (cAlias)->CODBEM,;
                                            (cAlias)->NomBem,;
                                            (cAlias)->CCUSTO,;
                                            (cAlias)->CENTRA,;
                                            Stod((cAlias)->DTABER),;
                                            (cAlias)->HOABER,;
                                            Stod((cAlias)->DTFECH),;
                                            (cAlias)->HOFECH,;
                                            (cAlias)->ORDEM,;
                                            (cAlias)->TEMPO,;    //Everson - 25/04/2022. Chamado 69385.
                                            (cAlias)->CDEXEC,;  //Everson - 25/04/2022. Chamado 69385.
                                            (cAlias)->NMEXEC,;   //Everson - 25/04/2022. Chamado 69385.
                                            (cAlias)->CDSOLI,;
                                            UsrFullName((cAlias)->CDSOLI),;
                                            (cAlias)->SOLUCA,;
                                            (cAlias)->CODMSS,;
                                            (cAlias)->NOME,;
                                            (cAlias)->SERVICO,;
                                            (cAlias)->NOMESER})	// Linha
            (cAlias)->(DbSkip())
    
    EndDo
        
    (cAlias)->(DbCloseArea())
    
    If !(lJob)
        cTimeNow   := TIME()
        cDIRREDE := "\rel_mnt\"
        cNomArq := "REL_"+_cPlanilha+"_"+cEmpAnt+"_"+cFilAnt+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".XLS" 
    Else
        cTimeNow   := TIME()
        cDIRREDE:= "\rel_mnt\"
        cNomArq := "REL_"+_cPlanilha+"_"+czEMP+"_"+czFIL+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".XLS"
        cNomZip := "REL_"+_cPlanilha+"_"+czFIL+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".ZIP"
    EndIf
    
    oExcel:Activate()
	
    If !(lJob)
        MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRREDE+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
        __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 		
	Else
        oExcel:GetXMLFile(cDIRREDE+cNomArq)

        fZip(cDIRARQ+cNomZip,{cDIRREDE+cNomArq})
     	//@Ticket 13242 ini
        cDIRREDE :="\rel_mnt\"
        nStatus:= __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 		
		If FError() == 25 //Arquivo já existe na pasta destino
			//FERASE(cDIRREDE+cNomArq) 
            nStatus:= __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 
		EndIf
        //@Ticket 13242 fim
    Endif
    // oExcel:WorkBooks:Open(cNomArq) 	// Abre uma planilha
	// oExcel:SetVisible(.T.) 			// visualiza a planilha
	// apresenta a planilha gerada                      
	// oExcel:OpenXML(cNomArq) 
	oExcelApp:=MsExcel():New()                                         
	
    //If !(lJob) //Denis - voltar
    If !(lJob)
        oExcelApp:WorkBooks:Open( cDIRLOCAL+cNomArq ) // Abre uma planilha
        oExcelApp:SetVisible(.T.)
    Else
        aAdd(aAnexos, cDIRLOCAL+cNomZip)
        fEnvMail(cPara, cAssunto, cCorpo, aAnexos, lMostraLog, lUsaTLS)
	EndIf
       
EndIf

Return

//Denis email//
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
