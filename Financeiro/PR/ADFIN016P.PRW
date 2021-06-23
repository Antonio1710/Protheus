#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "AP5MAIL.ch"
 
//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
//±±ºPrograma  ³ADFIN016P º Autor ³Mauricio - MDS TEC  º Data ³  04/02/15   º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºDescricao ³ Importa arquivo gerado pela CISP com informações da RECEITAº±±
//±±º          ³  SINTEGRA relativo clientes quanto a status deles.         º±±
//±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
//±±ºUso       ³ AD'ORO                                                     º±±
//±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//±±ºAdriana     ³24/05/2019³TI-Devido a substituicao email para shared     º±±
//±±º            ³          ³relay, substituido MV_RELACNT p/ MV_RELFROM    º±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

  
User Function ADFIN016P()

Local _lRet := .F.
Private oDlg01
Private oFont1
Private _cFile
Private _aDadosGer := {}
Private _aDadosFin := {}

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Importa arquivo gerado pela CISP com informações da RECEITA SINTEGRA relativo clientes quanto a status deles.')

Define msDialog oDlg01 From 00,00 To 220,370 Title "Importa arquivo com Status RECEITA/SINTEGRA de Clientes" Pixel
Define Font oFont1 Name "Arial" Size 0,-10 Bold   //-12
@005,005 to 080,180 of oDlg01 Pixel      //45,180
@010,010 Say "Rotina para importar arquivo TXT com informções da " Font oFont1 of oDlg01 Pixel
@020,010 Say "RECEITA/SINTEGRA/SUFRAMA sobre o status de Clientes.Somente" Font oFont1 of oDlg01 Pixel
@030,010 Say "dados da RECEITA/SINTEGRA serao considerados. A condição do" Font oFont1 of oDlg01 Pixel
@040,010 Say "cadastro dos clientes(bloqueado ou Não) mu1da em função dessa" Font oFont1 of oDlg01 Pixel
@050,010 Say "informação. Email é enviado aos responsaveis." Font oFont1 of oDlg01 Pixel

@080,115 BmpButton Type 1 Action(_lRet := .T.,Close(oDlg01))
@080,150 BmpButton Type 2 Action(_lRet := .F.,Close(oDlg01))
Activate Dialog oDlg01 Centered

If _lRet
   _cFile := cGetFile("Arquivo REC/SIN/SUF|*.txt|",OemToAnsi("Abrir arquivo..."),,'C:\',.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + 32)
   IF !Empty(_cFile)
      if (MsgNoYes("Confirma inicio da importação?" + _cFile))
         _aFile := Directory(_cFile)
         _nIn := 0
         Processa( {|| ProcFile()},"Importando o arquivo..." )
         If _nIn > 0
            MsgInfo("Atençao! Houve problema com o arquivo")
         Endif
         DbSelectArea("SA1")
         DbSetOrder(1)
         dbGotop()         
      Endif
   Else
      MsgInfo("Não foi escolhido nenhum arquivo para ser importado.","Atenção")      
   Endif
Endif

Return(_lRet)

Static function ProcFile()
//AADD(_aDadosGer,{"","","",""})
       FT_FUSE(_cFile)
       _nTam := FT_FLASTREC()
       FT_FGoTop()
       ProcRegua(_nTam)
       While !(FT_Feof())
             IncProc("importando dados e realizando as atualizações necessarias...")
             _cTxt := Alltrim(FT_FReadLN())
             _cTxt := Alltrim(_cTxt)
             
             LeArq()
             
             FT_FSKIP() 
       Enddo
       FT_FUSE()
                  
//Return()
      
for _nz := 1 to len(_aDadosGer)
    _cStatSIN := "C"
    _cStatREC := "C"
    If _aDadosGer[_nz][4] == "1" &&Sintegra
       _cStatSIN := "C"
       _cStatREC := "C" 
       if alltrim(_aDadosGer[_nz][2]) == "ATIVA" .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO COM RESTRICAO" ;
           .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO - HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO - ATIVO" 
          _cStatSIN := "A"     &&ativo
       Elseif Substr(Alltrim(_aDadosGer[_nz][2]),1,14) == "NAO HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTO" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTA" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADA" ;
            .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO (VIDE OBS)" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSO" ;
            .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXA DEFERIDA"
          _cStatSIN := "B"     &&Bloqueado
       Endif      
       //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"1")
       _nPos  := Ascan(_aDadosFin,{|x| x[1]  == _aDadosGer[_nz][1]} )   &&verifico se ja existe gravado o CNPJ 
       If _nPos = 0
	       AADD(_aDadosFin,{_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatSIN,_cStatREC})
       Else                      
         _aDadosFin[_nPOs][3] := _cStatSIN       
       Endif       
    Elseif _aDadosGer[_nz][4] == "2"  &&Receita
       _cStatSIN := "C"
       _cStatREC := "C"  
       if alltrim(_aDadosGer[_nz][2]) == "ATIVA" .Or. Alltrim(_aDadosGer[_nz][2]) == "ATIVO".Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO ATIVO" .Or. Alltrim(_aDadosGer[_nz][2]) == "HABILITADO COM RESTRICAO"
          _cStatREC := "A"     &&ativo
       Elseif Alltrim(_aDadosGer[_nz][2]) == "INAPTA" .Or. Alltrim(_aDadosGer[_nz][2]) == "CANCELADA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "INAPTO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADA" ;
             .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXADO (VIDE OBS)" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSA" .Or. Alltrim(_aDadosGer[_nz][2]) == "SUSPENSO" .Or. Alltrim(_aDadosGer[_nz][2]) == "BAIXA DEFERIDA"
          _cStatREC := "B"     &&Bloqueado
       Endif     
       //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"2")
       _nPos  := Ascan(_aDadosFin,{|x| x[1]  == _aDadosGer[_nz][1]} )   &&verifico se ja existe gravado o CNPJ 
       If _nPos = 0
	       AADD(_aDadosFin,{_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatSIN,_cStatREC})
       Else                      
         _aDadosFin[_nPOs][4] := _cStatREC       
       Endif
    Endif                     
NEXT _nz

for _nz := 1 to len(_aDadosFin)
    //fprocCli(_aDadosGer[_nz][1],_aDadosGer[_nz][2],_cStatCISP,"2")
    fprocCli(_aDadosFIN[_nz][1],_aDadosFIN[_nz][2],_aDadosFIN[_nz][3],_aDadosFIN[_nz][4])
NEXT _nz

Return()


Static function fprocCli(_cCNPJ,_cSitua,_cStSIN,_cStREC)
       
       DbSelectarea("SA1")               &&confirmado junto a Adriana e Alberto, so considerar clientes com cadastro na SA1...
       DbSetOrder(3)
       if dbseek(xFilial("SA1")+ALltrim(_cCNPJ))
          If SA1->A1_MSBLQL == "2" .Or. Empty(SA1->A1_MSBLQL)
             _cStatProt := "A"
          Elseif SA1->A1_MSBLQL == "1"   
             _cStatProt := "B"
          Endif          
          IF _cStatProt == "A" .And. (_cStSIN == "B" .Or. _cStREC == "B")      &&Neste caso vou bloquear no Protheus...
             IF _cStSIN == "B"
                _cMotivo := "IF"
                _cDscMot := "Cliente bloqueado por irregularidade Fiscal relativo ao SINTEGRA."
                AdoGrvBloq( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ,SA1->A1_VEND)
             Elseif _cStREC == "B"   
                _cMotivo := "IF"
                _cDscMot := "Cliente bloqueado por irregularidade Fiscal relativo a RECEITA."
                AdoGrvBloq( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ,SA1->A1_VEND)
             Endif   
          Elseif _cStatProt == "B" .And. (_cStSIN == "A" .AND. _cStREC == "A") &&neste caso vou enviar email para avaliarem o desbloqueio ou não....
                _cMotivo := "IF"                
                _cDscMot := "Cliente se encontra com situação de ATIVO junto a SINTEGRA/RECEITA e bloqueado no Protheus."                                                                                   
                AdoGrvlib( SA1->A1_COD,SA1->A1_LOJA,_cMotivo, _cDscMot,_cCNPJ)           
          Endif
       Endif
Return()
                                                                                                                   	
Static Function AdoGrvBloq( cCodcli, cLojaCli, cMotivo, cDscMot,_cCNPJ,cCodVend)
Local cNomeUsr	 := GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
Local _nPos      := RAT("\",Alltrim(_cFile))
Local _cArqui	 := Alltrim(Substr(Alltrim(_cFile),_nPos + 1,25))
Local cPara		 := SuperGetMv("FS_MOVMAIL", .F., 0 )
Local cEmailVend := Alltrim(Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_EMAIL")) //email representante  
Local cSuperv    := Posicione("SA3",1,xFilial("SA3")+cCodVend,"A3_CODSUP") //buscar email do  Supervisor 
Local cSupUsu    := Posicione("SZR",1,xFilial("SZR")+cSuperv,"ZR_USER")  
Local cEmaiSup   := Posicione("SA3",7,xFilial("SA3")+cSupUsu,"A3_EMAIL") 
Local cCC        := GETMV('MV_#EMACIS') + ';' + cEmailVend + ';' + cEmaiSup


Local cNivel	 := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)

DbSelectArea( 'PB3' )
PB3->( dbSetOrder( 3 ))
If PB3->( dbSeek( xFilial( 'PB3' ) + AllTrim(_cCNPJ) ))
	
	//Grava LOG
	//U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_BLOQUE', 'X3_Titulo' ), /*PB3->PB3_BLOQUE*/ 'Desbloqueado', /*'1'*/ 'Bloqueado' )
	U_Ado05Log( PB3->PB3_COD, PB3->PB3_LOJA, cNomeUsr, dDataBase, Posicione('SX3', 2, 'PB3_MOTBLQ', 'X3_Titulo' ),_cArqui, cMotivo+" - "+ cDscMot )
	
	DbSelectArea( 'PBA' )
	RecLock( 'PBA', .T. )
	
		PBA->PBA_FILIAL	:= xFilial("PBA")
		PBA->PBA_CODCLI	:= PB3->PB3_COD
		PBA->PBA_LOJACL	:= PB3->PB3_LOJA
		PBA->PBA_NIVEL	:= cNivel
		PBA->PBA_USUARI	:= __cUserId
		PBA->PBA_NOME	:= cNomeUsr
		PBA->PBA_DATA	:= dDatabase
		PBA->PBA_HORA	:= TIME()
		MSMM(,TamSx3("PBA_PARECE")[1],,cMotivo+" - "+ cDscMot,1,,,"PBA","PBA_CODMEM")
	
	PBA->( MsUnLock())
	
	cMensagem 	:= 	'O cliente ' + PB3->PB3_CODSA1 + ' - ' + PB3->PB3_NOME + ' Loja ' + PB3->PB3_LOJA + cNomeUsr+chr(13) + chr(10)+;
	'Foi bloqueado em ' + DtoC( dDatabase ) + ' Por ' + cNomeUsr+chr(13) + chr(10)+;
	"Motivo : "+cMotivo+" - "+ cDscMot
	RecLock( 'PB3', .F. )
	PB3->PB3_BLOQUE 	:= '1'
	PB3->PB3_MOTBLQ  	:= cMotivo
	PB3->PB3_SITUAC		:= '3'
	PB3->( MsUnLock())

	
	//bloquear tambem no cadastro de clientes
		DbSelectArea( 'SA1' )
		SA1->( DbSetOrder(3) )
		If SA1->( DbSeek( xFilial('SA1') + Alltrim(PB3->PB3_CGC) ))
			RecLock( 'SA1', .F. )
			SA1->A1_MSBLQL := '1'
			SA1->( MsUnLock()) 
			_aArea:=GetArea()
			RestArea(_aArea)
		Endif

	
	cMensagem := "Codigo          : "+ PB3->PB3_CODSA1+chr(13) + chr(10)
    cMensagem += "Loja            : "+ PB3->PB3_LOJA+chr(13) + chr(10)
	cMensagem += "Cliente         : "+ PB3->PB3_NOME+chr(13) + chr(10)
	cMensagem += "CNPJ/CPF        : "+ Transform(PB3->PB3_CGC,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
	cMensagem += "Vendedor        : "+ GetAdvFVal("SA3", "A3_COD",xFilial("SA3")+PB3->PB3_VEND, 7)+;
	"-"+GetAdvFVal("SA3", "A3_NOME",xFilial("SA3")+PB3->PB3_VEND, 7)	+chr(13) + chr(10)
	cMensagem += "Limite Aprov.   : "+ Alltrim(Transform(PB3->PB3_LIMAPR,"@E 999,999,999.99"))+chr(13) + chr(10)
	cMensagem += "Prazo           : "+ PB3->PB3_COND +"-"+GetAdvFVal("SE4", "E4_DESCRI",xFilial("SE4")+PB3->PB3_COND, 1)+chr(13) + chr(10)
	cMensagem += "Motivo Bloqueio : "+ cMotivo+" - "+ cDscMot+chr(13) + chr(10)	
	cMensagem += "Bloqueio automatico pelo arquivo :"+_cArqui+", em "+Dtoc(dDatabase)+" às "+Time()	+chr(13) + chr(10)			
	
	CriaMail(cPara, 'Cliente Bloqueado', cMensagem, ,cCC, .F., .F., PB3->PB3_COD, PB3->PB3_LOJA)
	
Endif

Return nil 

Static Function CriaMail(cPara, cAssunto, cMsg, cDe, cCC, lAnexo, lParecer, cCodCli, cLojaCli )

Local aArea		 :=  GetArea()
Local lResulConn := .T.
Local lResulSend := .T.
Local cError     := ''
Local cServer    := Trim( GetMV('MV_RELSERV') ) //'smtp.adoro.com.br' // smtp.ig.com.br ou 200.181.100.51
Local cEmail     := Trim( GetMV('MV_RELACNT') ) // fulano@ig.com.br
Local cPass      := Trim( GetMV('MV_RELPSW') )  // 123abc
//Local cServer      := Alltrim(GetMv("MV_INTSERV")) 
//Local cEmail       := AllTrim(GetMv("MV_INTACNT"))
//Local cPass       := AllTrim(GetMv("MV_INTPSW"))
Local cFrom        := Trim( GetMV('MV_RELFROM') ) //AllTrim(GetMv("MV_INTACNT")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM           
Local lRet       := .T.
Local cUser      := ''
Local lAutentica := .F.
Local cParecer	 := ''
Local cAnexo	 := ''
Local cNivel	 := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
Local cFileLog 	 := Criatrab(,.f.)+".TXT"
Local cFOpen	 := ''
Local nOpcao 	 := 0
Local i			 := 0
Local aArquivos	 := {}
Local aArq2		 := {}
Local cCaminho	 := ''
Local nPosicao	 := 0
Local oDlgDoc	 := Nil
Local oListBox	 := Nil
Local cRootPath  := AllTrim( GetSrvProfString( "RootPath", "\" ) )
Local cStartPath := AllTrim( GetSrvProfString( "StartPath", "\" ) )
Local nPos       := 0
Local lTemAnexo	 := .F.
Local oTik		 := LoadBitMap(GetResources(), 'LBTIK')
Local oNo		 := LoadBitMap(GetResources(), 'LBNO' )
Local cPathEst   := "C:\TEMP"
Local aAnexos	 := {}
Local cNomeUsr	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
Local _nPos     := RAT("\",Alltrim(_cFile))
Local _cArqui	:= Alltrim(Substr(Alltrim(_cFile),_nPos + 1,25))

Default cMsg     := ''
Default cCodCli  := Space(6)
Private nLastKey := 0

If Empty( cServer ) .AND. Empty( cEmail ) .AND. Empty( cPass )
	ApMsgStop( 'Não foram definidos os parâmetros no server do Protheus para envio de e-mail', cAssunto )
	Return .F.
Endif

If lAnexo
	
	dbSelectArea("PB3")
	PB3->( dbSetOrder(1))
	PB3->( dbSeek( xFilial( 'PB3' ) + cCodCli + cLojaCli ))
	
	cDirServer := Alltrim(GetPvProfString(GetEnvServer(),"Rootpath","",GetADV97())) + "\Anexos" //GetMv("AC_DIRANEX",,"chamados\")
	
	if Right(cDirServer,1) <> "\"
		cDirServer += "\"
	endif
	
	cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
	if !lIsDir(cDirServer)
		makeDir(cDirServer)
	endif
	
	// verifica se cliente já possui diretório
	cDirServer += ( StrZero( Val( alltrim(cCodCli)), 6 ) + cLojaCli + "\")
	cDirServer := StrTran(Lower(cDirServer),Lower(cRootPath),"")
	if lIsDir(cDirServer)
		lTemAnexo:= .T.
	endif
	
	if Right(cPathEst,1) <> "\"
		cPathEst += "\"
	endif
	
	nPos := 1
	nPos1 := 1
	cdirTemp := ""
	
	While .t.
		nPos := at("\", substr(cPathEst,nPos1))
		if nPos > 3
			cDirTemp := substr(cPathEst,1, nPos1+nPos-1)
			if !lIsDir(cDirTemp)
				makeDir(cDirTemp)
			endif
		Endif
		nPos1 := nPos1+npos
		if nPos1 >= len(cPathEst)
			exit
		Endif
	Enddo
	
	cAnexFile 	:= StrZero( Val( AllTrim( cCodCli )), 6 ) + cLojaCli  + ".XLS"
	nPos 		:= rat(".", cAnexFile)
	cExtens 	:= ""
	if Len(Dtoc(dDataBase)) = 8
		cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 7, 2 )
	else
		cData 		:= Substr( DtoC( dDataBase ), 1, 2 ) + Substr( DtoC( dDataBase ), 4, 2 ) + Substr( DtoC( dDataBase ), 9, 2 )
	endif
	if nPos>0
		cExtens := substr(cAnexFile, nPos+1)
	Endif
	
	If lTemAnexo
		
		// apaga arquivos que estejam na maquina do usuario
		If File( cPathEst + cAnexFile )
			Ferase( cPathEst + cAnexFile )
		EndIf
		
		cFileOrig := cDirServer //+cAnexFile
		// pega os arquivos do cliente
		aAnexos := Directory( /*cRootPath + */cDirServer + '*.*', '')
		If Empty( aAnexos )
			Alert( 'Não existem anexos para o cliente selecionado')
		Else
			// monta array com as informacoes que serao exibidas em tela Nome arquivo, data que foi inserido, usuario que inseriu
			for i:= 1 to len( aAnexos )
				aAnexos[ i, 2 ] := 	aAnexos[ i, 1 ]
				aAnexos[ i, 1 ] := .F.
				aAnexos[ i, 3 ] := CtoD( SubStr( aAnexos[ i, 2 ], 9, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 11, 2 ) + '/' + SubStr( aAnexos[ i, 2 ], 13, 2 ) )
//				aAnexos[ i, 4 ] := Posicione( 'PB1',1,xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ),'PB1_NOME')
				aAnexos[ i, 4 ] := GetAdvFVal( 'PB1', 'PB1_NOME',xFilial('PB1') + Substr(aAnexos[ i, 2 ], 21, 6 ), 1)
			Next i
			
			DEFINE MSDIALOG oDlgDoc TITLE "Seleção de Anexos" FROM 10,10 To 400,/*397*/470 OF oMainWnd PIXEL
			
			@ 000,000 Say 'SELECIONE O ARQUIVO QUE DESEJA VISUALIZAR' SIZE 200,15 OF oDlgDoc PIXEL CENTERED
			@ 020,007 ListBox oListBox Fields HEADER " ","Arquivo", "Data", "Usuário";
			Size 220 , 170 Of oDlgDoc Pixel ColSizes 25,100,50,50;
			On DBLCLICK (aAnexos[oListBox:nAt,1] := !aAnexos[oListBox:nAt,1] , oListBox:Refresh())
			oListBox:SetArray(aAnexos)
			oListBox:bLine := {|| {If( aAnexos[oListBox:nAT,01], oTIK, oNO ),aAnexos[oListBox:nAT,02],aAnexos[oListBox:nAT,03],aAnexos[oListBox:nAT,04]}}
			
			ACTIVATE MSDIALOG oDlgDoc CENTERED ON INIT EnchoiceBar(oDlgDoc,{||nOpcao:= 1,oDlgDoc:End()},{||nOpcao:=0,oDlgDoc:End()})
		Endif
	Endif
		
	If nOpcao == 1 .And. !Empty( aAnexos )
		For i:= 1 to len( aAnexos )
			If aAnexos[ i, 1 ]
				aAdd(aArquivos, aAnexos[ i, 2 ] )
			Endif
		Next i
		
		//copia dos arquivos selecionados para o system
		If !Empty( aArquivos )
			//			cCaminho := MontaDir(cStartPath+'\Anexos\')
			For i := 1 to Len( aArquivos )
				
				// encontra a posicao da ultima barra
				//				nPosicao := Rat( '\', aArquivos[i] )
				// extrai apenas o nome do arquivo
				cFOpen:= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) )
				// copia o arquivo para o caminho desejado
				//				__copyfile( aArquivos[i] , cStartPath+'\Anexos\' + cFOpen )
				// alimenta array com os nomes de arquivo
				//				aAdd( aArq2, cFOpen )
				//cAnexo += cStartPath+'\Anexos\' + cFOpen + '; '
				cAnexo += cDirServer + cFOpen + ';'
				//cFOpen+= Right( aArquivos[i], ( Len( aArquivos[i] ) - nPosicao ) ) + '; '
			Next i
		Endif
	Endif
Endif

// Deseja enviar os pareceres por anexo
If lParecer
	cParecer := AdoGetHist( cCodCli, cLojaCli, cNivel )
	MemoWrite( cFileLog, cParecer )
	//	cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
	cAnexo 	 += cStartPath+'\'+ cFileLog+ ';'
Endif
cAnexo   := Left(cAnexo,len(cAnexo)-1)
cDe      := AllTrim(GetMv("MV_RELFROM")) //Por Adriana em 24/05/2019 substituido MV_RELACNT por MV_RELFROM
cPara    := AllTrim( cPara )
cCC      := AllTrim( cCC )
cAssunto := AllTrim( cAssunto )

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

If !lResulConn
	GET MAIL ERROR cError
	CONOUT( 'Falha na conexão para envio de e-mail ' + cError,, .F. )
	
	If !IsBlind()
		ApMsgStop( 'Falha na conexão para envio de e-mail ' + cError )
	EndIf
	
	//Grava LOG
	U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulConn, "Enviado com sucesso! ", "Falha de envio! "), " " )
	
	DbSelectArea( 'PBA' )
	RecLock( 'PBA', .T. )
	
		PBA->PBA_FILIAL	:= xFilial("PBA")
		PBA->PBA_CODCLI	:= PB3->PB3_COD
		PBA->PBA_LOJACL	:= PB3->PB3_LOJA
		PBA->PBA_NIVEL	:= cNivel
		PBA->PBA_USUARI	:= __cUserId
		PBA->PBA_NOME	:= cNomeUsr
		PBA->PBA_DATA	:= dDatabase
		PBA->PBA_HORA	:= TIME()
		MSMM(,TamSx3("PBA_PARECE")[1],,"Envio E-mail",1,,,"PBA","PBA_CODMEM")
	
	PBA->( MsUnLock())
	
	Return .F.
Endif

lAutentica:= GETMV('MV_RELAUTH')
If lAutentica
	cUser:= GETMV('MV_RELACNT')   //AllTrim(GetMv("MV_INTACNT"))//GETMV('MV_RELACNT')
	cPass:= GETMV('MV_RELAPSW') //AllTrim(GetMv("MV_INTPSW")) //GETMV('MV_RELAPSW')
	If !MailAuth(cUser,cPass)
		Msginfo(OemToAnsi('Falha autenticacao Usuario'))
		//cNomeUsr := Right(Alltrim(_cFile),30)   //GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")
		
		//Grava LOG
		U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lAutentica, "Enviado com sucesso!", "Falha de envio!"), " " )
		DbSelectArea( 'PBA' )
		RecLock( 'PBA', .T. )
		
			PBA->PBA_FILIAL	:= xFilial("PBA")
			PBA->PBA_CODCLI	:= PB3->PB3_COD
			PBA->PBA_LOJACL	:= PB3->PB3_LOJA
			PBA->PBA_NIVEL	:= cNivel
			PBA->PBA_USUARI	:= __cUserId
			PBA->PBA_NOME	:= cNomeUsr
			PBA->PBA_DATA	:= dDatabase
			PBA->PBA_HORA	:= TIME()
			MSMM(,TamSx3("PBA_PARECE")[1],,"Envio E-mail",1,,,"PBA","PBA_CODMEM")
		
		PBA->( MsUnLock())
	
		Return .F.
	Endif
Endif

If Empty( cCc ) .AND.  Empty( cAnexo )
	SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
	
ElseIf  Empty( cCc ) .AND. !Empty( cAnexo )
	SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	
ElseIf !Empty( cCc ) .AND.  Empty( cAnexo )
	SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend
	
Else
	SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	
Endif

If !lResulSend
	GET MAIL ERROR cError
	lRet := .F.
	
	If !IsBlind()
		ApMsgStop( 'Falha no envio do e-mail (' + cError + ') ' )
	Else
		CONOUT( 'Falha no envio do e-mail (' + cError + ') ',, .F. )
	EndIf
Endif
//cNomeUsr := Right(Alltrim(_cFile),30)  //GetAdvFVal("PB1", "PB1_NOME", xFilial("PB1") + __cUserId, 1, " ")

//Grava LOG
U_Ado05Log( cCodCli, cLojaCli, cNomeUsr, dDataBase, "Envio E-mail", If(lResulSend, "Enviado com sucesso!", "Falha de envio!"), " " )
	DbSelectArea( 'PBA' )
	RecLock( 'PBA', .T. )
	
		PBA->PBA_FILIAL	:= xFilial("PBA")
		PBA->PBA_CODCLI	:= PB3->PB3_COD
		PBA->PBA_LOJACL	:= PB3->PB3_LOJA
		PBA->PBA_NIVEL	:= cNivel
		PBA->PBA_USUARI	:= __cUserId
		PBA->PBA_NOME	:= cNomeUsr
		PBA->PBA_DATA	:= dDatabase
		PBA->PBA_HORA	:= TIME()
		MSMM(,TamSx3("PBA_PARECE")[1],,"Envio E-mail",1,,,"PBA","PBA_CODMEM")
	
	PBA->( MsUnLock())

DISCONNECT SMTP SERVER
cMsg :=''

FERASE( cFileLog )
//If !Empty( aArq2 )
//	For i:= 1 to len( aArq2 )
//		FERASE( cStartPath+'\anexos\' + aArq2[i] )
//	Next i
//Endif
RestArea( aArea )
Return lRet  
                      
Static Function AdoGrvLib( cCodcli, cLojaCli, cMotivo, cDscMot,_cCNPJ)
Local cNomeUsr	:= GetAdvFVal( 'PB1', 'PB1_NOME', xFilial( 'PB1' ) + __cUserId, 1)
Local _nPos     := RAT("\",Alltrim(_cFile))
Local _cArqui	:= Alltrim(Substr(Alltrim(_cFile),_nPos + 1,25))
Local cNivel	 := GetAdvFVal( 'PB1', 'PB1_NIVEL', xFilial( 'PB1' ) + __cUserId, 1)
Local cPara		:= SuperGetMv("FS_MOVMAIL", .F., 0 )
Local cCC       := GETMV('MV_#EMACIS')

DbSelectArea( 'PB3' )
PB3->( dbSetOrder( 3 ))
If PB3->( dbSeek( xFilial( 'PB3' ) + AllTrim(_cCNPJ) ))
	If Alltrim(PB3->PB3_MOTBLQ) == "IF"  &&Apenas avisar quando o motivo original do bloqueio for CISP (Adriana 18/02/15).
		
		DbSelectArea( 'SA1' )
		SA1->( dbSetOrder( 3 ))
		If SA1->( dbSeek( xFilial( 'SA1' ) + Alltrim(_cCNPJ) ))
			
			//Grava LOG	
			U_Ado05Log( cCodcli, cLojaCli, cNomeUsr, dDataBase,"","Enviado email "+_cArqui, cMotivo+" - "+ cDscMot )
			
			DbSelectArea( 'PBA' )
			RecLock( 'PBA', .T. )
			
				PBA->PBA_FILIAL	:= xFilial("PBA")
				PBA->PBA_CODCLI	:= PB3->PB3_COD
				PBA->PBA_LOJACL	:= PB3->PB3_LOJA
				PBA->PBA_NIVEL	:= cNivel
				PBA->PBA_USUARI	:= __cUserId
				PBA->PBA_NOME	:= cNomeUsr
				PBA->PBA_DATA	:= dDatabase
				PBA->PBA_HORA	:= TIME()
				MSMM(,TamSx3("PBA_PARECE")[1],,cMotivo+" - "+ cDscMot,1,,,"PBA","PBA_CODMEM")
			                                      
			PBA->( MsUnLock())
			
			cMensagem := "Codigo          : "+ SA1->A1_COD+chr(13) + chr(10)
			cMensagem += "Loja            : "+ SA1->A1_LOJA+chr(13) + chr(10)
			cMensagem += "Cliente         : "+ SA1->A1_NOME+chr(13) + chr(10)
			cMensagem += "CNPJ/CPF        : "+ Transform(_cCNPJ,U_Pic(PB3->PB3_PESSOA))+chr(13) + chr(10)
			cMensagem += "Usuario/Arquivo : "+ cNomeUSr+ " data: "+DtoC( dDatabase )	+chr(13) + chr(10)
			cMensagem += "Informação para avaliação : "+ cMotivo+" - "+ cDscMot+chr(13) + chr(10)
			
			cMensagem += "Cliente ativado no arquivo da RECEITA ou SINTEGRA e bloqueado no Protheus.Favor avaliar bloqueio do Cliente no Protheus."+chr(13) + chr(10)
			
			CriaMail(cPara, 'Cliente Ativo na RECEITA ou SINTEGRA', cMensagem, ,cCC, .F., .F.,PB3->PB3_COD, PB3->PB3_LOJA)
			
		Endif
	Endif
Endif

Return nil 


Static function LeArq()
_cStatCISP := ""

If Substr(_cTxt,1,1) == "1" .Or. Substr(_cTxt,1,1) == "2"  &&1 Sintegra     2 Receita
   
   _cTp     := Substr(_cTxt,1,1)
   _cCNPJ   := Substr(_cTxt,5,14)
   _cSitua  := Substr(_cTxt,715,50)
   _cDTCONS := Substr(_cTxt,781,8)
   
   _nPos  := Ascan(_aDadosGer,{|x| (x[1] + x[4]) == (_cCNPJ + _cTp)} )   &&verifico se ja existe gravado o CNPJ + Tipo
   If _nPos = 0
	  AADD(_aDadosGer,{_cCNPJ,_cSitua,_cDTCONS,_cTp})
   Else      
      IF STOD(_cDTCONS) > STOD(_aDadosger[_nPos][3])  && se data no registro atual é maior que data ja registrada no array
         _aDadosGer[_nPos][2] := _cSitua
         _aDadosGer[_nPOs][3] := _cDTCONS
         _aDadosGer[_nPos][4] := _cTp
      Endif
   Endif
     
Endif      
             
Return()      