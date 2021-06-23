#Include "Protheus.CH"
#Include "XMLXFun.CH"
#Include "TopConn.CH"
#Include "TbiConn.CH"

#Define _LF		Chr( 10 )
#Define CRLF	Chr( 13 ) + Chr( 10 )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LeXMLSC    ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Integracao de Notas Fiscais (Entradas/Saidas)              ³±±
±±³          ³ Sao Carlos -> Varzea Paulista                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function LEXMLSC( _cCodEmp, _cCodFil, _cInterval, _cUser, _cPassword )

Local _lInterval	:= .T.   
Local _cRet := ""
Private oProcess
Private _lErroDOC		:= .F.
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private lExecAuto		:= .T.
Private _lExcJob		:= .F.
Private _cMascara		:= "*.xml"
Private cFormul		:= "S"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a rotina e executada atraves de um JOB ou Menu   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetRemoteType() == -01
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ JOB - verifica se a rotina e executada entre um intervalo ou ³
	//³ em um horario estabelecido                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_lInterval	:= ( At( ":", _cInterval ) == 00 )
	_lExcJob		:= .T.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara Environment                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PREPARE ENVIRONMENT EMPRESA _cCodEmp FILIAL _cCodFil USER _cUser PASSWORD _cPassword MODULO "FAT" TABLES "SA7","SB1","SB2","SB5","SB8","SBJ","SB9","SBE","SBF","SC0","SC5","SC6","SD5","SBK","SD7","SDC","SF4","SGA","SM2","SDA","SDB","SBM","DAK","DAI","SA1","SA2","SE4","SE2"

	U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao de Notas Fiscais (Entradas/Saidas) Sao Carlos -> Varzea Paulista')
	
	While !KillApp()
		
		If _lInterval .Or. ( Left( Time(), 05 ) == _cInterval )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processamento de Importacao                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLeXMLSC( .T., _cCodEmp, _cCodFil )
			
		EndIf
		
		Inkey( Iif( _lInterval, Val( _cInterval ), 30000 ) )
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reset do Environment                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RESET ENVIRONMENT
	
Else
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Execucao atraves de Menu                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_lExcJob := .F.
	
	If MsgYesNo( "Confirma processamento de importacao XML Sao Carlos", "Atencao" )
		
		oProcess	:= MsNewProcess():New( {||ProcLeXMLSC( .F., _cCodEmp, _cCodFil ) }, "Processando", "Importando XML Sao Carlos ...", .T. )
		oProcess:Activate()
		
	EndIf
	
EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ProcLeXMLSC ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento de importacao de Notas Fiscais (E/S)         ³±±
±±³          ³ Sao Carlos -> Varzea Paulista                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcLeXMLSC( _lExcJob, _cCodEmp, _cCodFil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _cSource		:= ""
Local _cTargetImp	:= ""
Local _cTargetPrc	:= ""
Local _cTargetErr	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private _cRootPath		:= ""
Private cEmpPad			:= Iif( _lExcJob, _cCodEmp, cEmpAnt )
Private cFilPad			:= Iif( _lExcJob, _cCodFil, cFilAnt )
Private lAutoErrNoFile	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Diretorios Source/Target                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cSource		:= SuperGetMv( "MV_ADSCDIR", .F., "\NFSXMLSC\ENVIADOS\" )
_cRootPath	:= GetSrvProfString( "ROOTPATH", "" )
_cTargetImp	:= "\NFSXMLSC\Importados\"
_cTargetPrc	:= "\NFSXMLSC\Processados\"
_cTargetErr	:= "\NFSXMLSC\Erros\"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida existencia dos diretorios                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If FileInDir( _cSource, _cTargetImp, _cTargetPrc, _cTargetErr )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a copia dos arquivos XML para executar processamento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CpyXMLSC( _cSource, _cTargetImp )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PrcXMLSC( _cTargetImp, _cTargetPrc, _cTargetErr )
	
EndIf

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FileInDir  ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a existencia dos diretorios de processamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Diretorio Source (MV_ADSCDIR)                     ³±±
±±³          ³ parm02 = Diretorio Importados (Parser)                     ³±±
±±³          ³ parm03 = Diretorio Processados                             ³±±
±±³          ³ parm04 = Diretorio Erros                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FileInDir( _cSource, _cTargetImp, _cTargetPrc, _cTargetErr )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _lRet	:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !File( _cSource + "*.*" )
	
	If !_lExcJob
		MsgStop( AllTrim( _cSource ), "Diretorio inexistente" )
	Else
		ConOut( AllTrim( FunName() ) + " -> Diretorio inexistente: " + AllTrim( _cSource ) )
	EndIf
	
	_lRet := .F.
	
EndIf

If !File( _cSource + _cMascara ) .And. !File( _cTargetImp + _cMascara )
	
	If !_lExcJob
		MsgStop( AllTrim( _cSource ), "Nao existem arquivos para processamento" )
	Else
		ConOut( AllTrim( FunName() ) + " -> Nao existem arquivo para processamento em : " + AllTrim( _cSource ) )
	EndIf
	
	_lRet := .F.
	
EndIf

If !File( _cTargetImp + "*.*" )
	
	If !_lExcJob
		MsgStop( AllTrim( _cTargetImp ), "Diretorio inexistente" )
	Else
		ConOut( AllTrim( FunName() ) + " -> Diretorio inexistente: " + AllTrim( _cTargetImp ) )
	EndIf
	
	_lRet := .F.
	
EndIf

If !File( _cTargetPrc + "*.*" )
	
	If !_lExcJob
		MsgStop( AllTrim( _cTargetPrc ), "Diretorio inexistente" )
	Else
		ConOut( AllTrim( FunName() ) + " -> Diretorio inexistente: " + AllTrim( _cTargetPrc ) )
	EndIf
	
	_lRet := .F.
	
EndIf

If !File( _cTargetErr + "*.*" )
	
	If !_lExcJob
		MsgStop( AllTrim( _cTargetErr ), "Diretorio inexistente" )
	Else
		ConOut( AllTrim( FunName() ) + " -> Diretorio inexistente: " + AllTrim( _cTargetErr ) )
	EndIf
	
	_lRet := .F.
	
EndIf

Return ( _lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CpyXMLSC   ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a copia dos arquivos contidos no diretorio Source  ³±±
±±³          ³ para processamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Diretorio origem dos arquivos XML                 ³±±
±±³          ³ parm02 = Diretorio destino dos arquivos XML para Parser    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CpyXMLSC( _cSource, _cTargetImp )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aDirectory		:= Directory( _cSource + _cMascara )
Local _nCtDir			:= 00
Local _cSourceFile	:= ""
Local _cTargetFile	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a copia dos arquivos XML                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !_lExcJob
	oProcess:SetRegua1( Len( _aDirectory ) )
EndIf

For _nCtDir := 01 To Len( _aDirectory )
	
	If !_lExcJob
		oProcess:IncRegua1( "Copiando arquivos " + StrZero( _nCtDir, 05 ) + " de " + StrZero( Len( _aDirectory ), 05 ) + " ..." )
	EndIf
	
	If Upper( AllTrim( _aDirectory[ _nCtDir ][ 05 ] ) ) == "A"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Defino o nome dos arquivos                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cSourceFile	:= AllTrim( _cSource ) + AllTrim( _aDirectory[ _nCtDir ][ 01 ] )
		_cTargetFile	:= AllTrim( _cTargetImp ) +  AllTrim( _aDirectory[ _nCtDir ][ 01 ] )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua a copia dos arquivos ainda nao copiados               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !File( _cTargetFile )
			Copy File &( _cSourceFile ) To &( _cTargetFile )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se copia bem sucedida, remove arquivo Source                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If File( _cTargetFile )
			FErase( _cSourceFile )
		EndIf
		
	EndIf
	
Next _nCtDir

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrcXMLSC   ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento dos arquivos .XML existentes no diretorio de ³±±
±±³          ³ Importados                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Diretorio Importados                              ³±±
±±³          ³ parm02 = Diretorio Processados                             ³±±
±±³          ³ parm03 = Diretorio Erros                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrcXMLSC( _cTargetImp, _cTargetPrc, _cTargetErr )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _nArqXML	:= 00
Local _cErro	:= ""
Local _cAviso	:= ""
Local _cArqXML	:= ""
Local _cNewXML	:= ""
Local _aFiles	:= Directory( _cTargetImp + _cMascara )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oXML
Private _cAliasXML	:= ""
Private _lOk			:= .T.
Private _cAssunto		:= ""
Private _cBody			:= ""
Private _cFrom    	:= GetMv( "MV_RELFROM" )
Private _cMailTo  	:= GetMv( "MV_XEMAIL" ) //incluida chamada de parametro ao inves de deixar fixo no programa por Adriana Oliveira em 21/09/10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a leitura dos arquivos XML                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !_lExcJob
	oProcess:SetRegua1( Len( _aFiles ) )
EndIf

For _nArqXML := 01 To Len( _aFiles )
	
	_lOk			:= .T.
	_cArqXML		:= Lower( _cTargetImp + AllTrim( _aFiles[ _nArqXML ][ 01 ] ) )
	_lErroDOC	:= .F.
	
	If !_lExcJob
		oProcess:IncRegua1( AllTrim( _cArqXML ) )
	EndIf
	
	_cAssunto	:= "Processamento Aquivo: " + _cArqXML + " em " + DtoC( Date() ) + " - " + Time()
	_cBody		:= "<Htm><br>" + CRLF
	_cErro		:= ""
	
	ConOut( AllTrim( FunName() ) + " - Inicio processamento Aquivo: " + _cArqXML + " em " + DtoC( Date() ) + " - " + Time() )
	
	_cBody		+= "Processamento Arquivo : " + _cArqXML + "<br>" + CRLF
	_cBody		+= "<br>" + CRLF
	
	_cAliasXML	:= Left( _aFiles[ _nArqXML][ 01 ], At( ".", _aFiles[ _nArqXML ][ 01 ] ) -01 )
	
	oXML			:= XMLParserFile( _cArqXML, "_", @_cErro, @_cAviso )
	
	If !( Empty( _cErro ) .And. Empty( _cAviso ) .And. oXML != Nil )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Parser com erro                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cNewXML	:= StrTran( Upper( _cArqXML ), Upper( _cTargetImp ), Upper( _cTargetErr ) )
		
		_cBody	+= "O Arquivo : " + _cArqXML + " / Alias : " + _cAliasXML + " foi copiado para " + _cNewXML + "<br>" + CRLF
		_cBody	+= "Arquivo com Erro : " + _cErro + "<br>" + CRLF
		_cBody	+= _cAviso + "<br>" + CRLF
		_cBody	+= "<br>" + CRLF
		
		ConOut( AllTrim( FunName() ) + " - Atencao Erro: " + _cErro )
		ConOut( AllTrim( FunName() ) + " - O Arquivo " + _cArqXML + " foi copiado para " + _cNewXML )
		
	Else
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua processamento do XML                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fProcXML( oXML, _cAliasXML, @_lOk )
		
		_cNewXML	:=  Iif( _lOk, _cTargetPrc, _cTargetErr ) + AllTrim( _cAliasXML ) + ".XML"
		
		If !_lErroDOC
			_cBody	+= "O Arquivo : " + _cArqXML + " / Alias : " + _cAliasXML + Iif( !_lOk, " nao", "" ) + " foi processado com sucesso <br>" + CRLF
			_cBody	+= "O Arquivo : " + _cArqXML + " / Alias : " + _cAliasXML + " foi copiado para " + _cNewXML + "<br>" + CRLF
		Else
			_cBody	+= "O Arquivo : " + _cArqXML + " / Alias : " + _cAliasXML + " nao foi processado com sucesso <br>" + CRLF
		EndIf
		
		_cBody	+= "<br>" + CRLF
		
		If !_lErroDOC
			ConOut( AllTrim( FunName() ) + " - O Arquivo " + _cArqXML + Iif( !_lOk, " nao", "" ) + " foi processado com sucesso" )
			ConOut( AllTrim( FunName() ) + " - O Arquivo " + _cArqXML + " foi copiado para " + _cNewXML )
		Else
			ConOut( AllTrim( FunName() ) + " - O Arquivo " + _cArqXML + " nao foi processado com sucesso" )
		EndIf
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move XML para o diretorio destino (Processado/Erro)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !_lErroDOC

		Copy File &( _cArqXML ) To &( _cNewXML )
	
		If File( _cNewXML )
			FErase( _cArqXML )
		EndIf
	
	EndIf
	
	_cBody += "</Htm>"
	
	ConOut( AllTrim( FunName() )+ " - Final processamento Aquivo: " + _cArqXML + " em " + DtoC( Date() ) + " - " + Time() )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia email de confirmacao do processamento                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty( _cMailTo )
	  	U_fEnviaMail( _cFrom, _cMailTo, _cAssunto,, _cBody )
	  //	U_fEnviaMail( _cFrom, "ilaine@adoro.com.br", _cAssunto,, _cBody )
	EndIf
	
	If _lErroDOC
		Exit
	EndIf
	
Next _nArqXML

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PrcXMLSC   ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento dos arquivos .XML existentes no diretorio de ³±±
±±³          ³ Importados                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Objeto XML                                        ³±±
±±³          ³ parm02 = Alias XML                                         ³±±
±±³          ³ parm03 = lOK                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcXML( oXML, _cAliasXML, _lOk )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _nRegs		:= 00
Local _nRegXML		:= 00
Local _nMovim		:= 00
Local _cTpMov		:= ""
Local _cArqTrb		:= ""
Local _cArqInd		:= ""
Local _cChave		:= ""
Local _aMovim		:= {}
Local _aCampos		:= {}
Local _aStru		:= {}
Local _cAliasTrb	:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aCampos	:=	{	{ "COD_EMP"		, "C", 02, 00, "EMPRESA"					, "StrZero( 01, 02 )"														},;
					{ "COD_FIL"		, "C", 02, 00, "FILIAL"						, "Left( @@, 02 )"															},;
					{ "TP_MOVIMEN"	, "C", 03, 00, "TIPO_MOVIMENTO"			, "Left( @@, 03 )"															},;
					{ "TP_DE_NOTA"	, "C", 01, 00, "TIPO_DE_NOTA"				, "Left( @@, 01 )"															},;
					{ "FORM_PROP"	, "C", 01, 00, "FORM_PROP"					, "Left( @@, 01 )"															},;
					{ "CLI_FOR"		, "C", 06, 00, "CLI_FOR"					, "PadR( Right( @@, 06 ), 06 )"											},;
					{ "LJ_CLI_FOR"	, "C", 02, 00, "LOJA_CLI_FOR"				, "PadR( Right( @@, 02 ), 02 )"											},;
					{ "ESTADO"		, "C", 02, 00, "ESTADO"						, "PadR( Right( @@, 02 ), 02 )"											},;
					{ "NR_PEDIDO"	, "C", 06, 00, "NR_PEDIDO"					, "PadR( Right( @@, 06 ), 06 )"											},;
					{ "DT_EMISSAO"	, "D", 08, 00, "DATA_EMISSAO"				, "StoD( @@ )"									 								},;
					{ "DT_ENTRADA"	, "D", 08, 00, "DATA_ENTRADA"				, "StoD( @@ )"																	},;
					{ "SERIE"		, "C", 03, 00, "SERIE"						, "PadR( Left( @@, 03 ), 03 )"											},;
					{ "ESPECIE"		, "C", 05, 00, "ESPECIE"					, "PadR( Left( @@, 05 ), 05 )"											},;
					{ "ESP1"			, "C", 10, 00, "ESP1"						, "PadR( Left( @@, 15 ), 15 )"											},;
					{ "ESPQTD"		, "N", 07, 00, "ESPQTD"						, "Val( @@ )" 																	},;
					{ "COD_PROD"	, "C", 15, 00, "COD_PRODUTO"				, "PadR( Left( @@, 15 ), 15 )"											},;
					{ "QUANTIDADE"	, "N", 13, 04, "QUANTIDADE"				, "NoRound( Val( @@ ) / 10000, 04 )"									},;
					{ "UNIDADE"		, "C", 02, 00, "UNIDADE"					, "PadR( Left( @@, 02 ), 02 )"											},;
					{ "VLR_UNIT"	, "N", 15, 04, "VLR_UNITARIO"				, "NoRound( Val( @@ ) / 10000, 04 )"									},;
					{ "VLR_TOTAL"	, "N", 13, 02, "VLR_TOTAL"					, "Val( @@ ) / 100"															},;
					{ "TES"			, "C", 03, 00, "TES"							, "PadR( Left( @@, 03 ), 03 )"											},;
					{ "ALMOXARIFA"	, "C", 02, 00, "ALMOXARIFADO"				, "PadR( Left( @@, 02 ), 02 )"											},;
					{ "BASE_ICMS"	, "N", 13, 02, "BASE_ICMS"					, "Val( @@ ) / 100"															},;
					{ "VLR_ICMS"	, "N", 13, 02, "VLR_ICMS"					, "Val( @@ ) / 100"															},;
					{ "ALIQ_ICMS"	, "N", 05, 02, "ALIQUOTA_ICMS"			, "Val( @@ ) / 100"															},;
					{ "DESC_PERC"	, "N", 05, 02, "DESCONTO_PERCENTUAL"	, "Val( @@ ) / 100"															},;
					{ "DESC_VALOR"	, "N", 13, 02, "DESCONTO_VALOR"			, "Val( @@ ) / 100"															},;
					{ "VLR_BRUTO"	, "N", 13, 02, "VALOR_BRUTO"				, "Val( @@ ) / 100"															},;
					{ "PESO_LIQ"	, "N", 13, 02, "PESO_LIQUIDO"				, "Val( @@ ) / 100"															},;
					{ "GRP_PROD"	, "C", 04, 00, "GRUPO_PRODUTO"			, "PadR( Left( @@, 04 ), 04 )"											},;
					{ "COND_PAG"	, "C", 03, 00, "CONDICAO_PAGTO"			, "PadR( Left( @@, 03 ), 03 )"											},;
					{ "DT_VECNTO"	, "D", 08, 00, "DATA_VENCIMENTO"			, "StoD( @@ )"                                               	},;
					{ "CCUSTO"		, "C", 09, 00, "CENTRO_CUSTO"	 			, "PadR( Left( @@, 09 ), 09 )"											},;
					{ "CCONTABIL"	, "C", 20, 00, "CONTA_CONTABIL"			, "PadR( Left( @@, 20 ), 20 )"											},;
					{ "ITEM_CONT"	, "C", 09, 00, "ITEM_CONTABIL"			, "PadR( Left( @@, 09 ), 09 )"											},;
					{ "NF_COMPRA"	, "C", 06, 00, "NF_COMPRA"					, "PadR( Right( @@, 06 ), 06 )"											},;
					{ "SERIE_COM"	, "C", 03, 00, "SERIE_COM"					, "PadR( Left( @@, 03 ), 03 )"											},;
					{ "ITEM_COM"	, "C", 04, 00, "ITEM_COM"					, "PadR( Left( @@, 04 ), 04 )"											},;
					{ "DT_INTEGRA"	, "D", 08, 00, "DATA_INTEGRACAO"			, "StoD( @@ )"                                              	},;
					{ "MEN1"			, "C", 60, 00, "MEN1"						, "PadR( Left( @@, 60 ), 60 )"											},;
					{ "MEN2"			, "C", 60, 00, "MEN2"						, "PadR( Left( @@, 60 ), 60 )"											},;
					{ "MEN3"			, "C", 60, 00, "MEN3"						, "PadR( Left( @@, 60 ), 60 )"											},;
					{ "MEN4"			, "C", 60, 00, "MEN4"						, "PadR( Left( @@, 60 ), 60 )"											},;
					{ "MEN5"			, "C", 60, 00, "MEN5"						, "PadR( Left( @@, 60 ), 60 )"											},;
					{ "PLACA"		, "C", 08, 00, "PLACA"						, 'PadR( Left( @@, 08 ), 08 )'											},;
					{ "TRANS"		, "C", 06, 00, "TRANS"						, "PadR( Right( @@, 06 ), 06 )"											},;
					{ "TRANS_LOJA"	, "C", 02, 00, "TRANS_LOJA"				, "PadR( Right( @@, 02 ), 02 )"											},;
					{ "GRANJA"		, "C", 06, 00, "GRANJA"						, 'PadR( Left( @@, 06 ), 06 )'											},;
					{ "GRANJADA"	, "C", 04, 00, "GRANJADA"					, 'Iif( SubStr( _cAliasXML, 01, 03 ) == "NFS", PadR( Left( @@, 04 ), 04 ), Space(04) )'		},;
					{ "PESO_BRT"	, "N", 13, 02, "PESO_BRUTO"				, 'Iif( SubStr( _cAliasXML, 01, 03 ) == "NFS", Val( @@ ) / 100, 00 )'					         },;
					{ "FASE"			, "C", 08, 00, "FASE"						, 'Iif( SubStr( _cAliasXML, 01, 03 ) == "NFS", PadR( Left( @@, 08 ), 08 ), Space(08) )'		},;
					{ "ORIGEM"		, "C", 06, 00, "ORIGEM"						, "PadR( Left( @@, 06 ), 06 )"																		} }

_aStru := {}
aEval( _aCampos, {|x| aAdd( _aStru, { x[ 01 ], x[ 02 ], x[ 03 ], x[ 04 ] } ) } )

_cArqTrb	:= CriaTrab( _aStru, .T. )
_cArqInd	:= CriaTrab( Nil, .F. )
_cChave	:= "COD_EMP+COD_FIL+TP_MOVIMEN+TP_DE_NOTA+SERIE+NR_PEDIDO+ESPECIE+CLI_FOR+LJ_CLI_FOR"

If Select( _cAliasTrb ) > 00
	( _cAliasTrb )->( dbCloseArea() )
EndIf

dbUseArea( .T.,, _cArqTrb, _cAliasTrb )

( _cAliasTrb )->( dbCreateIndex( _cArqInd, _cChave, {|| &_cChave }, .F. ) )
( _cAliasTrb )->( dbCommitAll() )
( _cAliasTrb )->( dbGoTop() )

( _cAliasTrb )->( dbClearInd() )
( _cAliasTrb )->( dbSetIndex( _cArqInd ) )
( _cAliasTrb )->( dbSetOrder( 01 ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna quantidade de itens                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nRegs := fRet( oXML, _cAliasXML, "ITENS",,, "LEN" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa arquivos XML                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !_lExcJob
	oProcess:SetRegua2( _nRegs * 02 )
EndIf

For _nRegXML := 01 To _nRegs
	
	If !_lExcJob
		oProcess:IncRegua2()
	EndIf
	
	( _cAliasTrb )->( RecLock( _cAliasTrb, .T. ) )
	aEval( _aCampos, {|x|( _cAliasTrb )->( FieldPut( ( _cAliasTrb )->( FieldPos( x[ 01 ] ) ), &( StrTran( x[ 06 ], "@@", "fRet( oXML, _cAliasXML, 'ITENS'," + AllTrim( Str( _nRegXML ) ) + ",'" + x[ 05 ] + "')" ) ) ) ) } )
	( _cAliasTrb )->( MsUnLock() )
	
	If aScan( _aMovim, ( _cAliasTrb )->( COD_EMP + COD_FIL + TP_MOVIMEN ) ) == 00
		aAdd( _aMovim, ( _cAliasTrb )->( COD_EMP + COD_FIL + TP_MOVIMEN ) )
	EndIf
	
Next _nRegXML

( _cAliasTrb )->( dbCloseArea() )

FErase( _cArqInd + IndexExt() )

For _nMovim := 01 To Len( _aMovim )
	
	_cTpMov	:= Right( _aMovim[ _nMovim ], 03 )
	
	If Select( _cAliasTrb ) > 00
		( _cAliasTrb )->( dbCloseArea() )
	Endif
	
	dbUseArea( .T.,, _cArqTrb, _cAliasTrb )
	
	( _cAliasTrb )->( dbCreateIndex( _cArqInd, _cChave, {|| &_cChave }, .F. ) )
	( _cAliasTrb )->( dbCommitAll() )
	( _cAliasTrb )->( dbGoTop() )
	
	( _cAliasTrb )->( dbClearInd() )
	( _cAliasTrb )->( dbSetIndex( _cArqInd ) )
	( _cAliasTrb )->( dbSetOrder( 01 ) )
	
	cFilAnt	:= ( _cAliasTrb )->COD_FIL
	
	If _cTpMov $ "NFE|PRE"
		fProcNFE( cFilAnt, _cTpMov, _cAliasTrb, @_lOk )
	ElseIf _cTpMov $ "NFS"
		fProcNFS( cFilAnt, _cTpMov, _cAliasTrb, @_lOk )
	EndIf
	
	( _cAliasTrb )->( dbCloseArea() )
	
	FErase( _cArqInd + IndexExt() )
	
Next _nMovim

FErase( _cArqTrb + GetdbExtension() )
FErase( _cArqInd + IndexExt() )

Return( _lOk )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fProcNFE   ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento Notas Fiscais de Entrada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Filial do registro                                ³±±
±±³          ³ parm02 = Tipo de Movimento                                 ³±±
±±³          ³ parm03 = Alias                                             ³±±
±±³          ³ parm03 = _lOk                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcNFE( _cFilReg, _cTpMov, _cAliasTrb, _lOk )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _lErro		:= .F.
Local _lContSX5	:= .T.
Local _lFirst		:= .T.
Local _nPesLCFOP	:= 00
Local _nPesBCFOP	:= 00
Local _nBaseIcm	:= 00
Local _nValIcm		:= 00
Local _nValMerc	:= 00
Local _nValBrut	:= 00
Local _nValUnit	:= 00
Local _nErro		:= 00
Local _nEspQtd		:= 00
Local _cCFOP		:= ""
Local _cMens		:= ""
Local _cLocPad		:= ""
Local _cUM			:= ""
Local _cAliasCli	:= ""
Local _cTipoCli	:= ""
Local _cEstCli		:= ""
Local _cItem		:= ""
Local _cTipoNf		:= ""
Local _cFormul		:= ""
Local _cSerNf		:= ""
Local _cNFiscal	:= ""
Local _cPedXML		:= ""
Local _cEspecie	:= ""
Local _cCliFor		:= ""
Local _cLoja		:= ""
Local _cTransp		:= ""
Local _cTLoja		:= ""
Local _dEmissao	:= ""
Local _dDtDigit	:= ""   
Local _dDtVecnto  := ""
Local _cEstado		:= ""
Local _cCondPag	:= ""
Local _cEsp1		:= ""
Local _cGranja		:= ""
Local _cMensExec	:= ""
Local _aErros		:= {}
Local aCab			:= {}
Local aItem			:= {}
Local _cFilSB1		:= Iif( Empty( xFilial( "SB1" ) ), Space( 02 ), _cFilReg )
Local _cFilSD1		:= Iif( Empty( xFilial( "SD1" ) ), Space( 02 ), _cFilReg )
Local _cFilSF1		:= Iif( Empty( xFilial( "SF1" ) ), Space( 02 ), _cFilReg )
Local _cFilSF4		:= Iif( Empty( xFilial( "SF4" ) ), Space( 02 ), _cFilReg )
Local _lPreNota	:= ( _cTpMov == "PRE" )
Local _cTes 		:= space(03) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
( _cAliasTrb )->( dbGoTop() )

While !( _cAliasTrb )->( Eof() )
	
	cEmpAnt		:= ( _cAliasTrb )->COD_EMP
	_lPreNota	:= ( _cTpMov == "PRE" )
	_lErro		:= .F.
	_cItem		:= StrZero( 01, Len( SD1->D1_ITEM ) )
	_cTipoNf		:= ( _cAliasTrb )->TP_DE_NOTA
	_cFormul		:= ( _cAliasTrb )->FORM_PROP
	_cSerNf		:= SubStr( Alltrim( GetMV( "MV_ADSERSC" ) ), 01, 02 )
	_cPedXML		:= ( _cAliasTrb )->NR_PEDIDO
	_cEspecie	:= ( _cAliasTrb )->ESPECIE
	_cEsp1		:= ( _cAliasTrb )->ESP1
	_nEspqtd		:= ( _cAliasTrb )->ESPQTD
	_cCliFor		:= ( _cAliasTrb )->CLI_FOR
	_cLoja		:= ( _cAliasTrb )->LJ_CLI_FOR
	_cTransp		:= ( _cAliasTrb )->TRANS 
	_cTLoja		:= ( _cAliasTrb )->TRANS_LOJA
	_dEmissao	:= ( _cAliasTrb )->DT_EMISSAO
	_dDtDigit	:= ( _cAliasTrb )->DT_ENTRADA
	_cEstado		:= ( _cAliasTrb )->ESTADO
	_cCondPag	:= ( _cAliasTrb )->COND_PAG
	_dDtVecnto	:= ( _cAliasTrb )->DT_VECNTO
	_cMens		:= AllTrim( ( _cAliasTrb )->MEN1 ) + " "  
	_cMens		+= AllTrim( ( _cAliasTrb )->MEN2 ) + " "   
	_cMens		+= AllTrim( ( _cAliasTrb )->MEN3 ) + " "   
	_cMens		+= AllTrim( ( _cAliasTrb )->MEN4 ) + " "   
	_cMens		+= AllTrim( ( _cAliasTrb )->MEN5 ) + " "  
	_cGranja		:= ( _cAliasTrb )->GRANJA 

	_nBaseIcm	:= 00
	_nValIcm		:= 00
	_nValMerc	:= 00
	_nValBrut	:= 00
	_nPesBrut	:= 00
	_nPesLiq		:= 00
	aItem			:= {}
	_lErroDOC	:= .F.
		
	ConOut( AllTrim( FunName() ) + " - Processando registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) )
	
	_lContSX5 := .T.

	If !U_XMLVldSX5( _cSerNF, @_cMensExec )

		_lErro		:= .T.
		_lContSX5	:= .F.
		
		aAdd( _aErros, "Erro de sequencia de numeracao de Notas Fiscais" )
				
		If !Empty( _cMensExec )
			_cBody	+= AllTrim( _cMensExec ) + "<br>" + CRLF
		Else
			_cBody	+= "Existe erro na sequencia de numeracao de Notas Fiscais, atualize o SX5 !<br>" + CRLF
			_cBody	+= "Erros :<br>" + CRLF
		EndIf
						
		_lOk			:= .F.
		_lErroDOC	:= .T.
				
		Exit
				
	Else

		If !Empty( _cMensExec )

			_lErro		:= .T.
			_lContSX5	:= .T.
		
			aAdd( _aErros, "Erro de sequencia de numeracao de Notas Fiscais" )
				
			_cBody	+= AllTrim( _cMensExec ) + "<br>" + CRLF
						
		EndIf
		
	EndIf
		
	If aScan( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf ) > 00
		( _cAliasTrb )->( dbSkip() )
		Loop
	EndIf
	
	_cAliasCli	:= Iif( _cTipoNF $ "DB", "SA1", "SA2" )
	_cTipoCli	:= Iif( _cTipoNF $ "DB", SA1->A1_TIPO, SA2->A2_TIPO )
	_cEstCli		:= Iif( _cTipoNF $ "DB", SA1->A1_EST, SA2->A2_EST )
  
	If !( _cAliasCli )->( dbSeek( xFilial( _cAliasCli ) + _cCliFor + _cLoja ) )
		
		If !_lErro
			
			aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
			
			_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
			_cBody	+= "Erros :<br>" + CRLF
			
		EndIf
		
		_lOk		:= .F.
		_lErro	:= .T.
		
		_cBody	+= "Cliente/Fornecedor " + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + " nao esta cadastrado!<br>" + CRLF
		_cBody	+= "<br>" + CRLF
		
	EndIf

	SF1->( dbSetOrder( 07 ) )
	
	If SF1->( dbSeek( _cFilSF1 + _cPedXML ) )
		
		_lOk   := .F.
		_lErro := .T.
		
		_cBody	+= "O Documento " + Alltrim( _cPedXML ) +  " nao foi importado, pois ja existe no Sistema !<br>" + CRLF 
		
		_cBody	+= "<br>" + CRLF
 
				
		aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
		
		( _cAliasTrb )->( dbSkip() )
		&&Loop
		exit
	EndIf

	While	!( _cAliasTrb )->( Eof() )					.And.	;
		( _cAliasTrb )->COD_EMP			== cEmpAnt		.And.	;
		( _cAliasTrb )->COD_FIL			== _cFilReg		.And.	;
		( _cAliasTrb )->TP_MOVIMEN		== _cTpMov		.And.	;
		( _cAliasTrb )->TP_DE_NOTA		== _cTipoNf		.And.	;
		( _cAliasTrb )->NR_PEDIDO		== _cPedXML		.And.	;
		( _cAliasTrb )->ESPECIE			== _cEspecie	.And.	;
		( _cAliasTrb )->CLI_FOR			== _cCliFor		.And.	;
		( _cAliasTrb )->LJ_CLI_FOR		== _cLoja
		
		If !_lExcJob
			oProcess:IncRegua2()
		EndIf
		
		_lErroDOC	:= .F.
		_lPreNota	:= Empty( ( _cAliasTrb )->TES )
		_cCFOP		:= ""
		
		If !SB1->( dbSeek( _cFilSB1 + ( _cAliasTrb )->COD_PROD ) )
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "O Produto " + ( _cAliasTrb )->COD_PROD + " nao esta cadastrado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If !SF4->( dbSeek( _cFilSF4 + ( _cAliasTrb )->TES ) ) .And.!_lPreNota
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) +"/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "O TES " + ( _cAliasTrb )->TES + " nao esta cadastrado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		Else
			_cCFOP	:= SF4->F4_CF
		EndIf
		
		If ( _cAliasTrb )->QUANTIDADE == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Quantidade nao informada<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->VLR_UNIT == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf )+ " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Valor Unitario nao informado<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->VLR_TOTAL == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Valor total nao informado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
	
		If _cAliasCli == "SA2" .And. _cFormul == "S"
		
			If !_lPreNota  
			
				dbSelectArea( "SA2" )
				SA2->( dbSetOrder( 01 ) )

				If SA2->( dbSeek( xFilial( "SA2" ) + _cCLiFor + _cLoja ) )
					_cCondPag := SA2->A2_COND
				EndIf

			EndIf

		EndIf
		
		If !_lErro
			
			_cUM			:= Iif( Empty( ( _cAliasTrb )->UNIDADE ), SB1->B1_UM, ( _cAliasTrb )->UNIDADE )
			_nValUnit	:= Round( ( ( _cAliasTrb )->VLR_TOTAL / ( _cAliasTrb )->QUANTIDADE ), 04 )
			_cLocPad		:= IIF(!RetArqProd(SB1->B1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+SB1->B1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_LOCPAD")) //LTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA 
			_cSerNf		:= SubStr( Alltrim( GetMV( "MV_ADSERSC" ) ), 01, 02 )

			If _lFirst
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Solicita e bloqueia numero de nota fiscal                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_cNFiscal	:= GetSX5NFE( ( _cAliasTrb )->NF_COMPRA, _cSerNF )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valida Numeracao da Nota Fiscal Gerada                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lErro	:= Iif( !_lContSX5, !( RetSX5NFE( _cFormul, _cNFiscal, _cSerNF ) ), .F. )

				If _lErro
   	
					aAdd( _aErros, "Erro de sequencia de numeracao de Notas Fiscais" )
				
					_cBody	+= "Existe erro na sequencia de numeracao de Notas Fiscais !<br>" + CRLF
					_cBody	+= "Erros :<br>" + CRLF
				
					_lOk			:= .F.
					_lErroDOC	:= .T.
				
					Exit
				
				EndIf

				_lFirst := .F.
				
			EndIf
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua tratamento Peso X CFOP                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_nPesLCFOP := Iif( !Empty( _cCFOP ) .And. AllTrim( _cCFOP ) $ "1124/2224", 00, ( _cAliasTrb )->PESO_LIQ )
			_nPesBCFOP := Iif( !Empty( _cCFOP ) .And. AllTrim( _cCFOP ) $ "1124/2224", 00, ( _cAliasTrb )->PESO_BRT )
/* 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Formata array de itens                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aItem,	{	{ "D1_FILIAL"	, _cFilSD1							, Nil },;
									{ "D1_COD"		, ( _cAliasTrb )->COD_PROD		, Nil },;
									{ "D1_DOC"		, _cNFiscal							, Nil },;
									{ "D1_SERIE"	, _cSerNF							, Nil },;
									{ "D1_ITEM"		, _cItem								, Nil },;
									{ "D1_UM"		, _cUm								, Nil },;
									{ "D1_QUANT"	, ( _cAliasTrb )->QUANTIDADE	, Nil },;
									{ "D1_VUNIT"	, _nValUnit							, Nil },;
									{ "D1_TOTAL"	, ( _cAliasTrb )->VLR_TOTAL	, Nil },;
									{ "D1_PICM"		, ( _cAliasTrb )->ALIQ_ICMS	, Nil },;
									{ "D1_IPI"		, 00									, Nil },;
									{ "D1_FORNECE"	, ( _cAliasTrb )->CLI_FOR		, Nil },;
									{ "D1_LOJA"		, ( _cAliasTrb )->LJ_CLI_FOR	, Nil },;
									{ "D1_EMISSAO"	, ( _cAliasTrb )->DT_EMISSAO	, Nil },;
									{ "D1_DTDIGIT"	, ( _cAliasTrb )->DT_ENTRADA	, Nil },;
									{ "D1_LOCAL"	, _cLocPad							, Nil },;
									{ "D1_CC"		, ( _cAliasTrb )->CCUSTO		, Nil },;
									{ "D1_CONTA"	, ( _cAliasTrb )->CCONTABIL	, Nil },;
									{ "D1_ITEMCTA"	, ( _cAliasTrb )->ITEM_CONT	, Nil },;
									{ "D1_GRUPO"	, ( _cAliasTrb )->GRP_PROD		, Nil },;
									{ "D1_TP"		, SB1->B1_TIPO						, Nil },;
									{ "D1_FORMUL"	, _cFormul							, Nil },;
									{ "D1_TIPO"		, _cTipoNF							, Nil },;
									{ "D1_PESO"		, _nPesLCFOP						, Nil },;
									{ "D1_DESC"		, ( _cAliasTrb )->DESC_PERC	, Nil },;
									{ "D1_VALDESC"	, ( _cAliasTrb )->DESC_VALOR	, Nil },;
									{ "AUTDELETA"	, "N"									, Nil } } )

*/     
// alterado por hcconsys em 22/01/2010 PARA DEIXAR o arry AITEM com a mesma ordem do SD1 NO SX3 


			If !_lPreNota
				_cTES := ( _cAliasTrb )->TES  		
			EndIf



			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Formata array de itens                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aItem,	{	{ "D1_FILIAL"	, _cFilSD1								, Nil },;
									{ "D1_COD"		, ( _cAliasTrb )->COD_PROD			, Nil },;
									{ "D1_UM"		, _cUm								, Nil },;
									{ "D1_QUANT"	, ( _cAliasTrb )->QUANTIDADE		, Nil },;
									{ "D1_VUNIT"	, _nValUnit							, Nil },;
									{ "D1_TOTAL"	, ( _cAliasTrb )->VLR_TOTAL			, Nil },;
									{ "D1_IPI"		, 00								, Nil },;
									{ "D1_PICM"		, ( _cAliasTrb )->ALIQ_ICMS			, Nil },;
									{ "D1_PESO"		, _nPesLCFOP						, Nil },;
									{ "D1_CONTA"	, ( _cAliasTrb )->CCONTABIL			, Nil },;
									{ "D1_CC"		, ( _cAliasTrb )->CCUSTO			, Nil },;
									{ "D1_ITEMCTA"	, ( _cAliasTrb )->ITEM_CONT			, Nil },;
									{ "D1_FORNECE"	, ( _cAliasTrb )->CLI_FOR			, Nil },;
									{ "D1_LOJA"		, ( _cAliasTrb )->LJ_CLI_FOR		, Nil },;
									{ "D1_LOCAL"	, _cLocPad							, Nil },;
									{ "D1_DOC"		, _cNFiscal							, Nil },;
									{ "D1_EMISSAO"	, ( _cAliasTrb )->DT_EMISSAO		, Nil },;
									{ "D1_DTDIGIT"	, ( _cAliasTrb )->DT_ENTRADA		, Nil },;
									{ "D1_GRUPO"	, ( _cAliasTrb )->GRP_PROD			, Nil },;
									{ "D1_TIPO"		, _cTipoNF							, Nil },;
									{ "D1_SERIE"	, _cSerNF							, Nil },;
									{ "D1_TP"		, SB1->B1_TIPO						, Nil },;
									{ "D1_ITEM"		, _cItem							, Nil },;
									{ "D1_VALDESC"	, ( _cAliasTrb )->DESC_VALOR		, Nil },;
									{ "D1_FORMUL"	, _cFormul							, Nil },;
						   			{ "AUTDELETA"	, "N"								, Nil } } )

			If !_lPreNota //habilitado por Adriana HC, para que a rotina busque a conta do cadastro de TES (por gatilho) e nao do XML
				aAdd( aItem[ Len( aItem ) ], { "D1_TES", _cTES, Nil } )
			EndIf
			
			_cItem		:= Soma1( _cItem, Len( SD1->D1_ITEM ) )
			_nBaseIcm	+= ( _cAliasTrb )->BASE_ICMS
			_nValIcm		+= ( _cAliasTrb )->VLR_ICMS
			_nValMerc	+= ( _cAliasTrb )->VLR_TOTAL
			_nValBrut	+= ( _cAliasTrb )->VLR_BRUTO

			If !( AllTrim( _cCFOP ) $ "1124/2224" )
				_nPesBrut	+= Iif( ( _cAliasTrb )->PESO_BRT == 00, ( _cAliasTrb )->QUANTIDADE, _nPesLCFOP )
				_nPesLiq		+= Iif( ( _cAliasTrb )->PESO_LIQ == 00, ( _cAliasTrb )->QUANTIDADE, _nPesBCFOP )
			EndIf
						
		EndIf
		
		( _cAliasTrb )->( dbSkip() )
		
	EndDo
	
	If !_lErro

/*
		aCab	:=	{	{ "F1_FILIAL"	, _cFilSF1	, Nil },;
						{ "F1_TIPO"		, _cTipoNF	, Nil },;
						{ "F1_FORMUL"	, _cFormul	, Nil },;
						{ "F1_DOC"		, _cNFiscal	, Nil },;
						{ "F1_SERIE"	, _cSerNF	, Nil },;
						{ "F1_EMISSAO"	, _dEmissao	, Nil },;
						{ "F1_DTDIGIT"	, _dDtDigit	, Nil },;
						{ "F1_FORNECE"	, _cCliFor	, Nil },;
						{ "F1_LOJA"		, _cLoja		, Nil },;
						{ "F1_EST"		, _cEstado	, Nil },;
						{ "F1_COND"		, _cCondPag	, Nil },;
						{ "F1_ESPECIE"	, _cEspecie	, Nil },;
						{ "F1_BASEICM"	, _nBaseIcm	, Nil },;
						{ "F1_VALICM"	, _nValIcm	, Nil },;
						{ "F1_VALMERC"	, _nValMerc	, Nil },;
						{ "F1_VALBRUT"	, _nValBrut	, Nil },;
						{ "F1_PESOL"	, _nPesLiq	, Nil },;
						{ "F1_PLIQUI"	, _nPesLiq	, Nil },;
						{ "F1_PBRUTO"	, _nPesBrut	, Nil },;
						{ "F1_ESPECI1" , _cEsp1   	, Nil },;
						{ "F1_VOLUME1"	, _nEspQtd	, Nil },;
 						{ "F1_MOEDA"	, 01			, Nil },;
						{ "F1_MENNOTA"	, _cMens		, Nil } } 
                        //{ "F1_ORIGEM"	, "LEXMLSC"	, Nil },;
*/

// alterado por hcconsys para deixar o ACAB com a mesma ordem do SF1 NO SX3 
  
				aCab	:=	{	{ "F1_FILIAL"	, _cFilSF1	, Nil },;
						{ "F1_DOC"		, _cNFiscal	, Nil },;
						{ "F1_SERIE"	, _cSerNF	, Nil },;
						{ "F1_FORNECE"	, _cCliFor	, Nil },;
						{ "F1_LOJA"		, _cLoja	, Nil },;
						{ "F1_COND"		, _cCondPag	, Nil },;
						{ "F1_EMISSAO"	, _dEmissao	, Nil },;
						{ "F1_EST"		, _cEstado	, Nil },;
						{ "F1_BASEICM"	, _nBaseIcm	, Nil },;
						{ "F1_VALICM"	, _nValIcm	, Nil },;
						{ "F1_VALMERC"	, _nValMerc	, Nil },;
						{ "F1_VALBRUT"	, _nValBrut	, Nil },;
						{ "F1_TIPO"		, _cTipoNF	, Nil },;
						{ "F1_DTDIGIT"	, _dDtDigit	, Nil },;
						{ "F1_FORMUL"	, _cFormul	, Nil },;
						{ "F1_ESPECIE"	, _cEspecie	, Nil },;
						{ "F1_PESOL"	, _nPesLiq	, Nil },;
						{ "F1_MENNOTA"	, ALLTRIM(_cMens), Nil },; 
						{ "F1_MOEDA"	, 01		, Nil }}//,;
/*						{ "F1_VOLUME1"	, _nEspQtd	, Nil },;
						{ "F1_VOLUME2"	, 0	, Nil },;
						{ "F1_VOLUME3"	, 0	, Nil },;
						{ "F1_VOLUME4"	, 0	, Nil }},;
						{ "F1_PLIQUI"	, _nPesLiq	, Nil },;
						{ "F1_PBRUTO"	, _nPesBrut	, Nil },;
						{ "F1_ESPECI1" 	, _cEsp1   	, Nil },;
						{ "F1_ESPECI2" 	, SPACE(10) 	, Nil },;
						{ "F1_ESPECI3" 	, SPACE(10)    	, Nil },;
						{ "F1_ESPECI4" 	, SPACE(10)    	, Nil },;
						{ "F1_NFELETR" 	,SPACE(8)  	, Nil },;
						{ "F1_CODNFE" 	,SPACE(8)  	, Nil },;
						{ "F1_EMINFE" 	,ctod("  /  /  ")  	, Nil },;
						{ "F1_HORNFE" 	,space(6)  	, Nil },;						
						{ "F1_CREDNFE" 	,space(17)  	, Nil },;						
						{ "F1_TRANSP" 	,space(6)  		, Nil },;						
						{ "F1_NUMRPS" 	,space(12)  	, Nil },; 
						{ "F1_CHVNFE" 	,space(44)  	, Nil }} 
*/


                        //{ "F1_ORIGEM"	, "LEXMLSC"	, Nil },;


		lMsErroAuto := .F.
		
		If _lPreNota
			
			dDataBase := _dDtDigit
			
			MSExecAuto( {|x,y,z| Mata140( x, y, z ) }, aCab, aItem, 03 )
			
			If lMsErroAuto
				
				If !_lExcJob
					MostraErro()
				EndIf
				
			Else
				
				SF1->( dbSetOrder( 01 ) )
				
				If SF1->( dbSeek( _cFilSF1 + _cNFiscal + _cSerNf + _cCliFor + _cLoja + _cTipoNf ) )

					Reclock( "SF1", .F. )
					SF1->F1_PESOL 			:= _nPesLiq
					SF1->F1_PLIQUI			:= _nPesLiq
					SF1->F1_PBRUTO			:= _nPesBrut
					SF1->F1_ESPECI1		:= _cEsp1
					SF1->F1_VOLUME1		:= _nEspQtd
					SF1->F1_MENNOTA		:= SUBS(_cMens,1,140)
					SF1->F1_MENNOTB		:= SUBS(_cMens,141,280)
					SF1->F1_TRANSP			:= _cTransp 
					SF1->F1_LOJATRA		:= _cTLoja 					
					SF1->F1_GRANJA			:= _cGranja 
					SF1->F1_PEDXML			:= _cPedXML
					SF1->( MsUnlock() )

				EndIf				
				
			EndIf
			
		Else
			
			dDataBase := _dDtDigit
			
			MSExecAuto( {|x,y,z| Mata103( x, y, z ) }, aCab, aItem, 03 )
			
			If lMsErroAuto
				
//				If !_lExcJob
					MostraErro()
//				EndIf
				
			Else
				
				SF1->( dbSetOrder( 01 ) )
				
				Reclock( "SF1", .F. )
				SF1->F1_PESOL 			:= _nPesLiq
				SF1->F1_PLIQUI			:= _nPesLiq
				SF1->F1_PBRUTO			:= _nPesBrut
				SF1->F1_ESPECI1		:= _cEsp1
				SF1->F1_VOLUME1		:= _nEspQtd
				SF1->F1_MENNOTA		:= SUBS(_cMens,1,140)
				SF1->F1_MENNOTB		:= SUBS(_cMens,141,280)
				SF1->F1_TRANSP			:= _cTransp 
				SF1->F1_LOJATRA		:= _cTLoja 					
				SF1->F1_GRANJA			:= _cGranja 
				SF1->F1_PEDXML			:= _cPedXML
				SF1->( MsUnlock() )
			
				If !Empty( _dDtVecnto )   
				
					if _dEmissao >= _dDtVecnto   		//incluido por Adriana Oliveira em 21/09/10 para atender chamado 007937
						_dDtVecnto := _dEmissao + 7  	//quando data de emissao for maior ou igual a data de vencimento o sistema altera a data 
					endif								//de vencimento para 7 dias da data da emissao

					dbSelectArea( "SE2" )
					SE2->( dbSetOrder( 06 ) )
					dbSeek(Xfilial("SE2")+SF1->F1_FORNECE + SF1->F1_LOJA + SF1->F1_SERIE + SF1->F1_DOC,.T. )
		
					While SF1->( F1_FORNECE + F1_LOJA + F1_SERIE + F1_DOC ) == SE2->( E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) .And. SE2->( !Eof() )

						dbSelectArea( "SE2" )

						RecLock("SE2",.F.)
						SE2->E2_VENCTO		:= _dDtVecnto
						SE2->E2_VENCREA	:= DataValida( _dDtVecnto )
						SE2->E2_VENCORI	:= _dDtVecnto
						SE2->E2_DATALIB := DDatabase
						SE2->E2_HIST    := SE2->E2_HIST + 'fProcNFE'  // Ricardo Lima - 05/06/18
						SE2->( MsUnlock() )
			
						SE2->( dbSkip() )
		
					EndDo

				EndIf 			
			
				SF1->( dbSetOrder( 01 ) )
			
			EndIf
	
		EndIf
		
		If lMsErroAuto
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cNFiscal + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_aErros	:= GetAutoGrLog()
			
			For _nErro := 01 To Len( _aErros )
				_cBody += _aErros[ _nErro ] + "<br>" + CRLF
			Next _nErro
			
			_cBody += "<br>" + CRLF
			
		Else
			
			_cBody	+= "A NFE " + _cNFiscal + " referente ao registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " foi importado com sucesso!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
	EndIf

	If _lErroDOC
		Exit
	EndIf
		
EndDo

Return( _lOk )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fProcNFS   ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processamento Notas Fiscais de Saida                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Filial do registro                                ³±±
±±³          ³ parm02 = Tipo de Movimento                                 ³±±
±±³          ³ parm03 = Alias                                             ³±±
±±³          ³ parm04 = _lOk                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcNFS( _cFilReg, _cTpMov, _cAliasTrb, _lOk )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _lErro		:= .F.
Local _lLibCred	:= .T.
Local _lContSX5	:= .T.
Local _nErro		:= 00
Local _nValMerc	:= 00
Local _nValBrut	:= 00
Local _nQtdLib		:= 00
Local _cMen1		:= ""
Local _cMen2		:= ""
Local _cMen3		:= ""
Local _cMen4		:= ""
Local _cMen5		:= ""
Local _cPedXML		:= ""
Local _cChaveTrb	:= ""
Local _cItem		:= ""
Local _cTipoNf		:= ""
Local _cEspecie	:= ""
Local _cEsp1		:= ""
Local _cCliFor		:= ""
Local _cLoja		:= ""
Local _dEmissao	:= ""
Local _dDtDigit	:= ""
Local _cEstado		:= ""
Local _cCondPag	:= ""
Local _cNFOri		:= ""
Local _cSerOri		:= ""
Local _cItemOri	:= ""
Local _cProduto	:= ""
Local _cAliasCli	:= ""
Local _cTipoCli	:= ""
Local _cEstCli		:= ""
Local _cPedido		:= ""
Local _cPlaca		:= ""
Local _cGranja		:= ""
Local _cGranjada	:= ""
Local _cFase		:= ""
Local _cMensExec	:= ""
Local _aErros		:= {}
Local aCab			:= {}
Local aItem			:= {}
Local _aPvlNfs		:= {}
Local _cFilSB1		:= Iif( Empty( xFilial( "SB1" ) ), Space( 02 ), _cFilReg )
Local _cFilSB2		:= Iif( Empty( xFilial( "SB2" ) ), Space( 02 ), _cFilReg )
Local _cFilSC5		:= Iif( Empty( xFilial( "SC5" ) ), Space( 02 ), _cFilReg )
Local _cFilSC6		:= Iif( Empty( xFilial( "SC6" ) ), Space( 02 ), _cFilReg )
Local _cFilSC9		:= Iif( Empty( xFilial( "SC9" ) ), Space( 02 ), _cFilReg )
Local _cFilSE4		:= Iif( Empty( xFilial( "SE4" ) ), Space( 02 ), _cFilReg )
Local _cFilSF2		:= Iif( Empty( xFilial( "SF2" ) ), Space( 02 ), _cFilReg )
Local _cFilSF4		:= Iif( Empty( xFilial( "SF4" ) ), Space( 02 ), _cFilReg )
Local _cFilSD1		:= Iif( Empty( xFilial( "SD1" ) ), Space( 02 ), _cFilReg )
Local _cFilSF1		:= Iif( Empty( xFilial( "SF1" ) ), Space( 02 ), _cFilReg )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Private                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lMsErroAuto	:= .F.
Private _cPed       := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Publicas                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Public _cNFiscal
Public _cSerNf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
( _cAliasTrb )->( dbGoTop() )

While	!( _cAliasTrb )->( Eof() )
	
	_lErro		:= .F.
	_nValMerc	:= 00
	_nValBrut	:= 00
	_nPesLiq		:= 00
	_nPesBrut	:= 00
	_cItemOri	:= Space( 04 )
	aItem			:= {}
	_cItem		:= StrZero( 01, Len( SC6->C6_ITEM ) )
	_cTipoNf		:= ( _cAliasTrb )->TP_DE_NOTA
	_cSerNf		:= SubStr( Alltrim( GetMV( "MV_ADSERSC" ) ), 01, 02 )
	_cPedXML		:= ( _cAliasTrb )->NR_PEDIDO
	_cEspecie	:= ( _cAliasTrb )->ESPECIE
	_cEsp1		:= ( _cAliasTrb )->ESP1
	_cCliFor		:= ( _cAliasTrb )->CLI_FOR
	_cLoja		:= ( _cAliasTrb )->LJ_CLI_FOR
	_dEmissao	:= ( _cAliasTrb )->DT_EMISSAO
	_dDtDigit	:= ( _cAliasTrb )->DT_ENTRADA
	_cEstado		:= ( _cAliasTrb )->ESTADO
	_cCondPag	:= ( _cAliasTrb )->COND_PAG
	_cNFOri		:= ( _cAliasTrb )->NF_COMPRA
	_cSerOri		:= ( _cAliasTrb )->SERIE_COM
	_cMen1		:= PadR( AllTrim( ( _cAliasTrb )->MEN1 ), 70 )
	//_cMen2		+= PadR( AllTrim( ( _cAliasTrb )->MEN2 ), 70 )
	//_cMen3		+= PadR( AllTrim( ( _cAliasTrb )->MEN3 ), 70 )
	//_cMen4		+= PadR( AllTrim( ( _cAliasTrb )->MEN4 ), 70 )
	//_cMen5		+= PadR( AllTrim( ( _cAliasTrb )->MEN5 ), 70 )
	_cMen2		:= PadR( AllTrim( ( _cAliasTrb )->MEN2 ), 70 )
	_cMen3		:= PadR( AllTrim( ( _cAliasTrb )->MEN3 ), 70 )
	_cMen4		:= PadR( AllTrim( ( _cAliasTrb )->MEN4 ), 70 )
	_cMen5		:= PadR( AllTrim( ( _cAliasTrb )->MEN5 ), 70 )	
	_cPlaca		:= ( _cAliasTrb )->PLACA
	_cTransp		:= ( _cAliasTrb )->TRANS
	_cGranja		:= ( _cAliasTrb )->GRANJA
	_cGranjada	:= ( _cAliasTrb )->GRANJADA
	_cFase		:= ( _cAliasTrb )->FASE
	_cProduto	:= ( _cAliasTrb )->COD_PROD
	_lErroDOC	:= .F.

	ConOut( AllTrim( FunName() ) + " - Processando registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) )
	
	_lContSX5 := .T.
   &&retirada validacao abaixo por se tratar de importacao de pedidos e nao ha necessidade de verificar sequencia de numero para NF.
   /*
	If !U_XMLVldSX5( _cSerNF, @_cMensExec )

		_lErro		:= .T.
		_lContSX5	:= .F.
		
		aAdd( _aErros, "Erro de sequencia de numeracao de Notas Fiscais" )
				
		If !Empty( _cMensExec )
			_cBody	+= AllTrim( _cMensExec ) + "<br>" + CRLF
		Else
			_cBody	+= "Existe erro na sequencia de numeracao de Notas Fiscais, atualize o SX5 !<br>" + CRLF
			_cBody	+= "Erros :<br>" + CRLF
		EndIf
						
		_lOk			:= .F.
		_lErroDOC	:= .T.
				
		Exit
				
	Else

		If !Empty( _cMensExec )

			_lErro		:= .T.
			_lContSX5	:= .T.

			aAdd( _aErros, "Erro de sequencia de numeracao de Notas Fiscais" )
				
			_cBody	+= AllTrim( _cMensExec ) + "<br>" + CRLF
						
		EndIf
		
	EndIf
	*/

	If aScan( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf ) > 00
		( _cAliasTrb )->( dbSkip() )
		Loop
	EndIf
	
	If _cTipoNF $ "DB"
		
		_cAliasCli	:= "SA2"
		_cTipoCli	:= "R"
		_cEstCli		:= SA2->A2_EST
	
	Else
		
		dbSelectArea( "SA1" )
		dbSetOrder( 01 )
		dbSeek( xFilial( "SA1" ) + _cCLiFor + _cLoja )
		
		_cAliasCli	:= "SA1"
		_cTipoCli	:= SA1->A1_TIPO
		_cEstCli		:= SA1->A1_EST
		
	EndIf
	
	If !( _cAliasCli )->( dbSeek( xFilial( _cAliasCli ) + _cCliFor + _cLoja ) )
		
		If !_lErro
			
			aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
			
			_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf )+ " nao foi importado!<br>" + CRLF
			_cBody	+= "Erros :<br>" + CRLF
			
		EndIf
		
		_lOk		:= .F.
		_lErro	:= .T.
		
		_cBody	+= "Cliente/Fornecedor " + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + " nao esta cadastrado!<br>" + CRLF
		_cBody	+= "<br>" + CRLF
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera Pedido de Vendas                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( _cAliasTrb )
	
	
&& Mauricio 30/03/10 - Retirado toda referencia a pegar numero do pedido automaticamente pois o MSEXECAUTO ja traz a numeração automaticamente.
&& passado para a variavel _cpedido entao o numero do XML para nova logica e continuidade da rotina
// INICIO ALTERACAO HCCONSYS EM 25/03/10 
	
//	_cPedido := RetAsc( Soma1( SubStr( _cPedXML, 01, 01 ) ), 01, .T. ) + SubStr( _cPedXML, 02 )

	//_cPedido := GetSX8Num("SC5","C5_NUM") 
    //ConfirmSX8()  &&Mauricio - 26/03/10.Confirma uso do numero do pedido na importacao.

// FIM ALTERACAO HCCONSYS EM 25/03/10

    _cPedido := _cPedXML
	
	While	!( _cAliasTrb )->( Eof() )				.And.	;
		( _cAliasTrb )->COD_EMP		== cEmpAnt		.And.	;
		( _cAliasTrb )->COD_FIL		== _cFilReg		.And.	;
		( _cAliasTrb )->TP_MOVIMEN	== _cTpMov		.And.	;
		( _cAliasTrb )->TP_DE_NOTA	== _cTipoNf		.And.	;
		( _cAliasTrb )->NR_PEDIDO	== _cPedXML		.And.	;
		( _cAliasTrb )->ESPECIE		== _cEspecie	.And.	;
		( _cAliasTrb )->CLI_FOR		== _cCliFor		.And.	;
		( _cAliasTrb )->LJ_CLI_FOR	== _cLoja
		
		If !_lExcJob
			oProcess:IncRegua2()
		EndIf
		&& Mauricio 30/03/10 - retirado pois a rotina não recebe mais o numero do pedido, não sendo necessária mais a consistencia.
		&&dbSelectArea( "SC5" )
		&&dbSetOrder( 01 )
		&&
		&&If SC5->( dbSeek( xFilial( "SC5" ) + _cPedido ) )
		&&	
		&&	If !_lErro
		&&		
		&&		aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
		&&		
		&&		_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
		&&		_cBody	+= "Erros :<br>" + CRLF
		&&		
		&&	EndIf
		&&	
		&&	_lOk		:= .F.
		&&	_lErro	:= .T.
		&&	
		&&	_cBody	+= "Pedido " + _cPedido + " ja cadastrado!<br>" + CRLF
		&&	_cBody	+= "<br>" + CRLF
		&&	
		&&EndIf
		
		&&Tratamento para numero de pedido xml ja gravado na tabela SC5.
		dbSelectArea( "SC5" )
		dbSetOrder( 12 )
		
		If SC5->( dbSeek( xFilial( "SC5" ) + _cPedXML ) )
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Pedido xml " + _cPedXML + " ja cadastrado no SC5!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf

		If !SB1->( dbSeek( _cFilSB1 + ( _cAliasTrb )->COD_PROD ) )
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "O Produto " + ( _cAliasTrb )->COD_PROD + " nao esta cadastrado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If !SF4->( dbSeek( _cFilSF4 + ( _cAliasTrb )->TES ) )
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf )+ " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "O TES " + ( _cAliasTrb )->TES + " nao esta cadastrado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->QUANTIDADE == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Quantidade nao informada!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->VLR_UNIT == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg+ _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Valor Unitario nao informado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->VLR_TOTAL == 00
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Valor total nao informado!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		EndIf
		
		If ( _cAliasTrb )->TP_DE_NOTA $ "D"
			
			_cChaveTrb := ( _cAliasTrb )->( NF_COMPRA + SERIE_COM + CLI_FOR + LJ_CLI_FOR + COD_PROD )
			
			SD1->( dbSetOrder( 01 ) )
			
			If !SD1->( dbSeek( _cFilSD1 + _cChaveTrb, .T. ) )
				
				_cBody += "O Registro " + _cChaveTrb + " nao foi importado, pois nao existe nf de entrada !<br>" + CRLF
				
				aAdd( _aErros, _cFilReg + _cChaveTrb )
				
				_lOk		:= .F.
				_lErro	:= .T.
				
			Else
				_cItemOri := SD1->D1_ITEM
			EndIf
			
		EndIf
		
		If Alltrim(( _cAliasTrb )->SERIE) == "M1"  
			_lOk   := .F.
			_lErro := .T.
		
			_cBody	+= "O Documento " + Alltrim( _cPedXML ) +  " nao foi importado, SERIE invalida !<br>" + CRLF 
		
			_cBody	+= "<br>" + CRLF
 				
			aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
			
		Endif			
		
		If !_lErro
			
			_cUM		:= Iif( Empty( ( _cAliasTrb )->UNIDADE ), SB1->B1_UM, ( _cAliasTrb )->UNIDADE )
			_cLocPad	:= IIF(!RetArqProd(SB1->B1_COD),POSICIONE("SBZ",1,xFilial("SBZ")+SB1->B1_COD,"BZ_LOCPAD"),POSICIONE("SB1",1,xFilial("SB1")+SB1->B1_COD,"B1_LOCPAD")) //LTERACAO REFERENTE A TABELA SBZ INDICADORES DE PRODUTOS CHAMADO 030317 - WILLIAM COSTA 
			
			If SB1->B1_CONV <= 01
				
				aAdd( aItem,	{	{ "C6_FILIAL"	, _cFilSC6							, Nil },;
										{ "C6_ITEM"		, _cItem								, Nil },;
										{ "C6_PRODUTO"	, ( _cAliasTrb )->COD_PROD		, Nil },;
										{ "C6_DESCRI"	, SB1->B1_DESC						, Nil },;
										{ "C6_UNSVEN"	, ( _cAliasTrb )->QUANTIDADE	, Nil },;
										{ "C6_PRCVEN"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										{ "C6_UM"		, _cUM								, Nil },;
										{ "C6_QTDVEN"	, ( _cAliasTrb )->QUANTIDADE	, Nil },;
										{ "C6_TES"		, ( _cAliasTrb )->TES			, Nil },;
										{ "C6_QTDLIB"	, 0									, Nil },;
										{ "C6_LOCAL"	, _cLocPad							, Nil },;
										{ "C6_CLI"		, ( _cAliasTrb )->CLI_FOR		, Nil },;
										{ "C6_DESCONT"	, ( _cAliasTrb )->DESC_PERC	, Nil },;
										{ "C6_VALDESC"	, ( _cAliasTrb )->DESC_VALOR	, Nil },;
										{ "C6_ENTREG"	, ( _cAliasTrb )->DT_EMISSAO	, Nil },;
										{ "C6_NFORI"	, ( _cAliasTrb )->NF_COMPRA	, Nil },;
										{ "C6_SERIORI"	, ( _cAliasTrb )->SERIE_COM	, Nil },;
										{ "C6_ITEMORI"	, _cItemOri							, Nil },;
										{ "C6_LOJA"		, ( _cAliasTrb )->LJ_CLI_FOR	, Nil },;
										{ "C6_PRUNIT"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										{ "C6_OP"		, "02"								, Nil } } )																				
										//{ "C6_NUM"		, _cPedido							, Nil },;
                                        //{ "C6_PRUNIT"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										//{ "C6_OP"		, "02"								, Nil } } )																				
				
			Else
				
				aAdd( aItem,	{	{ "C6_FILIAL"	, _cFilSC6							, Nil },;
										{ "C6_ITEM"		, _cItem								, Nil },;
										{ "C6_PRODUTO"	, ( _cAliasTrb )->COD_PROD		, Nil },;
										{ "C6_DESCRI"	, SB1->B1_DESC						, Nil },;
										{ "C6_SEGUM"	, _cUM								, Nil },;
										{ "C6_UNSVEN"	, ( _cAliasTrb )->QUANTIDADE	, Nil },;
										{ "C6_PRCVEN"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										{ "C6_UM"		, _cUM								, Nil },;
										{ "C6_QTDVEN"	, ( _cAliasTrb )->QUANTIDADE	, Nil },;
										{ "C6_TES"		, ( _cAliasTrb )->TES			, Nil },;
										{ "C6_QTDLIB"	, 00 									, Nil },;
										{ "C6_LOCAL"	, _cLocPad							, Nil },;
										{ "C6_CLI"		, ( _cAliasTrb )->CLI_FOR		, Nil },;
										{ "C6_DESCONT"	, ( _cAliasTrb )->DESC_PERC	, Nil },;
										{ "C6_VALDESC"	, ( _cAliasTrb )->DESC_VALOR	, Nil },;
										{ "C6_ENTREG"	, ( _cAliasTrb )->DT_EMISSAO	, Nil },;
										{ "C6_NFORI"	, ( _cAliasTrb )->NF_COMPRA	, Nil },;
										{ "C6_SERIORI"	, ( _cAliasTrb )->SERIE_COM	, Nil },;
										{ "C6_ITEMORI"	, _cItemOri							, Nil },;
										{ "C6_LOJA"		, ( _cAliasTrb )->LJ_CLI_FOR	, Nil },;
										{ "C6_PRUNIT"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										{ "C6_OP"		, "02"								, Nil },;
										{ "C6_TPOP"		, "F"									, Nil } } )										
										//{ "C6_NUM"		, _cPedido							, Nil },;
										//{ "C6_PRUNIT"	, ( _cAliasTrb )->VLR_UNIT		, Nil },;
										//{ "C6_OP"		, "02"								, Nil },;
										//{ "C6_TPOP"		, "F"									, Nil } } )										
				
			EndIf
			
			_cItem		:= Soma1( _cItem, Len( SC6->C6_ITEM ) )
			_nPesLiq		+= ( _cAliasTrb )->PESO_LIQ
			_nPesBrut	+= ( _cAliasTrb )->PESO_BRT
			
			
		EndIf
		
		( _cAliasTrb )->( dbSkip() )
		
	EndDo
	
	
	If _lErro
		RollBackSxe()
		Loop
	EndIf
	
	//aCab	:=	{	{ "C5_FILIAL"	, _cFilSC5		, Nil },;
	//				{ "C5_NUM"		, _cPedido		, Nil },;
	aCab	:=	{	{ "C5_FILIAL"	, _cFilSC5		, Nil },;				
					{ "C5_TIPO"		, _cTipoNF		, Nil },;
					{ "C5_CLIENTE"	, _cCliFor		, Nil },;
					{ "C5_LOJAENT"	, _cLoja			, Nil },;
					{ "C5_LOJACLI"	, _cLoja			, Nil },;
					{ "C5_CONDPAG"	, _cCondPag		, Nil },;
					{ "C5_PLACA"	, _cPlaca		, Nil },;
					{ "C5_TIPLIB" 	, "1"				, Nil },;
					{ "C5_TIPOCLI"	, _cTipoCli		, Nil },;
					{ "C5_EMISSAO"	, _dEmissao		, Nil },;
					{ "C5_MOEDA"	, 01				, Nil },;
					{ "C5_ESPECI1"	, _cEsp1			, Nil },;
					{ "C5_MENNOTA"	, _cMen1			, Nil },;
					{ "C5_MENNOT2"	, _cMen2			, Nil },;
					{ "C5_MENNOT3"	, _cMen3			, Nil },;
					{ "C5_MENNOT4"	, _cMen4			, Nil },;
					{ "C5_MENNOT5"	, _cMen5			, Nil },;
					{ "C5_PBRUTO"	, _nPesBrut		, Nil },;
					{ "C5_PESOL"	, _nPesLiq		, Nil },;
					{ "C5_LIBEROK"	, "S"				, Nil },;
					{ "C5_PEDXML"	, _cPedXML		, Nil },;
					{ "C5_GRANJA"	, _cGranja		, Nil },;
					{ "C5_GRANJDA"	, _cGranjada	, Nil },;
					{ "C5_PEDXML"	, _cPedXML		, Nil },;
					{ "C5_FASE"		, _cFase			, Nil } }
	
	RegToMemory( "SC5" )
	M->C5_FILIAL := _cFilSC5
	
	RegToMemory( "SC6" )
	M->C6_FILIAL := _cFilSC6
	
	lMsErroAuto := .F.
	
	Mata410( aCab, aItem, 03 )
	
	SC5->( MsUnLockAll() )
	SC6->( MsUnLockAll() )
	SC9->( MsUnLockAll() )
	
	SC5->( FKCommit() )
	SC6->( FKCommit() )
	SC9->( FKCommit() )
	
	SysRefresh()
	
	If lMsErroAuto
		
		If !_lExcJob
			MostraErro()
		EndIf
		
		If !_lErro
			
			aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
			
			_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
			_cBody	+= "Erros :<br>" + CRLF
			
		EndIf
		
		_lOk		:= .F.
		_lErro	:= .T.
		
		_aErros := GetAutoGrLog()
		
		For _nErro := 01 To Len( _aErros )
			_cBody += _aErros[ _nErro ] + "<br>" + CRLF
		Next _nErro
		
		_cBody += "<br>" + CRLF
		
	Else
	    &&Mauricio 30/03/10 - Novo tratamento para pegar o numero do pedido gerado pelo MSEXECAUTO.
	    DbSelectArea("SC5")
	    DbSetorder(12)
	    If SC5->( dbSeek( xFilial( "SC5" ) + _cPedXML ) )
	       _cPed := SC5->C5_NUM
	    else
	       _cPed := "Nao encont."
	    endif   
		
		_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPed ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " foi gerado o pedido " + AllTrim( _cPed ) + " com sucesso!<br>" + CRLF
		_cBody	+= "<br>" + CRLF
		
	EndIf
	
	dbSelectArea( _cAliasTrb )
	
	If _lErro
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Liberacao do Pedido de Vendas                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC5->( dbSetOrder( 01 ) )
	SC6->( dbSetOrder( 01 ) )
	SE4->( dbSetOrder( 01 ) )
	SB1->( dbSetOrder( 01 ) )
	SB2->( dbSetOrder( 01 ) )
	SF4->( dbSetOrder( 01 ) )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define variaveis usadas no MATA440                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lGerouPv		:= .T.
	lLiber		:= .F.
	lTrans		:= .F.
	lCredito		:= .F.
	lEstoque		:= .F.
	lAvCred		:= .T.
	lAvEst		:= .T.
	lLiberOk		:= .T.
	lItLib		:= .T.
	aPvlNfs		:= {}
	dDataBase	:= _dEmissao
	
	dbSelectArea( _cAliasTrb )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa liberacao do Pedido de Vendas                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&&Mauricio 30/03/10 - Tratamento para nova forma de vir o numero do pedido
	&&SC5->( dbSeek( _cFilSC5 + _cPedido ) )
	&&SC6->( dbSeek( _cFilSC6 + _cPedido ) )
	
	SC5->( dbSeek( _cFilSC5 + _cPed ) )
	SC6->( dbSeek( _cFilSC6 + _cPed ) )
	
	While !SC6->( Eof() ) .And. SC6->C6_FILIAL == _cFilSC6 .And. SC6->C6_NUM  == _cPed
		
		_nQtdLib := SC6->C6_QTDVEN
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros para efetuar a liberacao                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB1->( dbSeek( _cFilSB1 + SC6->C6_PRODUTO ) )
		
		_nQtdLib := MaLibDoFat( SC6->( Recno() ), _nQtdLib, @lCredito, @lEstoque, lAvCred, lAvEst, lLiber, lTrans )
		
		If _nQtdLib != SC6->C6_QTDVEN
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
				_cBody	+= "O Registro " + AllTrim( _cTpMov ) + "-" + AllTrim( _cFilReg ) + "/" + AllTrim( _cPedXML ) + "/" + AllTrim( _cSerNf ) + "/" + AllTrim( _cCliFor ) + "/" + AllTrim( _cLoja ) + "/" + AllTrim( _cTipoNf ) + " nao foi importado!<br>" + CRLF
				_cBody	+= "Erros :<br>" + CRLF
				
			EndIf
			
			lGerouPv	:= .F.
			_lOk		:= .F.
			_lErro	:= .T.
			
			_cBody	+= "Nao foi possivel liberar o Produto " + AllTrim( SC6->C6_PRODUTO ) + "!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
		Else
			
			SC9->( RecLock( "SC9", .F. ) )
			SC9->C9_BLEST	:= " "
			SC9->( MsUnLock() )
			
		EndIf

		If !Empty( SC9->C9_BLCRED )
			
			If !_lErro
				
				aAdd( _aErros, _cFilReg + _cPedXML + _cSerNf + _cCliFor + _cLoja + _cTipoNf )
				
			EndIf
			
			_lOk			:= .F.
			_lErro		:= .T.
			_lLibCred	:= .F.
			
			_cBody	+= "Nao foi possivel liberar o credito do Produto " + AllTrim( SC6->C6_PRODUTO ) + "!<br>" + CRLF
			_cBody	+= "<br>" + CRLF
			
			
		EndIf
		
		SE4->( dbSeek( _cFilSE4 + SC5->C5_CONDPAG ) )
		SB1->( dbSeek( _cFilSB1 + SC6->C6_PRODUTO ) )
		SB2->( dbSeek( _cFilSB2 + SC6->C6_PRODUTO + SC6->C6_LOCAL ) )
		SF4->( dbSeek( _cFilSF4 + SC6->C6_TES	) )
		
		aAdd( _aPvlnfs,	{	SC9->C9_PEDIDO			,;
									SC9->C9_ITEM			,;
									SC9->C9_SEQUEN			,;
									SC9->C9_QTDLIB			,;
									SC9->C9_PRCVEN			,;
									SC9->C9_PRODUTO		,;
									SF4->F4_ISS == "S"	,;
									SC9->( Recno() )		,;
									SC5->( Recno() )		,;
									SC6->( Recno() )		,;
									SE4->( Recno() )		,;
									SB1->( Recno() )		,;
									SB2->( Recno() )		,;
									SF4->( Recno() )		,;
									SC9->C9_LOCAL			} )
		
		SC6->( dbSkip() )
		
	EndDo
	
	SC5->( MsUnLockAll() )
	SC6->( MsUnLockAll() )
	SC9->( MsUnLockAll() )
	
	dbSelectArea( _cAliasTrb )
	
EndDo

Return( _lOk )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fRet       ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna item do objeto XML                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Objeto XML                                        ³±±
±±³          ³ parm02 = Alias XML                                         ³±±
±±³          ³ parm03 = Item XML                                          ³±±
±±³          ³ parm04 = Quantidade Itens XML                              ³±±
±±³          ³ parm05 = Variavel XML                                      ³±±
±±³          ³ parm06 = Funcao                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRet( oXML, _cAliasXML, _cItemXML, _nItemXML, _cVarXML, _cFuncao )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _xRet
Local _lIsArray

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAliasXML	:= Iif( _cAliasXML == Nil, "", Iif( Left( _cAliasXML, 01 ) != "_", "_", "" ) + _cAliasXML )
_cItemXML	:= Iif( _cItemXML == Nil, "", Iif( Left( _cItemXML, 01 ) != "_", "_", "" ) + _cItemXML )
_nItemXML	:= Iif( _nItemXML == Nil, "", AllTrim( Str( _nItemXML ) ) )
_cVarXML		:= Iif( _cVarXML == Nil, "", If( Left( _cVarXML, 01 ) != "_", "_", "" ) + _cVarXML )
_cFuncao		:= Iif( _cFuncao == Nil, "", _cFuncao )

_xRet := "oXML:" + _cAliasXML + Iif( !Empty( _cItemXML ), ":" + _cItemXML, "" )

_lIsArray := ValType( &_xRet ) == "A"

If _lIsArray
	_xRet += Iif( !Empty( _nItemXML ), "[" + _nItemXML + "]", "" )
EndIf

_xRet += Iif( !Empty( _cVarXML ), ":" + _cVarXML, "" ) + Iif( Empty( _cFuncao ), ":TEXT", "" )

If _lIsArray
	_xRet := Iif( !Empty( _cFuncao ), _cFuncao + "(", "" ) + _xRet + Iif( !Empty( _cFuncao ), ")", "" )
Else
	
	If !Empty( _cFuncao )
		_xRet := "1"
	EndIf
	
EndIf

Return( &_xRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fEnviaMail ³ Autor ³ HCConsys - Celso    ³ Data ³11/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia email das ocorrencias de importacao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ parm01 = Remetente                                         ³±±
±±³          ³ parm02 = Destinatario                                      ³±±
±±³          ³ parm03 = Assunto                                           ³±±
±±³          ³ parm04 = Atachado                                          ³±±
±±³          ³ parm05 = Corpo                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FENVIAMAIL( _cFrom, _cTo, _cAssunto, _cAttach, _cBody )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formata eMail                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAttach := Iif( _cAttach == Nil, "", AllTrim( _cAttach ) )

U_ADINF009P('LEXMLSC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao de Notas Fiscais (Entradas/Saidas) Sao Carlos -> Varzea Paulista')

If !Empty( _cAttach ) .And. !File( _cAttach )
	
	If !_lExcJob
		ApMsgInfo( "Arquivo Anexo (" + _cAttach + ") nao encontrado!" )
	Else
		ConOut( "Arquivo Anexo (" + _cAttach + ") nao encontrado!" )
	EndIf
	
	Return ( Nil )
	
EndIf

_cFrom			:= Iif( _cFrom == Nil, GetMV( "MV_RELFROM" ), _cFrom )
_aTo				:= { _cTo }
_aCC				:= {}
_aBcc				:= {}
_cSubject		:= _cAssunto
_aAttach			:= {}
_cMailServer	:= GetMv( "MV_RELSERV" )
_cMailConta		:= GetMv( "MV_RELACNT" )
_cMailSenha		:= GetMv( "MV_RELPSW" )

aAdd( _aAttach, _cAttach )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia eMail                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MailSmtpOn( _cMailServer, _cMailConta, _cMailSenha )
	
	If !MailAuth( _cMailConta, _cMailSenha )
		
		If !_lExcJob
			MsgStop("erro na Autenticacao !!!" )
		Else
			ConOut( "Erro na Autenticacao !!!" )
		EndIf
		
		Return ( Nil )
		
	EndIf
	
	If !MailSend( _cFrom, _aTo, _aCc, _aBcc, _cSubject, _cBody, _aAttach, .T. )
		
		If !_lExcJob
			Msgstop( "Erro no envio do e-mail!! - " + MailGetErr() )
		Else
			ConOut( "Erro no envio do e-mail!! - " + MailGetErr() )
		EndIf
		
	EndIf
	
	lDiscSmtp := MailSmtpOff()
	
Else
	cErrorMsg := "Erro na Conexao!!!"  + MailGetErr()
EndIf

FErase( _cAttach )

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GetSX5NFE  ³ Autor ³ HCConsys - Celso    ³ Data ³12/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Proximo Documento de Entrada Valido                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GetSX5NFE( _cNFiscal, _cSerNF )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea			:= GetArea()
Local _nAscan			:= 00
Local _nVezes			:= 00
Local _cNewNFiscal	:= ""
Local _lContinua		:= .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida Serie da Nota Fiscal de Entrada                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SX5" )
dbSetOrder( 01 )

If SX5->( dbSeek( xFilial( "SX5" ) + "01" + _cSerNF ) )
	
	&&_cNewNFiscal := RetAsc( ( Val( SX5->X5_DESCRI ) + 01 ), 06, .T. )
	  _cNewNFiscal := RetAsc( ( Val( SX5->X5_DESCRI )), 09, .T. )   &&Alterado para 09 Mauricio.Testes protheus 10
	
	While ( !SX5->( MsRLock() ) )
		
		_nVezes++
		
		If ( _nVezes > 10 )
			Help( " ", 01, "A460FLOCK" )
			_lContinua := .F.
			Exit
		EndIf
		
		Sleep( 100 )
		
	EndDo
	
	If _lContinua
		SX5->X5_DESCRI  := Soma1(_cNewNFiscal)
		SX5->X5_DESCSPA := Soma1(_cNewNFiscal)
		SX5->X5_DESCENG := Soma1(_cNewNFiscal)
	EndIf
	
	SX5->( MsRUnLock() )
	
EndIf

RestArea( _aArea )

Return ( _cNewNFiscal )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RetSX5NFE  ³ Autor ³ HCConsys - Celso    ³ Data ³12/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica integridade do numero do ultimo documento gerado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetSX5NFE( _cFormul, _cNFiscal, _cSerNF )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea			:= GetArea()
Local _cQuery			:= ""
Local _cTabNFiscal	:= RetAsc( ( Val( _cNFiscal ) - 01 ), 06, .T. )
Local _lRetSF1			:= .F.
Local _lRetSF2			:= .F.
Local _lRet				:= .T.


If _cFormul == "S" .And. !Empty( _cTabNFiscal )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona ultima Nota Fiscal de Entrada                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := "SELECT F1_DOC AS DOCUMENTO "
	_cQuery += "FROM " + RetSqlName( "SF1" ) + " "
	_cQuery += "WHERE F1_FILIAL = '" + xFilial( "SF1" ) + "' "
	_cQuery += "AND F1_DOC = '" + _cTabNFiscal + "' "
	_cQuery += "AND F1_FORMUL = 'S' "
	_cQuery += "AND F1_SERIE = '" + _cSerNF + "' "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "QRYTAB", .T., .T. )

	_lRetSF1 := !Empty( QRYTAB->DOCUMENTO )

	QRYTAB->( dbCloseArea() )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona ultima Nota Fiscal de Saida                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cQuery := "SELECT F2_DOC AS DOCUMENTO "
	_cQuery += "FROM " + RetSqlName( "SF2" ) + " "
	_cQuery += "WHERE F2_FILIAL = '" + xFilial( "SF2" ) + "' "
	_cQuery += "AND F2_DOC = '" + _cTabNFiscal + "' "
	_cQuery += "AND F2_SERIE = '" + _cSerNF + "' "

	_cQuery := ChangeQuery( _cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, _cQuery ), "QRYTAB", .T., .T. )

	_lRetSF2 := !Empty( QRYTAB->DOCUMENTO )

	QRYTAB->( dbCloseArea() )
	
EndIf

_lRet := Iif( _lRetSF1, .T., Iif( _lRetSF2, .T., .F. ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura area                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( _aArea )

Return ( _lRet )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ XMLVldSX5  ³ Autor ³ HCConsys - Celso    ³ Data ³12/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida Execucao da rotina ref. sequencia de numeracao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Adoro                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄ|ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLVLDSX5( _cSerNF, _cMensExec )
            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Locais                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local _aArea		:= GetArea()
Local _aSX5Num		:= {}
Local _cAliasSF1	:= ""
Local _cAliasSF2	:= ""
Local _lRet			:= .T.
Local _lDif			:= .F.

U_ADINF009P('LEXMLSC' + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'Integracao de Notas Fiscais (Entradas/Saidas) Sao Carlos -> Varzea Paulista')

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sequencia de Notas de Entrada - Formulario proprio = "S"     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAliasSF1 := GetNextAlias()

BeginSql Alias _cAliasSF1
	SELECT TOP 01 SF1.F1_DOC
	FROM %Table:SF1% SF1
	WHERE SF1.F1_FILIAL = %xFilial:SF1%
	AND SF1.F1_FORMUL = %Exp:'S'%
	AND SF1.F1_SERIE = %Exp:_cSerNF%
	AND SF1.F1_ESPECIE = %Exp:'SPED'%
	AND LEN(SF1.F1_DOC) > 6
	ORDER BY SF1.F1_DOC DESC
EndSql					

While ( _cAliasSF1 )->( !Eof() )

    //if len(ALLTRIM(( _cAliasSF1 )->F1_DOC )) <= 6  && adicionado em 21/10/10 Mauricio, teste virada protheus 10.
    //   ( _cAliasSF1 )->( dbSkip() )
    //   loop
    //endif
    
	aAdd( _aSX5Num, ( _cAliasSF1 )->F1_DOC )
	
	( _cAliasSF1 )->( dbSkip() )
	
EndDo

( _cAliasSF1 )->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sequencia de Notas de Saida                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cAliasSF2 := GetNextAlias()

BeginSql Alias _cAliasSF2
	SELECT TOP 01 SF2.F2_DOC
	FROM %Table:SF2% SF2
	WHERE SF2.F2_FILIAL = %xFilial:SF2%
	AND SF2.F2_SERIE = %Exp:_cSerNF%
	AND SF2.F2_ESPECIE = %Exp:'SPED'%
	AND SF2.F2_EMISSAO > %Exp:'20100201'% // ALTERADO POR HCCONSYS EM 23/10/09 PARA desprezar notas emitidas com data anterior, pois existem
	// notas com 6 digitos 
	AND LEN(SF2.F2_DOC) > 6
	ORDER BY SF2.F2_DOC DESC
EndSql					

While ( _cAliasSF2 )->( !Eof() )
        
    //if len(ALLTRIM(( _cAliasSF2 )->F2_DOC )) <= 6  && adicionado em 21/10/10 Mauricio, teste virada protheus 10.
    //   ( _cAliasSF2 )->( dbSkip() )
    //   loop
    //endif

	aAdd( _aSX5Num, ( _cAliasSF2 )->F2_DOC )
	
	( _cAliasSF2 )->( dbSkip() )
	
EndDo

( _cAliasSF2 )->( dbCloseArea() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indexa Array de sequencia de numeracao                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort( _aSX5Num )
           
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida sequencial de numeracao                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( _aSX5Num ) > 00

	dbSelectArea( "SX5" )
	SX5->( dbSetOrder( 01 ) )

	If SX5->( dbSeek( xFilial( "SX5" ) + "01" + _cSerNF ) ) .And. AllTrim( SX5->X5_DESCRI ) > (AllTrim( Soma1(_aSX5Num[ Len( _aSX5Num ) ])))
		_lDif	:= .T.
		MsgStop( "Existem divergencias no sequencial de numeracao de Notas Fiscais, ultima NF gerada " + AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ) + " e sequencial " + AllTrim( SX5->X5_DESCRI ), "Atencao" )
		_lRet := .F.
	EndIf

EndIf

If _lDif

	If _lRet
		_cMensExec := "PROCESSAMENTO CONFIRMADO PELO USUARIO <br>" + CRLF
	Else
		_cMensExec := "PROCESSAMENTO CANCELADO PELO USUARIO <br>" + CRLF
	EndIf

	_cMensExec += "Existem divergencias no sequencial de numeracao de Notas Fiscais, ultima NF gerada " + AllTrim( _aSX5Num[ Len( _aSX5Num ) ] ) + " e sequencial " + AllTrim( SX5->X5_DESCRI )

EndIf

Return ( _lRet )
