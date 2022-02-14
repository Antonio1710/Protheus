#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} ADFIN126P
  Funcao generica para envio de email     
  @type function
  @version  
  @author Rodrigo Mello [rodrigo@flek.solutions]
  @since 11/01/2022
/*/

/*
  MV_RELSERV   Nome do servidor de envio de e-mail (SMTP) utilizado no envio
  MV_RELACNT	 Conta a ser utilizada no envio
  MV_RELPSW	 Senha da conta de e-mail utilizada no envio
  MV_RELAUTH	 Servidor de e-mail necessita de autenticação
  MV_RELTLS	 Utilizar ou não conexão segura TLS
  MV_RELSSL	 Utilizar ou não conexão segura SSl
  MV_RELAUSR	 Conta a ser utilizada para autenticação SMTP
  MV_RELAPSW	 Senha da conta de e-mail para autenticação SMTP
*/
//-----------------------------------------------------------------------------
User Function ADFIN126P(cFrom,cTo,cCc,cBcc,cSubject,cBody,aAttach,aAccount,aSmtp)
//-----------------------------------------------------------------------------
  Local oMail, oMessage
  Local nErro          
  Local aSplPath := Array(4)         
  Local i
  
  DEFAULT cFrom    := GetMV('MV_RELFROM')
  DEFAULT cTo      := ''
  DEFAULT cCc      := ''
  DEFAULT cBcc     := '' 
  DEFAULT cSubject := ''
  DEFAULT cBody    := ''
  DEFAULT aAttach  := {}
  DEFAULT aAccount := { GetMV('MV_RELACNT') , GetMV('MV_RELPSW') }
  DEFAULT aSmtp    := StrTokArr (AllTrim(GetMV('MV_RELSERV')) , ":" )
              
  oMail := tMailManager():New()
  oMail:SetUseSSL( .f. /*GetMV('MV_RELSSL')*/ )
  oMail:SetUseTLS( .t. /*GetMV('MV_RELTLS')*/ )
   
  oMail:Init( '', aSmtp[1], aAccount[1], aAccount[2],0,Val(aSmtp[2]))   
  conout( 'Conectando do SMTP' )
  nErro := oMail:SmtpConnect()   
  
  If nErro <> 0
    conout( "ERROR:" + oMail:GetErrorString( nErro ) )
    oMail:SMTPDisconnect()
    return .F.
  Endif

  nErro := oMail:SetSMTPTimeout( 120 )
  If nErro <> 0
    conout( "ERROR:" + oMail:GetErrorString( nErro ) )
    oMail:SMTPDisconnect()
    return .F.
  Endif

  //If GetMV('MV_RELAUTH')
	  nErro := oMail:SmtpAuth( aAccount[1] , aAccount[2] )
  //EndIf
  
  If nErro <> 0
    conout( "ERROR:" + oMail:GetErrorString( nErro ) )
    oMail:SMTPDisconnect()
    return .F.
  Endif
  oMessage := tMailMessage():New()
  oMessage:Clear()     
  oMessage:cFrom                  := cFrom
  oMessage:cTo                    := cTo
  oMessage:cCc                    := cCc
  oMessage:cBcc                   := cBcc
  oMessage:cSubject               := cSubject
  oMessage:cBody                  := cBody

  for i:=1 to len(aAttach)
    If oMessage:AttachFile( aAttach[i][1] ) < 0
      Conout( "Erro ao atachar o arquivo" + aAttach[i][1] )
      Return .F.
    Else
      SplitPath(aAttach[i][1] , @aSplPath[1], @aSplPath[2], @aSplPath[3], @aSplPath[4]) 
      oMessage:AddAtthTag( 'Content-Disposition: attachment; filename="' + lower(aSplPath[3]) + lower(aSplPath[4])+'"' )
      oMessage:AddAtthTag( 'Content-ID:<'+aAttach[i][2]+'>' )
      Conout("Attach successful")
    EndIf
  next i

  nErro := oMessage:Send( oMail )
  
  If nErro <> 0
    conout( "ERROR:" + oMail:GetErrorString( nErro ) )
    oMail:SMTPDisconnect()
    Return .F.
  Endif
  conout( 'Desconectando do SMTP' )
  oMail:SMTPDisconnect()

  //
  U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Funcao generica para envio de email')
  //
  
Return .T.

