#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FILEIO.CH'

#define IMAP 1

/*/{Protheus.doc} User Function ADFIS044P
  Painel de controle de email de NFSE
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  @version 1
  @history Chamado n.059816 - Abel Babini - 24/08/2020 - Versão Inicial
  @history Ticket  n.    24 - Abel Babini - 01/09/2020 - Correção no filtro de anexos pela extensão

  /*/

User Function ADFIS044P()   
  Local aArea := GetArea()

  // Instanciamento da Classe de Browse 
	oBrowse := FWMBrowse():New() 
	 
	// Definição da tabela do Browse 
	oBrowse:SetAlias('ZG3') 

  // Definição da legenda 
	oBrowse:AddLegend( "ZG3_ANEXOS == 0", "RED", "Falta XML"  ) 
  oBrowse:AddLegend( "ZG3_ANEXOS != 0", "GREEN", "XML anexo"  ) 

	// Titulo da Browse 
	oBrowse:SetDescription('Caixa de Entrada e-mail NFSE XML') 
	 
	// Opcionalmente pode ser desligado a exibição dos detalhes 
	//oBrowse:DisableDetails() 
	 
	// Ativação da Classe 
	oBrowse:Activate() 

  RestArea(aArea)
Return

/*/{Protheus.doc} User Function ModelDef
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function ModelDef() 
               
	// Cria a estrutura a ser usada no Modelo de Dados 
	Local oStruZG3 := FWFormStruct( 1, 'ZG3' ) 
	Local oModel // Modelo de dados que será construído 
	  
	// Cria o objeto do Modelo de Dados 
	oModel := MPFormModel():New( '_FIS044P' )           
	 
	// Adiciona ao modelo um componente de formulário 
	oModel:AddFields( 'ZG3MASTER', /*cOwner*/, oStruZG3 )
	
	oModel:SetPrimaryKey( { "ZG3_FILIAL", "ZG3_CODIGO" } )       
	        
	// Adiciona a descrição do Modelo de Dados 
	oModel:SetDescription( 'Caixa de Entrada e-mail NFSE XML' )
	 
	// Adiciona a descrição do Componente do Modelo de Dados 
	oModel:GetModel( 'ZG3MASTER' ):SetDescription( 'Caixa de Entrada' )  
      
// Retorna o Modelo de dados 
Return oModel     

/*/{Protheus.doc} User Function ViewDef
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function ViewDef()                                                         

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado 
	Local oModel := FWLoadModel( 'ADFIS044P' )        
	
	// Cria a estrutura a ser usada na View 
	Local oStruZG3 := FWFormStruct( 2, 'ZG3' ) 
	 
	// Interface de visualização construída 
	Local oView   
	
	// Cria o objeto de View 
	oView := FWFormView():New() 
	 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
    
	// Adiciona no nosso View um controle do tipo formulário  
	// (antiga Enchoice) 
	oView:AddField( 'VIEW_ZG3', oStruZG3, 'ZG3MASTER' ) 
	   
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEW_ZG3', 'TELA' )  
	
	//Colocando título do formulário
	
	oView:EnableTitleView('VIEW_ZG3', 'Caixa de Entrada NFSE XML' )  
	
    //Força o fechamento da janela na confirmação
	
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	
	oView:SetOwnerView("VIEW_ZG3","TELA")

// Retorna o objeto de View criado 	
Return oView 

/*/{Protheus.doc} User Function MenuDef
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function MenuDef() 

	Local aRotina := {}  
	
		ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'U_PFIS044'           OPERATION 1                      ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.ADFIS044P'   OPERATION MODEL_OPERATION_VIEW   ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Legenda'    ACTION 'U_LFIS044'           OPERATION 6                      ACCESS 0 DISABLE MENU
		ADD OPTION aRotina TITLE 'Importar'   ACTION 'U_FIS044ML'          OPERATION MODEL_OPERATION_INSERT ACCESS 0 DISABLE MENU
  
Return aRotina     

/*/{Protheus.doc} User Function LFIS044
  Legenda da Rotina
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
User FUNCTION LFIS044()
    LOCAL aLegenda := {}

    //Monta as cores
    AADD(aLegenda,{"BR_VERMELHO",   "Falta XML"})
    AADD(aLegenda,{"BR_VERDE",   "XML anexo"})

    BrwLegenda("Caixa de Entrada NFSE XML", "Legenda", aLegenda) 
    
RETURN(NIL)

/*/{Protheus.doc} User Function PFIS044
  Pesquisa da Rotina
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
User FUNCTION PFIS044()
  Local aArea := GetArea()
  
	Private dDtIniMl:= CTOD('01/01/'+Alltrim(Str(Year(dDatabase))))  //Data Inicial
  Private dDtFinMl:= dDatabase  //Data Final
  Private cTxtMl  := Space(200)  //Texto
  Private cXML    := ''
  Private cQryTxt
  Private oDlgAtB
  Private aBrw01Rs  := {} //Array(1,6)
  Private oBrw01Rs
  Private nAt
  Private oXML
  Private oDlgAtB

	DEFINE MSDIALOG oDlgAtB TITLE "Relação de E-mails com XML´s encontrados" FROM 000, 000  TO 540, 640 COLORS 0, 16777215 PIXEL
	oDlgAtB:lEscClose     := .T. //Permite sair ao se pressionar a tecla ESC.

 	@ 005,010 SAY OemToAnsi('Data Inicial')	SIZE 030,025 	OF oDlgAtB COLORS 0 PIXEL
	@ 005,050 MSGET dDtIniMl				        SIZE 060,008	OF oDlgAtB PIXEL PICTURE '@!' VALID VerData(dDtIniMl)
	
	@ 005,120 SAY OemToAnsi('Data Final')	  SIZE 030,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 005,160 MSGET dDtFinMl					      SIZE 060,008	OF oDlgAtB PIXEL  PICTURE '@!' VALID VerData(dDtFinMl)
	
	@ 020,010 SAY OemToAnsi('Texto')	      SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL
	@ 020,050 MSGET cTxtMl					        SIZE 240,008	OF oDlgAtB PIXEL  PICTURE '@!'
	
  DEFINE SBUTTON oBtnOK 	FROM 005, 260 TYPE 01 OF oDlgAtB ENABLE Action( FndRegs() )
	DEFINE SBUTTON oBtnCan 	FROM 005, 290 TYPE 02 OF oDlgAtB ENABLE Action( oDlgAtB:End() )

	oBrw01Rs:= TcBrowse():New(035,010,305,120,,,,oDlgAtB,,,,,,,,,,,,.f.,,.t.,,.f.,,,,)
	oBrw01Rs:AddColumn( TcColumn():New( "# Msg"	          , {|| aBrw01Rs[oBrw01Rs:nAt,01]}	, "@!"					,,,"LEFT"	,025,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Data"	          , {|| aBrw01Rs[oBrw01Rs:nAt,02]}	, "@!"					,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Hora"	          , {|| aBrw01Rs[oBrw01Rs:nAt,03]}	, "@!"					,,,"LEFT"	,030,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Num XMLs anexo"  , {|| aBrw01Rs[oBrw01Rs:nAt,04]}	, "@!"					,,,"LEFT"	,050,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Remetente"	      , {|| aBrw01Rs[oBrw01Rs:nAt,05]}	, "@!"					,,,"LEFT"	,100,.f.,.f.,,,,.f.,) )     					
	oBrw01Rs:AddColumn( TcColumn():New( "Assunto"		      , {|| aBrw01Rs[oBrw01Rs:nAt,06]}	, "@!"					,,,"LEFT"	,100,.f.,.f.,,,,.f.,) )     					

	oBrw01Rs:SetArray(aBrw01Rs)
	oBrw01Rs:bLine := {||{ 	aBrw01Rs[oBrw01Rs:nAt]}}
  oBrw01Rs:bSeekChange := {||LoadXML() }

  @ 157,010 SAY OemToAnsi('XML:')	      SIZE 150,025 	OF oDlgAtB COLORS 0, 16777215 PIXEL

  oXML := tMultiget():new(165,010, {|u| iif( pCount() > 0, cXML := u, cXML ) }, oDlgAtB, 305, 100, , , , , , .T. )
  oXML:EnableVScroll( .T. )

	ACTIVATE MSDIALOG oDlgAtB CENTERED

  RestArea(aArea)
RETURN(NIL)

/*/{Protheus.doc} Static Function LoadXML
  (long_description)
  @type  Static Function
  @author Abel Babini
  @since 18/08/2020
  /*/
Static Function LoadXML()
  cXML := ''
  IF Len(aBrw01Rs) > 0
    IF ZG3->(MsSeek(xFilial('ZG3')+aBrw01Rs[oBrw01Rs:nRowPos,1],.T.))
      cXML := SUBSTR(ZG3->ZG3_FILE,1,1048575)
    ENDIF
  ENDIF
  oXML:Refresh(.T.)

  oDlgAtB:Refresh(.T.)
Return .T.

/*/{Protheus.doc} Static Function FndRegs
  (long_description)
  @type  Static Function
  @author Abel Babini
  @since 18/08/2020
  /*/
Static Function FndRegs()
  Local cTxtPesq := Alltrim(cTxtMl)
  aBrw01Rs := {}

  cQryTxt := GetNextAlias()
  BeginSql alias cQryTxt
    COLUMN ZG3_DATA AS DATE
    SELECT *
    FROM (
      SELECT
        ZG3.ZG3_CODIGO    AS ZG3_CODIGO,
        ZG3.ZG3_DATA      AS ZG3_DATA,
        ZG3.ZG3_HORA      AS ZG3_HORA,
        ZG3.ZG3_DTMAIL    AS ZG3_DTMAIL,
        ZG3.ZG3_REMETE    AS ZG3_REMETE,
        ZG3.ZG3_ASSUNT    AS ZG3_ASSUNT,
        ZG3.ZG3_ANEXOS   AS ZG3_ANEXOS,
        ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), ZG3.ZG3_FILE)),'') AS ZG3_FILE,
        ISNULL(CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), ZG3.ZG3_BODY)),'') AS ZG3_BODY,
        ZG3.R_E_C_N_O_ AS REC
      FROM	%TABLE:ZG3% ZG3
      WHERE ZG3.%notDel%
      AND		ZG3.ZG3_DATA BETWEEN %Exp:DtoS(dDtIniMl)% AND %Exp:DtoS(dDtFinMl)% ) AS RES
    WHERE
      ZG3_FILE    LIKE '%'+%Exp:cTxtPesq%+'%'
  EndSql

  (cQryTxt)->(dbGoTop())
  IF !(cQryTxt)->(eof())
    (cQryTxt)->(dbGoTop())
    While !(cQryTxt)->(eof())
      
      AADD(aBrw01Rs,{ (cQryTxt)->ZG3_CODIGO,;
                      dtoc((cQryTxt)->ZG3_DATA),;
                      (cQryTxt)->ZG3_HORA,;
                      (cQryTxt)->ZG3_ANEXOS,;
                      Alltrim((cQryTxt)->ZG3_REMETE),;
                      Alltrim((cQryTxt)->ZG3_ASSUNT)})

      (cQryTxt)->(dbSkip())
    EndDo
  ENDIF
  oBrw01Rs:nRowPos := 1
  oBrw01Rs:nAt:=1
  oBrw01Rs:SetArray(aBrw01Rs)
  
  nRowPos := 1
  cXML := ''
  IF Len(aBrw01Rs) > 0
    IF ZG3->(MsSeek(xFilial('ZG3')+aBrw01Rs[oBrw01Rs:nRowPos,1],.T.))
      cXML := ZG3->ZG3_FILE
    ENDIF

  ENDIF

Return

/*/{Protheus.doc} User Function FIS044ML
  Função para Leitura da caixa posta e gravação na tabela ZG3 e download dos anexos.
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
User Function FIS044ML()
   MsAguarde({|| ReadMMsg()}, "Aguarde...", "Lendo caixa de entrada...")
Return

/*/{Protheus.doc} User Function ReadMMsg
  Função para Leitura da caixa posta e gravação na tabela ZG3 e download dos anexos.
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function ReadMMsg()
  Local aArea := GetArea()
  
  Local xRet
  Local nNumMsg := 0
  Local _cUserMl:= GETMV("MV_#NFSUSR",,"") //Usuário da Caixa de Email de NFSE
  Local _cPassMl:= GETMV("MV_#NFSPSW",,"") //Senha da Caixa de Email de NFSE
  Local _cSrvMl := GETMV("MV_#NFSSRV",,"") //Servidor da Caixa de Email de NFSE
  Local _i      := 0
  Local _j      := 0
  
  Private oServer
  Private oMessage
  Private cDirBase  := GetSrvProfString("RootPath", "")
  Private cDirPad   := "\xml_nfse\"
  Private cDirFull  := ''

  IF  Alltrim(_cUserMl) == '' .OR. ;
      Alltrim(_cPassMl) == '' .OR. ;
      Alltrim(_cSrvMl) == ''
    Aviso("ADFIS044P-01","Parâmetros Não preenchidos (MV_#NFSUSR / MV_#NFSPSW / MV_#NFSSRV)",{"OK"},3)
    RestArea(aArea)
    Return
  ENDIF

  //Se o último caracter não for barra, retira ela
  If SubStr(cDirBase, Len(cDirBase), 1) == '\'
      cDirBase := SubStr(cDirBase, 1, Len(cDirBase)-1)
  EndIf
  cDirFull := cDirBase + cDirPad

  oMessage := TMailMessage():New()
  oServer := TMailMng():New( IMAP, 3, 6 )
  oServer:cUser := _cUserMl
  oServer:cPass := _cPassMl
  oServer:cSrvAddr := _cSrvMl
   
  // Make IMAP connection
  MsProcTxt("Conectando com a Caixa de Email...")
  xRet := oServer:Connect()
  IF xRet != 0
    Aviso("ADFIS044P-02","Não foi possível se conectar a caixa de e-mail. Erro: "+oServer:GetErrorString( xRet ),{"OK"},3)
    RestArea(aArea)
    Return
  ENDIF
   
  MsProcTxt("Obtendo Mensagens...")
  xRet := oServer:GetNumMsgs( @nNumMsg )
  IF xRet <> 0
    oServer:Disconnect()
    Aviso("ADFIS044P-03","Não foi possível ler o número de mensagens. Erro: "+oServer:GetErrorString( xRet ),{"OK"},3)
    RestArea(aArea)
    Return
  ENDIF
   
  if nNumMsg > 0
    FOR _i := 1 to nNumMsg
      MsProcTxt("Obtendo Mensagem "+cValToChar( _i )+" de "+cValToChar( nNumMsg )+".")

      xRet := oMessage:Receive2( oServer, _i )
      if xRet != 0
        oServer:Disconnect()
        Aviso("ADFIS044P-04","Não foi possível ler uma mensagem da caixa postal. Erro: "+oServer:GetErrorString( xRet ),{"OK"},3)
        RestArea(aArea)
        Return
      endif
      
      nCntXML := 0
      For _j:=1 to oMessage:GetAttachCount()
        //@history Ticket  n.    24 - Abel Babini - 01/09/2020 - Correção no filtro de anexos pela extensão
        IF UPPER(Right(Alltrim(oMessage:GetAttachInfo(_j)[1]),4)) == ".XML" //.AND. Substr(Alltrim(oMessage:GetAttachInfo(_j,1)),8,2) != '55'
          nCntXML += 1
        ENDIF
      Next _j

      //Grava informações na tabela ZG3
      cCodMl := GrvZG3(oMessage:cDate, oMessage:cFrom, oMessage:cSubject, oMessage:cBody, nCntXML )

    NEXT _i
    
  ENDIF
   
  // Disconnect from IMAP server
  xRet := oServer:Disconnect()
  if xRet <> 0
    conout( "Error on Disconnect: " + oServer:GetErrorString( xRet ) )
    return
  endIf

  ZG3->(dbGoTop())

  RestArea(aArea) 
return

/*/{Protheus.doc} User Function DwnlAttc
  Grava anexos do Email no disco e na tabela ZG3
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function DwnlAttc(cCodMl, attachInfo, nIndex )
  Local aArea := GetArea()
  Local nHandle := nil 
  Local cContent:= ''
  Local nLast   := 0

  ////@history Ticket  n.    24 - Abel Babini - 01/09/2020 - Correção no filtro de anexos pela extensão
  IF !FILE(cDirFull + cCodMl + attachInfo)
    xRet := oMessage:SaveAttach(nIndex, cDirFull + cCodMl + attachInfo)
  ELSE
    xRet := .T.
  endif

  IF xRet != .T.
    ////@history Ticket  n.    24 - Abel Babini - 01/09/2020 - Correção no filtro de anexos pela extensão
    //Aviso("ADFIS044P-05","Não foi possível salvar um anexo no servidor. Erro: "+Alltrim(attachInfo),{"OK"},3)
  ELSE
    
    nHandle := FT_FUSE(cDirPad + cCodMl + attachInfo )
    
    If nHandle == -1
      Aviso("ADFIS044P-06","Não foi possível abrir XML. Erro: "+Alltrim(str(ferror(),4)),{"OK"},3)
    Else
      // Posiciona na primeria linha
      FT_FGoTop()
      // Retorna o número de linhas do arquivo
      nLast := FT_FLastRec()
      cContent := ''
      While !FT_FEOF()
        // Retorna a linha corrente
        cContent  += FT_FReadLn()

        // Pula para próxima linha
        FT_FSKIP()
      End
      // Fecha o Arquivo
      FT_FUSE()
      
    Endif

    dbSelectArea("ZG3")
    dbSetOrder(1)
    IF ZG3->(MsSeek(xFilial("ZG3")+cCodMl))
      Reclock("ZG3", .F.)
        ZG3->ZG3_FILE := SUBSTRING(Alltrim(ZG3->ZG3_FILE) + UPPER(cContent),1,1048575)
      ZG3->(msUnlock())
    ENDIF

  ENDIF
  RestArea(aArea)
Return


/*/{Protheus.doc} User Function GrvZG3
  Grava tabela ZG3 - Emails Recebidos NFSE
  @type  Function
  @author Abel Babini
  @since 24/08/2020
  /*/
Static Function GrvZG3(_cData, _cFrom, _cSubjec, _cBody, _nAttach )
  Local aArea   := GetArea()
  Local cCodMl  := ''
  Local cQuery1
  Local cDiaMl  := ''
  Local cMesExMl:= ''
  Local cMesMl  := ''
  Local cAnoMl  := ''
  Local cHoraMl := ''
  Local dDtMail
  Local _j      := 0
  cQuery1 := GetNextAlias()
  BeginSql alias cQuery1
    SELECT TOP 1 ZG3.ZG3_CODIGO AS ZG3_CODIGO
    FROM %TABLE:ZG3% ZG3
    WHERE ZG3.%notDel%
    ORDER BY ZG3_CODIGO DESC
  EndSql

  IF (cQuery1)->(eof())
    cCodMl  := StrZero(1,6)
  ELSE
    cCodMl  := SOMA1((cQuery1)->ZG3_CODIGO,6)
  ENDIF
  (cQuery1)->(dbCloseArea())


  cDiaMl  := SubStr(Alltrim(_cData),At(" ",Alltrim(_cData))+1,2)
  _cAuxdt := Alltrim(Substr(Alltrim(_cData),At(" ",Alltrim(_cData))+3,Len(Alltrim(_cData))))
  cMesExMl:= SubStr(_cAuxdt, 1, 3)
  _cAuxdt := Substr(Alltrim(_cAuxdt),5,Len(_cAuxdt))
  cAnoMl  := IIF(At(" ",_cAuxdt)==3,SubStr(_cAuxdt, 1, 2),SubStr(_cAuxdt, 1, 4)) 
  _cAuxdt := IIF(At(" ",_cAuxdt)==3,Substr(Alltrim(_cAuxdt),4,Len(_cAuxdt)),Substr(Alltrim(_cAuxdt),6,Len(_cAuxdt))) 
  cHoraMl := SubStr(_cData, At(":",_cData)-2, 8)
  DO CASE
    CASE cMesExMl == 'Jan'
      cMesMl := '01'
    CASE cMesExMl == 'Fev' .or. cMesExMl == 'Feb'
      cMesMl := '02'
    CASE cMesExMl == 'Mar' 
      cMesMl := '03'
    CASE cMesExMl == 'Abr' .or. cMesExMl == 'Apr'
      cMesMl := '04'
    CASE cMesExMl == 'Mai' .or. cMesExMl == 'May'
      cMesMl := '05'
    CASE cMesExMl == 'Jun'
      cMesMl := '06'
    CASE cMesExMl == 'Jul'
      cMesMl := '07'
    CASE cMesExMl == 'Ago' .or. cMesExMl == 'Aug'
      cMesMl := '08'
    CASE cMesExMl == 'Set' .or. cMesExMl == 'Sep'
      cMesMl := '09'
    CASE cMesExMl == 'Out' .or. cMesExMl == 'Oct'
      cMesMl := '10'
    CASE cMesExMl == 'Nov'
      cMesMl := '11'
    CASE cMesExMl == 'Dez' .or. cMesExMl == 'Dec'
      cMesMl := '12'
    OTHERWISE
      cMesMl := ''
  ENDCASE
  
  
  IF Alltrim(cMesMl) != ''
    dDtMail := CTOD(cDiaMl+'/'+cMesMl+'/'+cAnoMl)

    _cFrom  := StrTran(StrTran(_cFrom,'"',''),"'","")
    dbSelectArea("ZG3")
    dbSetOrder(2)
    IF ! ZG3->(MsSeek(xFilial("ZG3")+DTOS(dDtMail)+cHoraMl+_cFrom+SPACE(200-Len(_cFrom))+_cSubjec))
      Reclock("ZG3", .T.)                                                                                                     
        ZG3->ZG3_CODIGO := cCodMl
        ZG3->ZG3_DATA   := dDtMail
        ZG3->ZG3_HORA   := cHoraMl
        ZG3->ZG3_DTMAIL := _cData
        ZG3->ZG3_REMETE := UPPER(_cFrom)
        ZG3->ZG3_ASSUNT := UPPER(_cSubjec)
        ZG3->ZG3_BODY   := UPPER(_cBody)
        ZG3->ZG3_ANEXOS := _nAttach
      ZG3->(msUnlock())

      For _j:=1 to oMessage:GetAttachCount()
        //@history Ticket  n.    24 - Abel Babini - 01/09/2020 - Correção no filtro de anexos pela extensão
        IF UPPER(Right(Alltrim(oMessage:GetAttachInfo(_j)[1]),4)) == ".XML"

          DwnlAttc(cCodMl, oMessage:GetAttachInfo(_j)[1], _j )

        ENDIF
      Next _j

    ENDIF
  ENDIF

  RestArea(aArea)
Return cCodMl
