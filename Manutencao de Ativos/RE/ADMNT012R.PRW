#INCLUDE "PROTHEUS.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#Include 'TOTVS.ch'
#INCLUDE "topconn.ch"
 #define CRLF Chr(13)+Chr(10)
/*/{Protheus.doc} ADMNT012R - Relatorio de Custo por OS / Eqto Exporta Excel
)
    @type  Function
    @author Tiago Stocco
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
/*/

User Function ADMNT012R(aParam)
Local bProcess 		:= {|oSelf| Executa(oSelf) }
Local cPerg 		:= "ADMNT012R"
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
    cPara      :=  SuperGetMv('ZZ_MNT012R', .f. ,"leonardo.monteiro@adoro.com.br" ) 
    
    oProcess := Executa()
Else
    oProcess := tNewProcess():New("ADMNT012R","Relação SS",bProcess,cTxtIntro,cPerg,aInfoCustom, .T.,5, "Relação SS", .T. )
Endif

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Relatorio de Custo por OS ')

Return

Static Function Executa(oProcess)
Local cQry      := ""
Local cAlias    := GetNextAlias()
Local cBem      := ""
Local cHrTot    := ""
Local cCodExec  := ""
Local cNmExec   := ""

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


oExcel:AddworkSheet("SS") // Planilha
oExcel:AddTable ("SS","RelaSS") // Titulo da Planilha (Cabeçalho)
oExcel:AddColumn("SS","RelaSS","Filial"         ,1,1)
oExcel:AddColumn("SS","RelaSS","NUMSOL"		    ,1,1)
oExcel:AddColumn("SS","RelaSS","TIPOOS"	        ,1,1)
oExcel:AddColumn("SS","RelaSS","CODBEM"	        ,1,1)
oExcel:AddColumn("SS","RelaSS","NOMEBL"		    ,1,1)
oExcel:AddColumn("SS","RelaSS","CCUSTO"		    ,1,1)
oExcel:AddColumn("SS","RelaSS","CENTRA"		    ,1,1)
oExcel:AddColumn("SS","RelaSS","DATABER"	    ,1,1)
oExcel:AddColumn("SS","RelaSS","HORABER"        ,1,1)
oExcel:AddColumn("SS","RelaSS","DATAFEC"        ,1,1)
oExcel:AddColumn("SS","RelaSS","HORAFEC"        ,1,1)
oExcel:AddColumn("SS","RelaSS","ORDEM"          ,1,1)
oExcel:AddColumn("SS","RelaSS","TEMPOAT"		,1,1)
oExcel:AddColumn("SS","RelaSS","CODEXEC"	    ,1,1)
oExcel:AddColumn("SS","RelaSS","EXECUT"		    ,1,1)
//@Ticket 13241 , Data 10/05/2021, TIAGO STOCCO adição do solicitante
oExcel:AddColumn("SS","RelaSS","CODSOLI"	    ,1,1)
oExcel:AddColumn("SS","RelaSS","NOMSOLI"	    ,1,1)

//@Ticket 11502, Data 05/04/2021, Leonardo P. Monteiro, Adição do tipo do cliente na inclusão ou alteração;
oExcel:AddColumn("SS","RelaSS","STATUS"         ,1,1)
oExcel:AddColumn("SS","RelaSS","DESCATIV"       ,1,1)

//@Ticket 13242, Data 26/05/2021, Denis Guedes, Adição do nome do técnico;
oExcel:AddColumn("SS","RelaSS","TECNICO"        ,1,1)


cQry    := " SELECT DISTINCT"+CRLF
cQry    += " TQB_FILIAL,"+CRLF
cQry    += " TQB_SOLICI,"+CRLF
cQry    += " TQB_TIPOSS,"+CRLF
cQry    += " TQB_CODBEM,"+CRLF
cQry    += " TQB_CCUSTO,"+CRLF
cQry    += " TQB_CENTRA,"+CRLF
cQry    += " TQB_DTABER,"+CRLF
cQry    += " TQB_HOABER,"+CRLF
cQry    += " TQB_DTFECH,"+CRLF
cQry    += " TQB_HOFECH,"+CRLF
cQry    += " TQB_ORDEM,"+CRLF
cQry    += " TQB_TEMPO,"+CRLF
cQry    += " TQB_CDSOLI,"+CRLF
cQry    += " TQB_CDEXEC,"+CRLF
cQry    += " TQ4_NMEXEC,"+CRLF
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
cQry    += " '') AS TQB_CODMSS,"+CRLF
cQry    += " CASE WHEN TQB_SOLUCA='A' THEN 'A=Aguardando Analise' WHEN TQB_SOLUCA='D' THEN 'D=Distribuida' WHEN TQB_SOLUCA='E' THEN 'E=Encerrada' WHEN TQB_SOLUCA='C' THEN 'C=Cancelada' ELSE TQB_SOLUCA+'=NA' END TQB_SOLUCA, "+CRLF
cQry    += " T1_NOME "+CRLF
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

cQry    += " WHERE "+CRLF
cQry    += " TQB_DTABER BETWEEN '"+DTOS(dMVPAR01)+"' AND '"+DTOS(dMVPAR02)+"' "+CRLF
cQry    += " AND TQB_FILIAL BETWEEN '"+cMVPAR03+"' AND '"+cMVPAR04+"' "+CRLF
//cQry    += " TQB_DTABER BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
//cQry    += " AND TQB_FILIAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQry    += " AND TQB.D_E_L_E_T_ = ' ' "+CRLF

//Everson - 25/04/2022. Chamado 69385.
cQry    += " UNION ALL "+CRLF

cQry += " SELECT  " +CRLF
cQry += " DISTINCT  " +CRLF
cQry += " TJ_FILIAL, " +CRLF
cQry += " '' AS SOLICI, " +CRLF
cQry += " '' AS TIPOSS, " +CRLF
cQry += " TJ_CODBEM, " +CRLF
cQry += " TJ_CCUSTO, " +CRLF
cQry += " TJ_CENTRAB, " +CRLF
cQry += " TJ_DTORIGI, " +CRLF
cQry += " '' AS HORABE, " +CRLF
cQry += " TJ_DTMRFIM, " +CRLF
cQry += " TJ_HOMRFIM, " +CRLF
cQry += " TJ_ORDEM, " +CRLF

cQry += " CASE WHEN  TJ_TERMINO = 'S' THEN "+CRLF
cQry += " ( "+CRLF
cQry += " SELECT  " +CRLF
cQry += " RIGHT('0000'+RIGHT('00'+CAST(CAST(BASE_SEC.TL_QUANTID AS INT)/3600 AS VARCHAR),2)+ " +CRLF
cQry += " ':'+LEFT(CAST(CAST(BASE_SEC.TL_QUANTID AS INT)%3600/60 AS VARCHAR(2))+'00' ,2) + ':00',10) AS TL_QUANTID  " +CRLF
cQry += " FROM "  +CRLF
cQry += " (  " +CRLF
cQry += " SELECT   "+CRLF
cQry += " SUM(  " +CRLF
cQry += " CASE  "   +CRLF
cQry += " WHEN CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR)) > 0   "   +CRLF
cQry += " THEN    "     +CRLF
cQry += " SUBSTRING(CAST(TL_QUANTID AS VARCHAR),1,CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR))-1)*3600 +   "     +CRLF
cQry += " SUBSTRING(CAST(TL_QUANTID AS VARCHAR),CHARINDEX ('.',CAST(TL_QUANTID AS VARCHAR))+1,10)*60     "  +CRLF
cQry += " ELSE    "    +CRLF
cQry += " TL_QUANTID*3600    "    +CRLF
cQry += " END    "  +CRLF
cQry += " )      " +CRLF
cQry += " AS TL_QUANTID     " +CRLF
cQry += " FROM       "+CRLF   
cQry += " " + RetSqlName("STL") + "   (NOLOCK) AS STL       "   +CRLF
cQry += " WHERE         " +CRLF
cQry += " TL_FILIAL = '" + FWxFilial("STL") + "'     " +CRLF
cQry += " AND TL_ORDEM = TJ_ORDEM      "    +CRLF
cQry += " AND TL_SEQRELA <> '0'    "      +CRLF
cQry += " AND TL_TIPOREG = 'M'       "  +CRLF
cQry += " AND STL.D_E_L_E_T_ = ''    "  +CRLF
cQry += " ) AS BASE_SEC   " +CRLF
cQry += " )   " +CRLF
cQry += " ELSE ''   "+CRLF 
cQry += " END AS TEMPO,   "+CRLF 

cQry += " '' AS CDSOLI, " +CRLF
cQry += " CODEXEC.TL_CODIGO, " +CRLF
cQry += " '' AS NOME, " +CRLF
cQry += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), TJ_OBSERVA)),'') AS TJ_OBSERVA, " +CRLF
cQry += " CASE WHEN TJ_TERMINO = 'S' THEN 'E=Encerrada' ELSE 'D=Distribuida' END, " +CRLF
cQry += " CODEXEC. T1_NOME " +CRLF
cQry += " FROM " +CRLF
cQry += " "+RetSqlName("STJ")+" (NOLOCK) AS STJ " +CRLF

cQry += " LEFT OUTER JOIN "+CRLF
cQry += " ( "+CRLF

cQry += " SELECT TL_FILIAL, TL_ORDEM, TL_CODIGO, T1_NOME"+CRLF
cQry += " FROM " + RetSqlName("STL") + " (NOLOCK) AS STL "+CRLF
cQry += " INNER JOIN "+CRLF
cQry += " " + RetSqlName("ST1") + " (NOLOCK) AS ST1 ON "+CRLF
cQry += " TL_FILIAL = T1_FILIAL "+CRLF
cQry += " AND TL_CODIGO = T1_CODFUNC "+CRLF
cQry += " WHERE "+CRLF
cQry += " TL_FILIAL = '" + FWxFilial("STL") + "' AND TL_SEQRELA = '0' AND TL_TIPOREG = 'M' AND STL.D_E_L_E_T_ = '' AND ST1.D_E_L_E_T_ = '' " +CRLF

cQry += " ) AS CODEXEC ON "+CRLF
cQry += " TJ_FILIAL = CODEXEC.TL_FILIAL "+CRLF
cQry += " AND TJ_ORDEM = CODEXEC.TL_ORDEM "+CRLF

cQry += " WHERE " +CRLF
cQry += " TJ_FILIAL BETWEEN '"+cMVPAR03+"' AND '"+cMVPAR04+"' "+CRLF
cQry += " AND TJ_DTORIGI BETWEEN '"+DTOS(dMVPAR01)+"' AND '"+DTOS(dMVPAR02)+"' "+CRLF
cQry += " AND TJ_SOLICI = '' " +CRLF
cQry += " AND STJ.D_E_L_E_T_ = '' " +CRLF

cQry    += " ORDER BY TQB_FILIAL,TQB_SOLICI "+CRLF

//MemoWrite("c:\TEMP\cQry.txt", cQry)

IF Select (cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf
DbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), cAlias)
DbSelectArea(cAlias)
DbGotop()
If (cAlias)->(!EOF())
	While (cAlias)->(!EOF())

        //Everson - 25/04/2022. Chamado 69385.
        cHrTot   := (cAlias)->TQB_TEMPO
        cCodExec := (cAlias)->TQB_CDEXEC
        cNmExec  := (cAlias)->TQ4_NMEXEC

        cBem        := Posicione("ST9",1,xFilial("ST9")+(cAlias)->TQB_CODBEM,"T9_NOME")
        oExcel:AddRow("SS","RelaSS",{	(cAlias)->TQB_FILIAL    ,;
                                        (cAlias)->TQB_SOLICI    ,;
                                        (cAlias)->TQB_TIPOSS	,;
                                        (cAlias)->TQB_CODBEM	,;
                                        cBem                	,;
                                        (cAlias)->TQB_CCUSTO	,;
                                        (cAlias)->TQB_CENTRA	,;
                                        Stod((cAlias)->TQB_DTABER)	,;
                                        (cAlias)->TQB_HOABER	,;
                                        Stod((cAlias)->TQB_DTFECH)	,;
                                        (cAlias)->TQB_HOFECH	,;
                                        (cAlias)->TQB_ORDEM	    ,;
                                        cHrTot                  ,; //Everson - 25/04/2022. Chamado 69385.
                                        cCodexec             	,; //Everson - 25/04/2022. Chamado 69385.
                                        cNmExec             	,; //Everson - 25/04/2022. Chamado 69385.
                                        (cAlias)->TQB_CDSOLI    ,;
                                        UsrFullName((cAlias)->TQB_CDSOLI),;
                                        (cAlias)->TQB_SOLUCA    ,;
                                        (cAlias)->TQB_CODMSS,;
                                        (cAlias)->T1_NOME    ;
                                        })	// Linha
        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())
    
    If !(lJob)
        cDIRARQ := "c:\temp\"
        cNomArq := "REL_SS_"+cEmpAnt+"_"+cFilAnt+".XLS" 
    Else
        cDIRARQ := "\DATA\"
        cNomArq := "REL_SS_"+czEMP+"_"+czFIL+".XLS"
        cNomZip := "REL_SS_"+czEMP+"_"+czFIL+".ZIP"
    EndIf
	
    
    oExcel:Activate()
	
    If !(lJob)
        MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRARQ+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
	Else
        oExcel:GetXMLFile(cDIRARQ+cNomArq)

        fZip(cDIRARQ+cNomZip,{cDIRARQ+cNomArq})
     	//@Ticket 13242 ini
        cDIRREDE :="\RELATORIO\"
        nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 		
		If FError() == 25 //Arquivo já existe na pasta destino
			FERASE(cDIRREDE+cNomArq) 
            nStatus:= __CopyFile((cDIRARQ+cNomArq),(cDIRREDE+cNomArq)) 
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
        oExcelApp:WorkBooks:Open( cDIRARQ+cNomArq ) // Abre uma planilha
        oExcelApp:SetVisible(.T.)
    Else
        aAdd(aAnexos, cDIRARQ+cNomZip)
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
