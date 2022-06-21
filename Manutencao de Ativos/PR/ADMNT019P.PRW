
#INCLUDE "TOTVS.CH"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "Topconn.ch"
#DEFINE CRLF CHR(13)+CHR(10) 
//---------------------------------------------------------------------
/*/{Protheus.doc} ADMNT019P
Importacao de Executantes para atribuição a ordem de serviço
@author Antonio Domingos
@since 21/06/2022
@version 1.0
@type User Function. 
@Ticket 62638, Data 21/06/2022, Antonio Domingos, Direcionamento de OS preventiva para os executante
/*/
//---------------------------------------------------------------------
User Function ADMNT019P()

//Delimitado por ";", SEM linha de cabecalho
/*
1=Ordem Serv.	
2=Plano Manut.
3=Bem	
4=Nome do Bem
5=Servico
6=Nome Servico	
7=P.In.Man.	
8=Responsavel
*/

Local _nTamLin 	:= 100            		// Tamanho da linha no arquivo texto
Local _nHdl    	:= Nil           		// Handle para abertura do arquivo
Local _cBuffer 	:= Space(_nTamLin+1) 	// Variavel para leitura
//Local _nBytes  	:= 0                	// Variavel para verificacao do fim de arquivo
//Local _cFileLog 	:= ""                   // Arquivo para gravacao do log de execucao da rotina
//Local _cPath 		:= ""  					//caminho onde sera gravado o arquivo de LOG
//Local _nQtChar 	:= 2
Local _cDelimit	    := ";"                 //Delimitador do arquivo CSV
Private _cPerg		:= PADR("ADMNT019P",10," ") //Perguntas do relatorio
Private _cArq    	:= MV_PAR01      		// Arquivo texto a importar
Private _cTipoRel   := " "                  //Tipo de Processamento - Importação/Simulação
Private _lJob       := .f.

ValidPerg()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importacao de Ordem de Serviços de Vendedores na tabela STJ')

if Pergunte(_cPerg,.T.)
	_cArq    	:= MV_PAR01      		// Arquivo texto a importar
	_cTipoRel  := " "
    
    If MV_PAR02 == 1  //1=Importação
        _cTipoRel := "Importação" 
    else
        _cTipoRel := "Simulação"    
    EndIf
	
    If MsgBox(OemToAnsi("Confirma importação de Executantes "+Alltrim(_cArq)+" para Alteração de OS? "),"ATENCAO","YESNO")
		_nHdl := fOpen(_cArq,2) // Abre o arquivo
		fClose(_nHdl)
		If _nHdl == -1
			Aviso( "AVISO",OemToAnsi("Não foi possível abrir o arquivo "+_cArq),{"Sair"} )
		else
			Processa({|| ImpCSVMS(_cBuffer,_cArq,_cDelimit)})
		endif
	endif
Endif

Return
//---------------------------------------------------------------------
/*/{Protheus.doc} ImpCSVMS(_cBuffer,_cArq) 
Importacao de Ordem de Serviços de Vendedores na tabela STJ
@author Antonio Domingos
@since 22/12/11
@version 1.0
@type User Function. 
@Ticket 8122, Data 20/06/2022, Antonio Domingos, Otimização do processo de Importação de Ordem de Serviço. Solicitado por DANILO KROLL
/*/
//---------------------------------------------------------------------
Static Function ImpCSVMS(_cBuffer,_cArq,_cDelimit)

Local _nCmp,_nLin,I,_lArqOk,_cTxtPos
Local _cFilal,_cOrdemServ,_cPlanoManut,_cBem,_cNomedoBem,_cServico,_cNomeServico,_dPInMan,_cResponsavel
Local cDirLocal := "C:\TEMP\"
Local _cPlanilha := "Relação"
Local _cTitulo   := "Executantes das Ordens de Serviços"
Local cPara      := SuperGetMv('MV_XMNT019', .f. ,"antonio.filho@adoro.com.br" ) 
Local cAssunto   := "Importacao de Executantes das Ordem de Serviços tabela STJ"
Local _cHtml     := ""
Local aAnexos    := {}
Local lMostraLog := .F.
Local lUsaTLS    := .T.

private oExcel  	:= FwMsExcel():New()
private cNomArq
private cDIRARQ
private cDIRREDE

oExcel:AddworkSheet(_cPlanilha) // Planilha
oExcel:AddTable (_cPlanilha,_cTitulo) // Titulo da Planilha (Cabeçalho)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Filial",1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Ordem Serv",1,1)	
oExcel:AddColumn(_cPlanilha,_cTitulo,"Plano Manut",1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Bem",1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Nome do Bem",1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Servico",1,1)
oExcel:AddColumn(_cPlanilha,_cTitulo,"Nome Servico",1,1)	
oExcel:AddColumn(_cPlanilha,_cTitulo,"P.In.Man.",1,1)	
oExcel:AddColumn(_cPlanilha,_cTitulo,"Responsavel",1,1)

Dbgotop()

ft_fUse(_cArq) 	//Abre o arquivo

ProcRegua(RecCount())
ft_fGoTop()		//Posiciona no inicio do arquivo
_nLin := 1

Do While !ft_fEOF()
	_lArqOk := .T.
	_cBuffer := ft_fReadLn()
	_nCmp := 1


	FOR I := 1 TO 5
		_cTxtPos := Substr(_cBuffer,1,At(_cDelimit, _cBuffer)-1)
		if _nCmp = 1
			_cOrdemServ    := _cTxtPos
		elseif _nCmp = 2
			_cPlanoManut := _cTxtPos
		elseif _nCmp = 3
			_cBem := _cTxtPos
		elseif _nCmp = 4
			_cNomedoBem := _cTxtPos
		elseif _nCmp = 5
			_cServico := _cTxtPos
		elseif _nCmp = 5
			_cNomeServico := _cTxtPos
		elseif _nCmp = 5
			_dPInMan := ctod(_cTxtPos)
		elseif _nCmp = 6
			_cResponsavel := _cTxtPos
		endif
		_cBuffer := Substr(_cBuffer,At(";", _cBuffer)+1)
		_nCmp++
	Next
	
	IncProc("Importando : "+_cVendedor + " Grupo: " + _cGrupo + " Data: "+DTOC(_dData))
	
	//Antonio Domingos - 21/06/2022 - ticket 62638
	If mv_par02 == 1 //Importação
        
            dbSelectArea("STJ")
            dbSetOrder(1) 
            // Verifica se ja tem esta Ordem de Serviço
            // Caso tenha altera a OS.
            //1-TJ_FILIAL+TJ_ORDEM+TJ_PLANO+TJ_TIPOOS+TJ_CODBEM+TJ_SERVICO+TJ_SEQRELA
            _cTIPOOS  := "B"
            _cSEQRELA := "0"
            If dbseek(_cFILIAL+_cOrdemServ+_cPlanoManut+_cTIPOOS+_cBem+_cServico+_cSEQRELA)        //Vendedor+supervisor+grupo+data
                
                //RecLock("STJ",.F.)
                // Atribuição do executante na Ordem de Serviço VOLUME
                //STJ->TJ_DTMPINI := _dPInMan
                //STJ->TJ_        := _cResponsavel
                //MSUNLOCK()
               
            Endif
            
        
    Endif
 	
	oExcel:AddRow(_cPlanilha,_cTitulo,{	_cFilal,;
                                        _cOrdemServ,;	
                                        _cPlanoManut,;
                                        _cBem,;	
                                        _cNomedoBem,;
                                        _cServico,;
                                        _cNomeServico,;	
                                        _dPInMan,;	
                                        _cResponsavel})

	ft_fSkip()
	_nLin ++
	
EndDo

If !(_lJob)
    cTimeNow   := TIME()
    cDIRREDE := "\spool\"
    cNomArq := "REL_"+_cPlanilha+"_"+cEmpAnt+"_"+cFilAnt+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".XLS" 
Else
    cTimeNow   := TIME()
    cDIRREDE:= "\temp\"
    cNomArq := "REL_"+_cPlanilha+"_"+czEMP+"_"+czFIL+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".XLS"
    cNomZip := "REL_"+_cPlanilha+"_"+czFIL+"_"+DTOS(dDatabase)+"_"+STRTRAN(cTimeNow,":","")+".ZIP"
EndIf
    
oExcel:Activate()                                        
	
	_cHtml += '<html>'
	_cHtml += '<head>'
	_cHtml += '	<title>Editor HTML Online</title>'
	_cHtml += '</head>'
	_cHtml += '<body>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		<strong>Importacao dos Executantes das Ordens de Serviços na tabela STJ</strong></div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		&nbsp;</div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		<strong>Parametros</strong>:</div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		&nbsp;</div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		<strong><span style="color:#000080;">Importar do Arquivo CSV ?</span></strong> <strong>'+Alltrim(_cArq)+'</strong></div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		&nbsp;</div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		<span style="color:#0000cd;"><strong>Tipo Processamento?</strong></span> <strong>'+_cTipoRel+'</strong></div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		&nbsp;</div>'
	_cHtml += '	<div style="text-align: left;">'
	_cHtml += '		&nbsp;</div>'
	_cHtml += '</body>'
    _cHtml += '</html>'

	
If !(_lJob)
    MsAguarde({||Processa({|| oExcel:GetXMLFile(cDIRREDE+cNomArq) })},"Processanento", "Gerando arquivo XML, aguarde....")
    __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 		
Else
    oExcel:GetXMLFile(cDIRREDE+cNomArq)

    fZip(cDIRARQ+cNomZip,{cDIRREDE+cNomArq})
	cDIRREDE :="\spool\"
 	nStatus:= __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 		
	If FError() == 25 //Arquivo já existe na pasta destino
			//FERASE(cDIRREDE+cNomArq) 
       nStatus:= __CopyFile((cDIRREDE+cNomArq),(cDIRLOCAL+cNomArq)) 
	EndIf
Endif
    // oExcel:WorkBooks:Open(cNomArq) 	// Abre uma planilha
	// oExcel:SetVisible(.T.) 			// visualiza a planilha
	// apresenta a planilha gerada                      
	// oExcel:OpenXML(cNomArq) 
oExcelApp:=MsExcel():New()                                         
	
If !(_lJob)
    //oExcelApp:WorkBooks:Open( cDIRLOCAL+cNomArq ) // Abre uma planilha
    //oExcelApp:SetVisible(.T.)
    aAdd(aAnexos, cDIRREDE+cNomArq)
    fEnvMail(cPara, cAssunto, _cHtml, aAnexos, lMostraLog, lUsaTLS)
Else
	aAdd(aAnexos, cDIRREDE+cNomArq)
    fEnvMail(cPara, cAssunto, _cHtml, aAnexos, lMostraLog, lUsaTLS)
EndIf

iF _lArqOk
	msgInfo("Processamento concluido com sucesso!")
endIf

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VALIDPERG ºAutor  ³ADRIANA - HC        º Data ³  27/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Para incluir perguntas no SX1                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg

PutSx1(_cPerg,"01","Importar do Arquivo CSV ?","Importar do Arquivo ?","Importar do Arquivo ?","mv_ch1","C",50,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","","","","")
PutSX1(_cPerg,"02","Tipo Processamento      ?","Tipo Processamento  ?","Tipo Processamento  ?","mv_ch2","N",01,0,1,"C","","","","","mv_par02", "Importação","","","","Simulação","","","","","","","","","","","",,,)


Return

//---------------------------------------------------------------------
/*/{Protheus.doc} fEnvMail 
Função de envio de e-mail do relatorio
@author Antonio Domingos
@since 18/05/2022
@version undefined
@type Static Function
/*/
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
