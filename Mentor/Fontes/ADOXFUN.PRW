#INCLUDE "PROTHEUS.CH"

//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//Analista :: Wagner Manfre
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//data     :: 11/05/2011
//Função   :: FSAbreLog
//Uso      :: U_FSAbreLog([cFile]) => True ou False 
//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

// ############################################################################################################
// ---------+-------------------+--------------------------------------------------------------+---------------
// Data     | Autor             | Descricao                                                    | Chamado
// ---------+-------------------+--------------------------------------------------------------+---------------
// 07/12/18 | William Costa     | Regra para verificar se os CNPJ's são iguais                 | 045446
// ---------+-------------------+--------------------------------------------------------------+---------------
// ############################################################################################################

Static __logHdl	
Static __cFileLog
Static __cPathLog

User Function FSAbrelog(cName, lMsg)

Local lRet			:= .T.
Local _cDrive    	:= ''
Local _cDiretorio 	:= ''
Local _cFile     	:= ''
Local _cExtensao 	:= ''
Local aAreaSav		:= GetArea()
Local cAux			:= ""
Local cMascara		:= 'Arquivo de Log | *.log | Arquivo Texto |*.txt '
Local cTitulo		:= OemToAnsi('Abrir Arquivo...')
Local cDirInicial   := Alltrim(GetSrvProfString( 'RootPath', '' ))

Default cName := ""
Default lMsg := .F.

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If Empty( cName )
//cGetFile ( [ cMascara], [ cTitulo], [ nMascpadrao], [ cDirinicial], [ lSalvar], [ nOpcoes], [ lArvore], [ lKeepCase] )
	cName := Upper(cGetFile(cMascara,cTitulo, 1, cDirInicial, .T., GETF_NETWORKDRIVE, .T., .T. ))
Endif

SplitPath( cName, @_cDrive, @_cDiretorio, @_cFile, @_cExtensao ) 

if Empty( _cDrive )

	_cDiretorio := Iif(!Empty(_cDiretorio), _cDiretorio, Alltrim(GetSrvProfString( 'StartPath', '' ))+GetMV("FS_PATTMP",,"LOGTEMP"))

	If Right( _cDiretorio, 1) <> "\"
		_cDiretorio += "\"
	Endif

	_cDiretorio := StrTran(Lower(_cDiretorio),Lower(Alltrim(GetSrvProfString( 'RootPath', '' ))),"")

	nPos := 1
	nPos1 := 1
	cdirTemp := ""
	
	While .t.
		nPos := at("\", substr(_cDiretorio,nPos1))
		if nPos > 3
			cDirTemp := substr(_cDiretorio,1, nPos1+nPos-1)
			if !lIsDir(cDirTemp)
				makeDir(cDirTemp)
			endif
		Endif
		nPos1 := nPos1+npos
		if nPos1 >= len(_cDiretorio)
			exit
		Endif
	Enddo

	__cPathLog := _cDiretorio
	__cFileLog := _cFile + Iif(!Empty(_cExtensao), _cExtensao, ".log")
	If File( __cPathLog + __cFileLog )
 		If lMsg
			ApMsgAlert("O arquivo " + __cFileLog + ", já existia no caminho " + __cPathLog + ". O arquivo sera sobrescrito!", "Aviso" )
    	Endif
	Endif
	
	If (__logHdl := FCreate(__cPathLog + __cFileLog, 0)) == -1
		lRet := .F.
		If lMsg
			ApMsgAlert("Não foi possivel criar o arquivo de log " + __cFileLog + " conforme solicitado", "Falhou Log")
		Endif
		__cPathLog := Nil
		__cFileLog := Nil
		__logHdl := Nil
	EndIf

Else
	ApMsgAlert("Não foi possivel iniciar o arquivo de log conforme solicitado", "Falhou Log")
	__cPathLog := Nil
	__cFileLog := Nil
	__logHdl := Nil
	lRet := .F.
Endif

If lRet
	cAux := ""
	cAux += Replicate( '-', 128 ) + CRLF
	cAux += Replicate( ' ', 128 ) + CRLF
	cAux += 'LOG DE ACOMPANHAMENTO' + CRLF
	cAux += Replicate( ' ', 128 ) + CRLF
	cAux += Replicate( '-', 128 ) + CRLF
	cAux += CRLF
	cAux += ' Dados Ambiente'        + CRLF
	cAux += ' --------------------'  + CRLF
	cAux += ' Empresa / Filial...: ' + cEmpAnt + '/' + cFilAnt  + CRLF
	cAux += ' Nome Empresa.......: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_NOMECOM', cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
	cAux += ' Nome Filial........: ' + Capital( AllTrim( GetAdvFVal( 'SM0', 'M0_FILIAL' , cEmpAnt + cFilAnt, 1, '' ) ) ) + CRLF
	cAux += ' DataBase...........: ' + DtoC( dDataBase )  + CRLF
	cAux += ' Data / Hora........: ' + DtoC( Date() ) + ' / ' + Time()  + CRLF
	cAux += ' Environment........: ' + GetEnvServer()  + CRLF
	cAux += ' StartPath..........: ' + GetSrvProfString( 'StartPath', '' )  + CRLF
	cAux += ' RootPath...........: ' + GetSrvProfString( 'RootPath', '' )  + CRLF
	cAux += ' Versao.............: ' + GetVersao(.T.)  + CRLF
	cAux += ' Usuario Microsiga..: ' + __cUserId + ' ' +  cUserName + CRLF
	cAux += ' Computer Name......: ' + GetComputerName()  + CRLF

	aInfo   := GetUserInfo()
	If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
		cAux += ' '  + CRLF
		cAux += ' Dados Thread' + CRLF
		cAux += ' --------------------'  + CRLF
		cAux += ' Usuario da Rede....: ' + aInfo[nPos][1] + CRLF
		cAux += ' Estacao............: ' + aInfo[nPos][2] + CRLF
		cAux += ' Programa Inicial...: ' + aInfo[nPos][5] + CRLF
		cAux += ' Environment........: ' + aInfo[nPos][6] + CRLF
		cAux += ' Conexao............: ' + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), '' ), Chr( 10 ), '' ) )  + CRLF
	EndIf
	cAux += Replicate( '-', 128 ) + CRLF
	cAux += CRLF
	lRet := U_FSGrvlog(cAux)
Endif

RestArea(aAreaSav)

Return lRet


/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: FSGrvLog
Uso      :: U_FSGrvlog(cFile) => True ou False 
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function FSGrvlog(cMsg)

Local lRet 		:= .T.
Local nTam		:= len(cMsg)

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If __logHdl <> Nil
	If FWrite( __logHdl, cMsg, nTam ) <> nTam
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

Return lRet




/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: FSClsLog
Uso      :: U_FSClsLog() => Nil
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function FSClsLog(lMsg)

DeFault lMsg := .F.

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If __logHdl <> Nil
	fClose(__logHdl)
	If lMsg
		ApMsgAlert( "Arquivo de log" + __cFileLog + ", gerado na pasta " + __cPathLog + ".", "Aviso")
	Endif
Endif

__cPathLog := Nil
__cFileLog := Nil
__logHdl := Nil

Return Nil


/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: FSGetHdl
Uso      :: U_FSGetHdl() => nHandle
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function FSGetHdl()

Local nRet := -1

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If __logHdl <> Nil
	nRet := __logHdl
Endif

Return nRet



/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: FSGetFil
Uso      :: U_FSGetFil() => cFileName
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function FSGetFil()

Local cRet := ""

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If __logHdl <> Nil
	cRet := __cFileLog
Endif

Return cRet


/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: FSGetPat
Uso      :: U_FSGetPat() => cPathName
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function FSGetPat()

Local cRet := ""

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If __logHdl <> Nil
	cRet := __cPathLog
Endif

Return cRet


/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: TestLog1
Uso      :: U_TestLog1() => Nil
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function TestLog1()

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If U_FSAbrelog("TestLog.Log")
	if U_FSGrvLog("Rotina Testlog1" + CRLF)
		nVar := U_FSGethdl()
		if U_FSGrvLog("o Handle foi " + Alltrim(Str(nVar))+CRLF)
			cVar := U_FSGetPat()
			if U_FSGrvLog("o path do arquivo foi " + Alltrim(cVar)+CRLF)
				cVar := U_FSGetFil()
				if U_FSGrvLog("o arquivo foi " + Alltrim(cVar)+CRLF)
					U_FSGrvLog("Fim do Log "+CRLF)
				Endif
			Endif
		Endif
	Endif
	U_FSClsLog()
Else
	ApMsgAlert("Falhou ao abrir")
Endif
Return Nil



/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
Analista :: Wagner Manfre
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data     :: 11/05/2011
Função   :: TestLog2
Uso      :: U_TestLog2() => Nil
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
User Function TestLog2()

U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

If U_FSAbrelog()
	if U_FSGrvLog("Rotina Testlog1" + CRLF)
		nVar := U_FSGethdl()
		if U_FSGrvLog("o Handle foi " + Alltrim(Str(nVar))+CRLF)
			cVar := U_FSGetPat()
			if U_FSGrvLog("o path do arquivo foi " + Alltrim(cVar)+CRLF)
				cVar := U_FSGetFil()
				if U_FSGrvLog("o arquivo foi " + Alltrim(cVar)+CRLF)
					U_FSGrvLog("Fim do Log ")
				Endif
			Endif
		Endif
	Endif
	U_FSClsLog()
Else
	ApMsgAlert("Falhou ao abrir")
Endif
Return Nil  


//rotina para validação do codigo da Matriz
//fernando Sigoli Chamado 030181 -  10/11/2016
User Function valCodMat(_cCliente)

	Local _lReturn := .T.
	Local cCgc     := ''

	U_ADINF009P('ADOXFUN' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')
	
	IF ALLTRIM(_cCliente) <> ''
	
		dbSelectArea("SA1")
		dbSetOrder(1)
		
		If !dbSeek( xFilial("SA1")+ _cCliente )
		   MsgAlert("Cliente/Matriz "+Alltrim(_cCliente)+" Nao encontrado", "valCodMat-01")
		  _lReturn := .F.
		  
		ELSE
		
			cCgc := SA1->A1_CGC
		  	
		Endif
		
		// *** INICIO CHAMADO 045654 || OS 046839 || FINANCAS || ANDREA || 8319 || PB3 *** //
		
		IF _lReturn == .T.
		
			IF ALLTRIM(cCgc) == ''
			
				MsgAlert("OLÁ " + Alltrim(cUserName) + ", CGC do Cliente: " + _cCliente + ", em branco, favor verificar !!!", "valCodMat-02")
				
			 	_lReturn := .F.
			 	
			ENDIF
		
		ENDIF
		 
		IF _lReturn == .T.
		
			IF M->PB3_CGC <> cCgc
			
			 	MsgAlert("OLÁ " + Alltrim(cUserName)      + CHR(13) + CHR(10) + ;
			 	         "Os Cnpjs não Conferem " + CHR(13) + CHR(10) + ; 
			 	         "O CNPJ do Cliente Matriz: " + _cCliente  + " CGC: " + cCgc + ", não corresponde com o Cliente que está tentando fazer a Inclusão: " + M->PB3_CGC + ", favor entre em contato com o Financeiro !!!", "valCodMat-03")
			 	         
			 	_lReturn := .F.
			 	
			ENDIF
		
		ENDIF
		
		// *** FINAL CHAMADO 045654 || OS 046839 || FINANCAS || ANDREA || 8319 || PB3 *** //
		 
	ENDIF
	
Return _lReturn
	