#Include "RwMake.ch"
#Include "Protheus.ch"
#Include "Topconn.ch"
#Include "TbiConn.ch"
#Include "TbiCode.ch"

//Largura das colunas FWLayer
#DEFINE LRG_COL01		20
#DEFINE LRG_COL02		70
#DEFINE LRG_COL03		10

//Posicoes do pergunte do SX1
#DEFINE POS_X1DES		1
#DEFINE POS_X1TIP		2
#DEFINE POS_X1TAM		3
#DEFINE POS_X1OBJ		6
#DEFINE POS_X1VLD		7
#DEFINE POS_X1VAL		8
#DEFINE POS_X1CB1		9
#DEFINE POS_X1CB2		10
#DEFINE POS_X1CB3		11
#DEFINE POS_X1CB4		12
#DEFINE POS_X1CB5		13
#DEFINE POS_X1VAR		14

Static nDistPad	:= 002
Static nAltBot	:= 013
Static cHK		:= "&"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTFIN   บAutor  ณMicrosiga           บ Data ณ  04/16/16    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function INTFIN(dDatde,dDatate,lBackg)

LOCAL oSay,oSay2,oSay3
LOCAL oBtn1,oBtn2,oBtn3
LOCAL oDlg

Default lBackg := .F.

Private cPerg		:="INTFIN"
Private CCADASTRO 	:="Interface de PA SAG"
Private cUserLibe	:=SuperGetMV("MV_XFINLIB", .F., "")
Private cUserAprv	:=SuperGetMV("MV_XFINAPR", .F., "")
Private cCodUser 	:= RetCodUsr()

U_ADINF009P(SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))) + '.PRW',SUBSTRING(ALLTRIM(PROCNAME()),3,LEN(ALLTRIM(PROCNAME()))),'')

	If !(( cCodUser $ cUserLibe ) .OR. ( cCodUser $ cUserAprv ))
		MsgAlert("Este usuแrio nใo possui permissใo para acessar a funcionalidade para processar alguma PA!" + CHR(13) + CHR(10) + "Para acessar a funcionalidade o usuแrio precisar estar nos parโmetros MV_XFINLIB ou MV_XFINAPR", "Error Access")
		Return
	EndIf

	ProcLogIni( {},"INTFIN")
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcerta dicionแrio de perguntas       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If !lBackg
		AjustaSX1(cPerg)
		Pergunte(cPerg,.T.)
	Else
		Pergunte(cPerg,.F.)
		MV_PAR01:=dDatde
		MV_PAR02:=dDatate
	EndIF

//	If !lBackg
		DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Interface de PA SAG") PIXEL
		@ 11,6 TO 90,287 LABEL "" OF oDlg  PIXEL
		@ 16, 15 SAY OemToAnsi("Este programa efetua a integra็ใo dos Pagmentos Antecipados oriundos do SAG.") SIZE 268, 8 OF oDlg PIXEL
	
		DEFINE SBUTTON FROM 93, 163 TYPE 15 ACTION ProcLogView() ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 193 TYPE 5  ACTION Pergunte(cPerg,.T.) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION If(.T.,(Processa({|lEnd| INTFINC()},OemToAnsi("Interface de PA SAG"),OemToAnsi("Efetuando integra็ใo..."),.F.),oDlg:End()),) ENABLE OF oDlg
		DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION oDlg:End() ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
//	Else
//		E001Proces(lBackg)
//	EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณE001ProcesบAutor  ณMicrosiga           บ Data ณ  02/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function E001Proces(lBackg)

Local   aTables		:={"SE2","SA2"}

Private _nTcConn1	:= advConnection()
Private _cNomBco1  	:= ""
Private _cSrvBco1   := ""
Private _cPortBco1  := ""
Private _cNomBco2   := ""
Private _cSrvBco2   := ""
Private _cPortBco2  := ""
Private cPara       := ""
Private cCopia      := ""
Private cCpOcul     := ""
Private cAssunto    := ""
Private cDe         := ""
Private cMensagem	:= ""

	cEmp := cEmpAnt
	cFil := cFilAnt

// define link com a base da Interface
	_cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
	_cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
	_cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))

	cPara      := SuperGetMV("MV_XMPARA" ,,"")
	cCopia     := SuperGetMV("MV_XMCOPIA",,"")
	cCpOcul    := SuperGetMV("MV_XMCPOCU",,"")
	cAssunto   := SuperGetMV("MV_XMASSUN",,"Integracao Protheus X SAG")
	cDe        := SuperGetMV("MV_XMAILDE",,"")
	cEmail		:= GetMV("MV_XEMAIL",.F.,"")
	cExt		:= GetMv("MV_XEXT",.F.,"*.CSV")

	If Empty (MV_PAR01) .OR. Empty(MV_PAR02) .OR. MV_PAR02 > MV_PAR01

		Aviso(	"INTFINB",;
			"Parametros nใo informados ou invแlidos!" + CHR(13)+CHR(10) + ;
			"Nใo ้ permitido as datas estarem vazio ou serem diferente. ",;
			{"Ok"} )
		Return

	EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPROCESSAMENTO DA INTERFACEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//BeginTran()
//
//	ProcLogAtu("INICIO")
//	
//	INTFINA() //INCLUSรO
//	
//	Pergunte(cPerg,.F.) // seta a pergunta da rotina de importa็ใo
//		
//	INTFINB() //EXCLUSรO / ALTERวรO
//
//	ProcLogAtu("FIM")  
//	
//	If !lBackg
//		U_ExTelaMen("INTFIN - Processo de Importa็ใo concluido!!!", cMensagem, "Arial", 10, , .F., .T.) 
//	EndIf  
//	
//EndTran()

Return()








/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณINTFINC   บAutor ณLeonardo Rios     บ Data ณ25/09/2014     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณTela para mostrar o itens retornados conforme a query a ser  บฑฑ
ฑฑบ         ณ contruida com base na regra o nos parametros de filtro      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINC

Local oArea		:= FWLayer():New()
Local aCoord	:= FWGetDialogSize(oMainWnd)
Local lMDI		:= oAPP:lMDI
Local aTamObj	:= Array(4)
Local oDlg
Local oTPanel
Local oGetDados
Local aHeader   := {}
Local aButtons  := {}
Local aCampos   := {}  //Array aCampos utilizado para colocar quais campos deverแ fazer uma busca para o array aHeader
Local aPergunte	:= {}
Local cMens		:= ""

Local cAliasT
Local nCoefDif	:= 1
Local oOk 		:= LoadBitmap(GetResources(),"LBOK")
Local oNo 		:= LoadBitmap(GetResources(),"LBNO")
Local bAtGD		:= {|lAtGD,lFoco| IIf(lAtGD,(oGD01:SetArray(aCols),oGD01:bLine := &(cLine01),oGD01:GoTop()),.T.),;
	IIf(ValType(lFoco) == "L" .AND. lFoco,(oGD01:SetFocus(), oGD01:Refresh()),.T.)}
//Local bAtFim	:= {|| ( TcUnLink(_nTcConn1), TcUnLink(_nTcConn2), oTela:End() ) }
Local bAtFim	:= {|| oTela:End() }

//Objetos graficos
Local oTela
Local oPainel01
Local oPainel02
Local oPainel03
Local oPainelS01
Local oBot01
Local oBot02
Local oBot03
Local oBot04
Local oBot05
Local oBot06


//Cores
Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Local oWhite	:= LoadBitmap( GetResources(), "BR_BRANCO")
Local oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
Local oGray		:= LoadBitmap( GetResources(), "BR_CINZA")

Private oGD01

Private cLine01	:= ""
Private aAux	  := {} //Array auxiliar utilizado para guardar informa็๕es que serใo necessarias
Private aCols     := {}
Private dPerg01Dta := mv_par01 // Perํodo De
Private dPerg02Dta := mv_par02 // Perํodo Ate
Private nPerg03Sta := mv_par03 // Status

Private lCheck	   := .F.
Private cBanco	:= SPACE(TamSx3("A6_COD")[1])
Private cAgencia:= SPACE(TamSx3("A6_AGENCIA")[1])
Private cContaC := SPACE(TamSx3("A6_NUMCON")[1])
Private nTaxa	:= 0 //TRANSFORM(0, PesqPict("SA6","A6_SALATU")) //SPACE(20)
Private dDataVenc := ddatabase
Private aBancos	:= {{"", "", "", 0, ddatabase, 0}}
Private oCheck1

Private _cNomBco1  := GetPvProfString("INTSAGBD","BCO1","ERROR",GetADV97())
Private _cSrvBco1  := GetPvProfString("INTSAGBD","SRV1","ERROR",GetADV97())
Private _cPortBco1 := Val(GetPvProfString("INTSAGBD","PRT1","ERROR",GetADV97()) )
Private _cNomBco2  := GetPvProfString("INTSAGBD","BCO2","ERROR",GetADV97())
Private _cSrvBco2  := GetPvProfString("INTSAGBD","SRV2","ERROR",GetADV97())
Private _cPortBco2 := Val(GetPvProfString("INTSAGBD","PRT2","ERROR",GetADV97()))
Private _nTcConn1
Private _nTcConn2

Private cMensagem	:= ""

	// TcConType("TCPIP")
	// If (_nTcConn1 := TcLink(_cNomBco1,_cSrvBco1,_cPortBco1))<0
	// 	_lRet     := .F.
	// 	cMsgError := "Nใo foi possํvel  conectar ao banco Protheus"
	// 	MsgInfo("Nใo foi possํvel  conectar ao banco produ็ใo, verifique com administrador","ERROR")	
	// EndIf
	
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	_lRet     := .F.
	// 	cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
	// 	MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")	
	// EndIf

	aFill(aTamObj,0)

	AADD( aCampos, {"E2_FILIAL", "E2_PREFIXO", "E2_NUM", "E2_TIPO", "E2_PARCELA", "E2_NATUREZ", "E2_FORNECE", "B1_COD", "E2_EMISSAO", "E2_VENCTO", "E2_VALOR", "E2_HIST", "R_E_C_N_O_", "E2_MOEDA"} )

	aAdd( aHeader, { '', 'CLEGEND' , '@BMP', 10 , 0, , , 'C', , 'V' ,  ,  , 		, 'V', 'S' } )
	aAdd( aHeader, { '', 'CHECKBOL', '@BMP', 20 , 0, , , 'L', , 'V' ,  ,  , 'mark'  , 'V', 'S' } )

	// Carrega aHeader
	dbSelectArea( "SX3" )
	SX3->( dbSetOrder( 2 ) ) // Campo
	For x:=1 To Len(aCampos)
		For y:= 1 To Len(aCampos[x]) //s๓ estou usando a variavel x porque tamb้m possui o valor 3
		
			If SX3->( dbSeek( aCampos[x, y] ) )
				AADD( aHeader, { 	AllTrim( X3Titulo() ),; // 01 - Titulo
									SX3->X3_CAMPO		 ,;			// 02 - Campo
									SX3->X3_Picture		 ,;			// 03 - Picture
									IIF(ALLTRIM(aCampos[x, y]) == "B1_COD", 50, SX3->X3_TAMANHO) ,;			// 04 - Tamanho
									SX3->X3_DECIMAL		 ,;			// 05 - Decimal
									SX3->X3_Valid  		 ,;			// 06 - Valid
									SX3->X3_USADO  		 ,;			// 07 - Usado
									SX3->X3_TIPO   		 ,;			// 08 - Tipo
									SX3->X3_F3			 ,;			// 09 - F3
									SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
									SX3->X3_CBOX		 ,; 		// 11 - ComboBox
									SX3->X3_RELACAO 	 ,;         // 12 - Relacao
									SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
									SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
									SX3->X3_VISUAL  } )
			EndIf
			
		Next y
	Next x

	aOutros := {'OPERACAO_INT', 'MENSAGEM_INT'} //, 'STATUS_INT', 'STATUS_PRC'}
	SX3->( dbSeek( "E2_PREFIXO" ) )
//	For x:=1 To Len(aOutros)
		AADD( aHeader, { 	AllTrim( aOutros[1] ),; // 01 - Titulo
							SX3->X3_CAMPO		 ,;			// 02 - Campo
							SX3->X3_Picture		 ,;			// 03 - Picture
							10					 ,;			// 04 - Tamanho
							SX3->X3_DECIMAL		 ,;			// 05 - Decimal
							SX3->X3_Valid  		 ,;			// 06 - Valid
							SX3->X3_USADO  		 ,;			// 07 - Usado
							SX3->X3_TIPO   		 ,;			// 08 - Tipo
							SX3->X3_F3			 ,;			// 09 - F3
							SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
							SX3->X3_CBOX		 ,; 		// 11 - ComboBox
							SX3->X3_RELACAO 	 ,;         // 12 - Relacao
							SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
							SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
							SX3->X3_VISUAL  } )
		
		AADD( aHeader, { 	AllTrim( aOutros[2] ),; // 01 - Titulo
							SX3->X3_CAMPO		 ,;			// 02 - Campo
							SX3->X3_Picture		 ,;			// 03 - Picture
							100					 ,;			// 04 - Tamanho
							SX3->X3_DECIMAL		 ,;			// 05 - Decimal
							SX3->X3_Valid  		 ,;			// 06 - Valid
							SX3->X3_USADO  		 ,;			// 07 - Usado
							SX3->X3_TIPO   		 ,;			// 08 - Tipo
							SX3->X3_F3			 ,;			// 09 - F3
							SX3->X3_CONTEXT 	 ,;         // 10 - Contexto
							SX3->X3_CBOX		 ,; 		// 11 - ComboBox
							SX3->X3_RELACAO 	 ,;         // 12 - Relacao
							SX3->X3_INIBRW  	 ,;			// 13 - Inicializador Browse
							SX3->X3_Browse  	 ,;			// 14 - Mostra no Browse
							SX3->X3_VISUAL  } )
//	Next x
	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca tํtulos para inclusใo no Protheus ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAliasT	:= GetNextAlias()
	
	INTFING(@cAliasT, 1)
	
	(cAliasT)->(dbGoTop())
	
	Do While !(cAliasT)->(Eof())
		
		DO CASE
			CASE (cAliasT)->STATUS_LIB == "0"
				xCor := oWhite
			CASE (cAliasT)->STATUS_LIB == "1"
				xCor := oGreen
			CASE (cAliasT)->STATUS_LIB == "2"
				xCor := oBlue
			CASE (cAliasT)->STATUS_LIB == "3"
				xCor := oGray
			OTHERWISE
				xCor := oRed
		ENDCASE
		
		AADD(aCols,	{	xCor					,;
						.F.                 	,;
						(cAliasT)->E2_FILIAL	,;
						(cAliasT)->E2_PREFIXO	,;
						(cAliasT)->E2_NUM		,;
						(cAliasT)->E2_TIPO		,;
						(cAliasT)->E2_PARCELA	,;						
						(cAliasT)->E2_NATUREZ	,;
						(cAliasT)->E2_FORNECE	,;
						(cAliasT)->E2_PRODUTO	,;
						DTOC(STOD((cAliasT)->E2_EMISSAO))	,;
						DTOC(STOD((cAliasT)->E2_VENCTO))	,;
						(cAliasT)->E2_VALOR		,;
						(cAliasT)->E2_HIST		,;
						(cAliasT)->R_E_C_N_O_	,;
						(cAliasT)->E2_MOEDA		,;
						IIF( (cAliasT)->OPERACAO_INT == "I", "Inclusใo", Iif( (cAliasT)->OPERACAO_INT == "A", "Altera็ใo", Iif( (cAliasT)->OPERACAO_INT == "E", "Exclusใo", "" ) ) ) ,;	
						(cAliasT)->MENSAGEM_INT		})
						

		AADD(aAux, {	(cAliasT)->STATUS_INT	,;
						(cAliasT)->OPERACAO_INT ,;
						(cAliasT)->STATUS_PRC   ,;
						(cAliasT)->STATUS_LIB     })

	 	
		AADD( aCols[Len(aCols)], .F. )
		
		(cAliasT)->(dbSkip())

	EndDo
	
	U_FecArTMP(cAliasT)
	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca tํtulos para altera็ใo/exclusใo no Protheus ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cAliasT	:= GetNextAlias()
	
	INTFING(@cAliasT, 2)
	
	(cAliasT)->(dbGoTop())
	
	Do While !(cAliasT)->(Eof())

		DO CASE
			CASE (cAliasT)->STATUS_LIB == "0"
				xCor := oWhite
			CASE (cAliasT)->STATUS_LIB == "1"
				xCor := oGreen
			CASE (cAliasT)->STATUS_LIB == "2"
				xCor := oBlue
			CASE (cAliasT)->STATUS_LIB == "3"
				xCor := oGray
			OTHERWISE
				xCor := oRed
		ENDCASE
		
		AADD(aCols,	{	xCor					,;
						.F.                 	,;
						(cAliasT)->E2_FILIAL	,;
						(cAliasT)->E2_PREFIXO	,;
						(cAliasT)->E2_NUM		,;
						(cAliasT)->E2_TIPO		,;
						(cAliasT)->E2_PARCELA	,;
						(cAliasT)->E2_NATUREZ	,;
						(cAliasT)->E2_FORNECE	,;
						(cAliasT)->E2_PRODUTO	,;
						DTOC(STOD((cAliasT)->E2_EMISSAO))	,;
						DTOC(STOD((cAliasT)->E2_VENCTO))	,;
						(cAliasT)->E2_VALOR		,;
						(cAliasT)->E2_HIST		,;
						(cAliasT)->R_E_C_N_O_	,;
						(cAliasT)->E2_MOEDA		,;
						IIF( (cAliasT)->OPERACAO_INT == "I", "Inclusใo", Iif( (cAliasT)->OPERACAO_INT == "A", "Altera็ใo", Iif( (cAliasT)->OPERACAO_INT == "E", "Exclusใo", "" ) ) )	,;	
						(cAliasT)->MENSAGEM_INT		})
						

		AADD(aAux, {	(cAliasT)->STATUS_INT	,;
						(cAliasT)->OPERACAO_INT ,;
						(cAliasT)->STATUS_PRC   ,;
						(cAliasT)->STATUS_LIB     })
	 	
		AADD( aCols[Len(aCols)], .F. )
		
		(cAliasT)->(dbSkip())

	EndDo
	
	U_FecArTMP(cAliasT)
	

	If Len(aCols) < 1
		xCor := oGray
		AADD(aCols,	{	xCor,;
						.F. ,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""  ,;
						""	,;
						""	,;
						""	,;
						""  })
	 	
		AADD( aCols[Len(aCols)], .T. )
	EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontar o codeblock para montar as listas de dados da GD  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cLine01 := "{|| Iif( Len(aCols) < 1, {}, "
	cLine01 += " { aCols[oGD01:nAt,1], "
	cLine01 += "IIf(aCols[oGD01:nAt,2],oOk,oNo),"
	For ni := 3 to 19
		cLine01 += "aCols[oGD01:nAt," + cValToChar(ni) + "]" + IIf(ni < 19,",","")
	Next ni
	cLine01 += "} ) }"
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInterface  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
	aCoord[3] := aCoord[3] * 0.95
	aCoord[4] := aCoord[4] * 0.95
	If U_ApRedFWL(.T.)
		nCoefDif := 0.95
	Endif
	
	DEFINE MSDIALOG oTela TITLE "Tela de Pr้-Processamento" FROM aCoord[1],aCoord[2] TO aCoord[3],aCoord[4] OF oMainWnd COLOR "W+/W" PIXEL

	oArea:Init(oTela,.F.)
	
//Mapeamento da area
	oArea:AddLine("L01",100 * nCoefDif,.T.)
	
//ฺฤฤฤฤฤฤฤฤฤฟ
//ณColunas  ณ
//ภฤฤฤฤฤฤฤฤฤู
	oArea:AddCollumn("L01C01",LRG_COL01,.F.,"L01")
	oArea:AddCollumn("L01C02",LRG_COL02,.F.,"L01")
	oArea:AddCollumn("L01C03",LRG_COL03,.F.,"L01")
	
//ฺฤฤฤฤฤฤฤฤฤฟ
//ณPaineis  ณ
//ภฤฤฤฤฤฤฤฤฤู
	oArea:AddWindow("L01C01","L01C01P01","Parโmetros",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel01 := oArea:GetWinPanel("L01C01","L01C01P01","L01")
		
	oArea:AddWindow("L01C02","L01C02P01","Dados adicionais",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel02 := oArea:GetWinPanel("L01C02","L01C02P01","L01")
		
	oArea:AddWindow("L01C03","L01C03P01","Fun็๕es",100,.F.,.F.,/*bAction*/,"L01",/*bGotFocus*/)
	oPainel03 := oArea:GetWinPanel("L01C03","L01C03P01","L01")
	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPainel 01 - Filtros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//PERGUNTAS
	U_DefTamObj(@aTamObj,000,000,(oPainel01:nClientHeight / 2) * 0.9, oPainel01:nClientWidth / 2)
	oPainelS01 := tPanel():New(aTamObj[1],aTamObj[2],"",oPainel01,,.F.,.F.,,CLR_WHITE,aTamObj[4],aTamObj[3],.T.,.F.)
	
	Pergunte(cPerg,.T.,,.F.,oPainelS01,,@aPergunte,.T.,.F.)
	
	INTFINE(aClone(aHeader),@aCols, @aAux)
	
//BOTAO PESQUISA
	U_DefTamObj(@aTamObj,(oPainel01:nClientHeight / 2) - nAltBot,000,(oPainel01:nClientWidth / 2),nAltBot,.T.)
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Pesquisar",oPainel01,;
		{|| IIf(INTFINF(cPerg,@aPergunte),;
		MsAguarde({|| CursorWait(),INTFINE(aClone(aHeader),@aCols, @aAux),Eval(bAtGD,.T.,.T.),CursorArrow()},"Pre-Processamento","Pesquisando",.F.),.F.)},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPainel 02 - Lista de dados  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGD01 := TCBrowse():New(000,000,000,000,/*bLine*/,{' ', ' ', 'FILIAL', 'PREFIXO', 'NUM NOTA', 'TIPO', 'PARCELA', 'NATUREZA', 'FORNECEDOR', 'PRODUTO', 'DT EMISSAO', 'DT VENCTO', 'VALOR', 'HIST', 'RECNO', 'MOEDA', 'OPERACAO', 'MENSAGEM'},,oPainel02,,,,/*bChange*/,/*bLDblClick*/,/*bRClick*/,/*oFont*/,,,,,,,.T.,/*bWhen*/,,/*bValid*/,.T.,.T.)
	oGD01:bHeaderClick	:= {|oObj,nCol| INTFINH(2,@aCols,@oGD01,nCol,aClone(aHeader)),oGD01:Refresh()}
	oGD01:blDblClick	:= {|| INTFIND(1,@aCols,@oGD01,,aClone(aHeader)),oGD01:Refresh()}
	oGD01:Align 		:= CONTROL_ALIGN_ALLCLIENT
	Eval(bAtGD,.T.,.F.)
	
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPainel 03 - Funcoes  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
//Processamento
	U_DefTamObj(@aTamObj,000,000,(oPainel03:nClientWidth / 2),nAltBot,.T.)
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + Iif(cCodUser $ cUserAprv, "Processamento", "Libera็ใo"),oPainel03,;
		{|| IIf(.T.,;
		MsAguarde({|| CursorWait(),lOk := INTFINI(aClone(aCols)),CursorArrow(),IIf(lOk,(INTFINE(aClone(aHeader),@aCols, @aAux),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
		"INTFIN",Iif(cCodUser $ cUserAprv, "Processando", "Liberando"),.F.),MsgAlert("Para " + Iif(cCodUser $ cUserAprv, "processar", "liberar")+ " ้ necessแrio que ao menos um registro seja selecionado!",Iif(cCodUser $ cUserAprv, "Processa", "Libera")))},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
		
//Estorno	
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + (nDistPad*2))
	oBot01 := tButton():New(aTamObj[1],aTamObj[2],cHK + Iif(cCodUser $ cUserAprv, "Estorna PA", "Estorna Libera็ใo"),oPainel03,;
		{|| IIf(.T.,;
		MsAguarde({|| CursorWait(),lOk := INTFINL(aClone(aCols)),CursorArrow(),IIf(lOk,(INTFINE(aClone(aHeader),@aCols, @aAux),Eval(bAtGD,.T.,.T.)),AllwaysTrue())},;
		"INTFIN","Estornando",.F.),MsgAlert("Para estornar ้ necessแrio que ao menos um registro seja selecionado!","Estorna"))},;
		aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
//Legenda
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + (nDistPad*2))
	oBot04 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Legenda",oPainel03,{|| Legenda()},aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)
	
//Sair
	U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + (nDistPad*2))
	oBot05 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Sair",oPainel03, bAtFim, aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)


	If cCodUser $ cUserAprv
//Visualizar
		U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + (nDistPad*2))
		oBot06 := tButton():New(aTamObj[1],aTamObj[2],cHK + "Visual. Banco",oPainel03,{|| INTFINK() },aTamObj[3],aTamObj[4],,/*Font*/,,.T.,,,,{|| .T.}/*When*/)

//Mesmo Banco
		U_DefTamObj(@aTamObj,aTamObj[1] + nAltBot + (nDistPad*3))
		oCheck1 := TCheckBox():New(aTamObj[1],aTamObj[2],'Mesmo Banco',{|| lCheck },oPainel03,100,8,,{|| INTFINJ(.T.)},,,,,,.T.,,,)
	EndIf


	oTela:Activate(,,,.T.,/*valid*/,,{|| .T.})

Return






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFIND บAutor  ณKF SYSTEM				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina pra fazer o tratamento de selecao de dados                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                                        	 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFIND(nOpc,aDados,oGDSel,nColSel,aHead)

Local ni		:= 0
Local nVal		:= 0

Default nOpc	:= 0
Default aDados	:= Array(0)
Default oGDSel  := Nil
Default nColSel	:= 1
Default aHead	:= Array(0)

//	If (cCodUser $ cUserAprv .AND. aAux[oGDSel:nAt][4] == '2') .OR. (cCodUser $ cUserLibe .AND. aAux[oGDSel:nAt][4] == '1') //TODO: ALTERAR para posi็ใo do STATUS_LIB
		If nOpc == 1
			If !aDados[oGDSel:nAt][19]
				aDados[oGDSel:nAt][2] := !aDados[oGDSel:nAt][2]
			EndIf
		Endif
	
		If cCodUser $ cUserAprv
			If aAux[oGDSel:nAt][4] == "2"
				If aDados[oGDSel:nAt][2] .AND. !aDados[oGDSel:nAt][19] 
					INTFINJ(Nil, .T.)			
				ElseIf !aDados[oGDSel:nAt][2] .AND. !aDados[oGDSel:nAt][19]	
					If !lCheck .AND. Len(aBancos) > 1
						For xPosi:=2 To Len(aBancos)
							If aBancos[xPosi,6] == oGDSel:nAt
								nVal := xPosi
								Exit
							EndIf
						Next xPosi
						
						If nVal > 0
							ADEL(aBancos, nVal)
							ASIZE(aBancos, Len(aBancos)-1)
						EndIf				
					EndIf	
				EndIf
			EndIf
		EndIf
//    Else
//    	MsgAlert("Seu usuแrio nใo tem permissใo para selecionar o item", "Aviso!")
//	EndIf

	//Forcar a atualizacao do browse
	oGDSel:DrawSelect()
	
Return Nil






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINE   บAutor  ณKF SYSTEM			    บ Data ณ04/06/12      	    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de atualizacao da lista de dados                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑบ          ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINE(aHeader,aCols, aAux)

Local cAliasT
Local oGreen   	:= LoadBitmap( GetResources(), "BR_VERDE")
Local oRed    	:= LoadBitmap( GetResources(), "BR_VERMELHO")
Local oWhite	:= LoadBitmap( GetResources(), "BR_WHITE")
Local oBlue		:= LoadBitmap( GetResources(), "BR_AZUL")
Local oGray		:= LoadBitmap( GetResources(), "BR_CINZA")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤgฟ
//ณDefinicoes de filtros  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aCols := {}
	aAux  := {}
	
	If mv_par03 == 4
		
		cAliasT	:= GetNextAlias()
		
		INTFING(@cAliasT, 3)
		
		(cAliasT)->(dbGoTop())
		
		Do While !(cAliasT)->(Eof())
	
			DO CASE
				CASE (cAliasT)->STATUS_LIB == "0"
					xCor := oWhite
				CASE (cAliasT)->STATUS_LIB == "1"
					xCor := oGreen
				CASE (cAliasT)->STATUS_LIB == "2"
					xCor := oBlue
				CASE (cAliasT)->STATUS_LIB == "3"
					xCor := oGray			
				OTHERWISE
					xCor := oRed
			ENDCASE
	
			AADD(aCols,	{	xCor					,;
							.F.                 	,;
							(cAliasT)->E2_FILIAL	,;
							(cAliasT)->E2_PREFIXO	,;
							(cAliasT)->E2_NUM		,;
							(cAliasT)->E2_TIPO		,;
							(cAliasT)->E2_PARCELA	,;
							(cAliasT)->E2_NATUREZ	,;
							(cAliasT)->E2_FORNECE	,;
							(cAliasT)->E2_PRODUTO	,;
							DTOC(STOD((cAliasT)->E2_EMISSAO))	,;
							DTOC(STOD((cAliasT)->E2_VENCTO))	,;
							(cAliasT)->E2_VALOR		,;
							(cAliasT)->E2_HIST		,;
							(cAliasT)->R_E_C_N_O_	,;
							(cAliasT)->E2_MOEDA		,;
							IIF( (cAliasT)->OPERACAO_INT == "I", "Inclusใo", Iif( (cAliasT)->OPERACAO_INT == "A", "Altera็ใo", Iif( (cAliasT)->OPERACAO_INT == "E", "Exclusใo", "" ) ) )	,;
							(cAliasT)->MENSAGEM_INT		})
							
	
			AADD(aAux, {	(cAliasT)->STATUS_INT	,;
							(cAliasT)->OPERACAO_INT ,;
							(cAliasT)->STATUS_PRC   ,;
							(cAliasT)->STATUS_LIB     })
		 	
			AADD( aCols[Len(aCols)], .F. )
			
			(cAliasT)->(dbSkip())
	
		EndDo
		
		U_FecArTMP(cAliasT)
	
    Else

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca tํtulos para inclusใo no Protheus ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cAliasT	:= GetNextAlias()
		
		INTFING(@cAliasT, 1)
		
		(cAliasT)->(dbGoTop())
		
		Do While !(cAliasT)->(Eof())
	
			DO CASE
				CASE (cAliasT)->STATUS_LIB == "0"
					xCor := oWhite
				CASE (cAliasT)->STATUS_LIB == "1"
					xCor := oGreen
				CASE (cAliasT)->STATUS_LIB == "2"
					xCor := oBlue
				CASE (cAliasT)->STATUS_LIB == "3"
					xCor := oGray			
				OTHERWISE
					xCor := oRed
			ENDCASE
	
			AADD(aCols,	{	xCor					,;
							.F.                 	,;
							(cAliasT)->E2_FILIAL	,;
							(cAliasT)->E2_PREFIXO	,;
							(cAliasT)->E2_NUM		,;
							(cAliasT)->E2_TIPO		,;
							(cAliasT)->E2_PARCELA	,;							
							(cAliasT)->E2_NATUREZ	,;
							(cAliasT)->E2_FORNECE	,;
							(cAliasT)->E2_PRODUTO	,;
							DTOC(STOD((cAliasT)->E2_EMISSAO))	,;
							DTOC(STOD((cAliasT)->E2_VENCTO))	,;
							(cAliasT)->E2_VALOR		,;
							(cAliasT)->E2_HIST		,;
							(cAliasT)->R_E_C_N_O_	,;
							(cAliasT)->E2_MOEDA		,;
							IIF( (cAliasT)->OPERACAO_INT == "I", "Inclusใo", Iif( (cAliasT)->OPERACAO_INT == "A", "Altera็ใo", Iif( (cAliasT)->OPERACAO_INT == "E", "Exclusใo", "" ) ) )	,;
							(cAliasT)->MENSAGEM_INT		})
							
	
			AADD(aAux, {	(cAliasT)->STATUS_INT	,;
							(cAliasT)->OPERACAO_INT ,;
							(cAliasT)->STATUS_PRC   ,;
							(cAliasT)->STATUS_LIB     })
		 	
			AADD( aCols[Len(aCols)], .F. )
			
			(cAliasT)->(dbSkip())
	
		EndDo
		
		U_FecArTMP(cAliasT)
		
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Busca tํtulos para altera็ใo/exclusใo no Protheus ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cAliasT	:= GetNextAlias()
		
		INTFING(@cAliasT, 2)
		
		(cAliasT)->(dbGoTop())
		
		Do While !(cAliasT)->(Eof())
	
			DO CASE
				CASE (cAliasT)->STATUS_LIB == "0"
					xCor := oWhite
				CASE (cAliasT)->STATUS_LIB == "1"
					xCor := oGreen
				CASE (cAliasT)->STATUS_LIB == "2"
					xCor := oBlue
				CASE (cAliasT)->STATUS_LIB == "3"
					xCor := oGray
				OTHERWISE
					xCor := oRed
			ENDCASE
	
			AADD(aCols,	{	xCor					,;
							.F.                 	,;
							(cAliasT)->E2_FILIAL	,;
							(cAliasT)->E2_PREFIXO	,;
							(cAliasT)->E2_NUM		,;
							(cAliasT)->E2_TIPO		,;
							(cAliasT)->E2_PARCELA	,;							
							(cAliasT)->E2_NATUREZ	,;
							(cAliasT)->E2_FORNECE	,;
							(cAliasT)->E2_PRODUTO	,;
							DTOC(STOD((cAliasT)->E2_EMISSAO))	,;
							DTOC(STOD((cAliasT)->E2_VENCTO))	,;
							(cAliasT)->E2_VALOR		,;
							(cAliasT)->E2_HIST		,;
							(cAliasT)->R_E_C_N_O_	,;
							(cAliasT)->E2_MOEDA		,;
							IIF( (cAliasT)->OPERACAO_INT == "I", "Inclusใo", Iif( (cAliasT)->OPERACAO_INT == "A", "Altera็ใo", Iif( (cAliasT)->OPERACAO_INT == "E", "Exclusใo", "" ) ) )	,;
							(cAliasT)->MENSAGEM_INT		})
	
			AADD(aAux, {	(cAliasT)->STATUS_INT	,;
							(cAliasT)->OPERACAO_INT ,;
							(cAliasT)->STATUS_PRC   ,;
							(cAliasT)->STATUS_LIB     })
	
			AADD( aCols[Len(aCols)], .F. )
	
			(cAliasT)->(dbSkip())
		EndDo
	
		U_FecArTMP(cAliasT)
    
	EndIf

	If Len(aCols) < 1
		xCor := oGray
		AADD(aCols,	{	xCor,;
						.F. ,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""	,;
						""  ,;
						""  ,;
						""  ,;
						""  ,;
						""	,;
						""	  })
	 			
		AADD( aCols[Len(aCols)], .T. )
	EndIf
	
	mv_par01 := dPerg01Dta // Perํodo De
	mv_par02 := dPerg02Dta // Perํodo Ate
	mv_par03 := nPerg03Sta // Status


Return Nil







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINF	  บAutor  ณKF SYSTEM				    บ Data ณ04/06/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para validacao do SX1 da rotina                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINF(cPerg,aPergunte)

Local lRet	:= .T.
Local ni	:= 0

//Gravar variaveis no grupo de perguntas do SX1
	__SaveParam(cPerg,@aPergunte)
//Reinicializar as perguntas
	ResetMVRange()
	For ni := 1 to Len(aPergunte)
	//Inicializar as perguntas c/ array caso existam diferencas, para as validacoes
		Do Case
		Case AllTrim(aPergunte[ni][POS_X1OBJ]) == "C"
			aPergunte[ni][POS_X1VAL] := &(aPergunte[ni][POS_X1VAR])
		Otherwise
			&(aPergunte[ni][POS_X1VAR]) := aPergunte[ni][POS_X1VAL]
		EndCase
	//Definir a variavel corrente como sendo o parametro a validar, para aquelas validacoes que utilizar a variavel de campo posicionado
		__ReadVar := aPergunte[ni][POS_X1VAR]
	//Executar validacao
		If !Eval(&("{|| " + aPergunte[ni][POS_X1VLD] + "}"))
			MsgAlert(cNomeUs + ", inconsist๊ncia na pergunta " + StrZero(ni,2) + " (" + StrTran(AllTrim(Capital(aPergunte[ni][POS_X1DES])),"?","") + ")")
			Return !lRet
		Endif
	Next ni


	dPerg01Dta := mv_par01 // Perํodo De
	dPerg02Dta := mv_par02 // Perํodo Ate
	nPerg03Sta := mv_par03 // Status

Return lRet







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTFING	  บAutor  ณMicrosiga         บ Data ณ  12/15/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuery do relat๓rio                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFING(cAliasT, nOpc)

Local cCampos 	:= "*"
Local cSTATUS 	:= ""
Local cOPERACAO	:= ""
Local cOpc		:= ""

	//TcSetConn(_nTcConn2)

	If mv_par03 == 1
		cOpc := "% STATUS_LIB = '0' %"
	ElseIf mv_par03 == 2
		cOpc := "% STATUS_LIB = '1' %"
	ElseIf mv_par03 == 3
		cOpc := "% STATUS_LIB = '2' %"
	ElseIf mv_par03 == 4
		cOpc := "% STATUS_LIB = '3' %"
	ElseIf mv_par03 == 5
		cOpc := "% STATUS_LIB = '4' %"
	EndIf

	If nOpc == 3
		BeginSQL Alias cAliasT
			SELECT *
				
			FROM SGFIN010
		
			WHERE E2_TIPO='PA' AND E2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% AND %Exp:cOpc%
	
			ORDER BY E2_FILIAL,E2_EMISSAO, R_E_C_N_O_
		EndSQL
		
	Else
	
		If nOpc == 1
			BeginSQL Alias cAliasT
				SELECT *
					
				FROM SGFIN010
			
				WHERE 
					( 
						(E2_TIPO='PA' AND E2_MSEXP='' AND OPERACAO_INT = 'I' AND E2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% )
					OR 
						( E2_TIPO='PA' AND E2_MSEXP<> '' AND STATUS_INT ='E' AND OPERACAO_INT = 'I' AND E2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% )
					)
					AND %Exp:cOpc%
		
				ORDER BY E2_FILIAL,E2_EMISSAO, R_E_C_N_O_
			EndSQL
	
		ElseIf nOpc == 2
			BeginSQL Alias cAliasT
				SELECT *
					
				FROM SGFIN010
	
				WHERE 
					(
						(E2_TIPO='PA' AND E2_MSEXP='' AND OPERACAO_INT  IN ('E','A') AND E2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND  %Exp:DTOS(MV_PAR02)% )
					OR 
						(E2_TIPO='PA' AND E2_MSEXP<> '' AND STATUS_INT ='E' AND OPERACAO_INT IN ('E','A') AND E2_EMISSAO BETWEEN %Exp:DTOS(MV_PAR01)% AND %Exp:DTOS(MV_PAR02)% )
					)
					AND %Exp:cOpc%
			
				ORDER BY E2_FILIAL,E2_EMISSAO, R_E_C_N_O_
			EndSQL
		
		EndIf
	EndIf

Return cAliasT







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINH  บAutor  ณKF SYSTEM				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para selecionar todos os itens 	                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                     	                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINH(nOpc,aDados,oGDSel,nColSel,aHead)

Local ni		:= 0
Local cRoteiro	:= ""
//Local lNot		:= .F.

	If nColSel == 2
		For ni := 1 to Len(aDados)
//			If (cCodUser $ cUserAprv .AND. aAux[ni][4] == '2') .OR. (cCodUser $ cUserLibe .AND. aAux[ni][4] == '1') //TODO: ALTERAR para posi็ใo do STATUS_LIB
				If !aDados[ni][19]
					aDados[ni][2] := !aDados[ni][2]
				EndIf
//			Else
//				lNot := .T.
//			EndIf
		Next ni
	EndIf
	
//	If lNot		
//		MsgAlert("Existem itens que foram selecionados que seu usuแrio nใo tem permissใo para liberar todos os itens", "Aviso!")
//	EndIf

//Forcar a atualizacao do browse
	oGDSel:DrawSelect()

Return Nil






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINI  บAutor  ณKF SYSTEM				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para pegar os itens selecionados e chamar as fun็๕es de    บฑฑ
ฑฑ		     ณinser็ใo, altera็ใo e exclusใo dos tํtulos					    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                     	                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINI(aCols)

Local aTitInc	:= {}
Local aTitAltDel:= {}
Local aInfoBco	:= {"", "", "", 0, ddatabase}
Local aAuxBco	:= aBancos
Local lNot		:= .F.

Private aUpdates	:= {}
Private lPermitUpd	:= .F.

	If cCodUser $ cUserAprv
	
		If cCodUser $ cUserAprv .AND. mv_par03 <> 3
			MsgAlert("Seu usuแrio possui permissใo apenas para aprovar um tํtulo jแ liberados e nใo serแ processados tํtulos com Status diferente de '2=Liberado Financeiro' ", "Aviso!")
		EndIf

		If lCheck
			aInfoBco[1] := aAuxBco[1,1]
			aInfoBco[2] := aAuxBco[1,2]
			aInfoBco[3] := aAuxBco[1,3]
			aInfoBco[4] := aAuxBco[1,4]
			aInfoBco[5] := aAuxBco[1,5]
		EndIf

		For x:=1 To Len(aCols)

			If aCols[x,2] .AND. !aCols[x,19]

				If !lCheck
					For xPosic:=2 To Len(aAuxBco)
						If aAuxBco[xPosic,6] == x
							aInfoBco[1] := aAuxBco[xPosic,1]
							aInfoBco[2] := aAuxBco[xPosic,2]
							aInfoBco[3] := aAuxBco[xPosic,3]
							aInfoBco[4] := aAuxBco[xPosic,4]
							aInfoBco[5] := aAuxBco[xPosic,5]
							
							ADEL(aAuxBco, xPosic)
							ASIZE(aAuxBco, Len(aAuxBco)-1)
					
							Exit
						EndIf
					Next xPosic
				EndIf

				If aAux[x,4] == '2'
					If aAux[x,2] == "I" .AND. aAux[x,3] <> "P"
						AADD(aTitInc, { aCols[x,1 ],;
										aCols[x,2 ],;
										aCols[x,3 ],;
										aCols[x,4 ],;
										aCols[x,5 ],;
										aCols[x,6 ],;
										aCols[x,7 ],;
										aCols[x,8 ],;
										aCols[x,9 ],;
										CTOD(aCols[x,11]),;
										CTOD(aCols[x,12]),;
										aCols[x,13],;
										aCols[x,14],;
										aCols[x,15],;
										aCols[x,16],;
										aAux [x,1 ],;
										aAux [x,2 ],;
										aAux [x,3 ],;
										aInfoBco[1],;
										aInfoBco[2],;
										aInfoBco[3],;
										aInfoBco[4],;
										aInfoBco[5]  } )
		
					ElseIf aAux[x,2] == "A" .OR. aAux[x,2] == "E"
		
						AADD(aTitAltDel, { 	aCols[x,1 ],;
											aCols[x,2 ],;
											aCols[x,3 ],;
											aCols[x,4 ],;
											aCols[x,5 ],;
											aCols[x,6 ],;
											aCols[x,7 ],;
											aCols[x,8 ],;
											aCols[x,9 ],;
											CTOD(aCols[x,11]),;
											CTOD(aCols[x,12]),;
											aCols[x,13],;
											aCols[x,14],;
											aCols[x,15],;
											aCols[x,16],;
											aAux [x,1 ],;
											aAux [x,2 ],;
											aAux [x,3 ],;
											aInfoBco[1],;
											aInfoBco[2],;
											aInfoBco[3],;
											aInfoBco[4],;
											aInfoBco[5]  } )
					EndIf

				EndIf

			EndIf
			
		Next x
		
		BeginTran()
            
			If Len(aTitInc) > 0
				INTFINA(Nil, aTitInc) //INCLUSรO
			EndIf
		
			Pergunte(cPerg,.F.) // seta a pergunta da rotina de importa็ใo
			
			If Len(aTitAltDel) > 0
				INTFINB(aTitAltDel) //EXCLUSรO / ALTERวรO
			EndIf

		EndTran()
	
	Else
		
		If cCodUser $ cUserLibe .AND. mv_par03 <> 2
			MsgAlert("Seu usuแrio possui permissใo apenas para liberar um tํtulo e nใo serแ liberado tํtulos com Status diferente de '1=Liberado Compras SAG' ", "Aviso!")
		EndIf
		
		/* Rotina para alterar o status das PA's selecionadas para liberado pelo financeiro */
		For k:=1 To Len(aCols)
			If aCols[k,2] .AND. !aCols[k,19]
				If aAux[k,4] == '1'
					AADD(aUpdates, "UPDATE SGFIN010 SET STATUS_LIB='2' WHERE R_E_C_N_O_=" + AllTrim( STR(aCols[k,15]) ) + " ")
					
					cMensagem += "Libera็ใo da PA =  '" + aCols[k][5] + "' / '" + aCols[k][4] +"', Fornecedor = '" + aCols[k][9] + "' "  
					cMensagem += "e xRecOrigem = '" + AllTrim(Str(aCols[k][15])) + "' " + CHR(13) + CHR(10)
				EndIf
			EndIf
		Next
	EndIf
	
	If Len(aUpdates) > 0
		////TcSetConn(_nTcConn2)
		For nNum:=1 To Len(aUpdates)
			TcSqlExec(aUpdates[nNum])
		Next nNum
	EndIf
	
	U_ExTelaMen("INTFIN - Processo concluido!!!", cMensagem, "Arial", 10, , .F., .T.)
	
	cMensagem := ""	
	
Return .T.





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINJ  บAutor  ณKF SYSTEM				    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para preencher as informa็๕es do banco						บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                     	                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINJ(lMsmBco, lIndival)

Local oDlg	
Local lRet := .T.

Default lMsmBco := .F.
Default lIndival := .F.	

	//TcSetConn(_nTcConn1)

	If !lMsmBco
		DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Informa็๕es do Banco") PIXEL
			@ 11,15 SAY OemToAnsi("Este programa efetua a integra็ใo dos Pagmentos Antecipados oriundos do SAG.") SIZE 268, 8 OF oDlg PIXEL
			
			@ 25,6 SAY OemToAnsi("Banco") SIZE 30, 8 OF oDlg PIXEL
			@ 32,6 MSGET cBanco Of oDlg F3 "SA6" PIXEL SIZE 30,10
			
			@ 25,80 SAY OemToAnsi("Ag๊ncia") SIZE 30, 8 OF oDlg PIXEL
			@ 32,80 MSGET cAgencia Of oDlg PIXEL SIZE 30,10	
			
			@ 25,160 SAY OemToAnsi("Conta Banco") SIZE 30, 8 OF oDlg PIXEL
			@ 32,160 MSGET cContaC Of oDlg PIXEL SIZE 50,10
			
			@ 55,6 SAY OemToAnsi("Taxa US$") SIZE 30, 8 OF oDlg PIXEL
			@ 62,6 MSGET nTaxa Of oDlg PIXEL Picture PesqPict("SA6","A6_SALATU")  SIZE 60,10
			
			@ 55,80 SAY OemToAnsi("Data Vencimento") SIZE 30, 8 OF oDlg PIXEL
			@ 62,80 MSGET dDataVenc Of oDlg PIXEL PICTURE "99/99/99"  SIZE 76,10
		
			DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION (lRet:=.T.,oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION (lRet:=.F.,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED
	Else
	
		If !lCheck
			DEFINE MSDIALOG oDlg FROM  96,9 TO 320,612 TITLE OemToAnsi("Informa็๕es do Banco") PIXEL
				@ 11,15 SAY OemToAnsi("Este programa efetua a integra็ใo dos Pagmentos Antecipados oriundos do SAG.") SIZE 268, 8 OF oDlg PIXEL
				
				@ 25,6 SAY OemToAnsi("Banco") SIZE 30, 8 OF oDlg PIXEL
				@ 32,6 MSGET cBanco Of oDlg F3 "SA6" PIXEL SIZE 30,10
				
				@ 25,80 SAY OemToAnsi("Ag๊ncia") SIZE 30, 8 OF oDlg PIXEL
				@ 32,80 MSGET cAgencia Of oDlg PIXEL SIZE 30,10	
				
				@ 25,160 SAY OemToAnsi("Conta Banco") SIZE 30, 8 OF oDlg PIXEL
				@ 32,160 MSGET cContaC Of oDlg PIXEL SIZE 30,10
				
				@ 55,6 SAY OemToAnsi("Taxa US$") SIZE 30, 8 OF oDlg PIXEL
				@ 62,6 MSGET nTaxa Of oDlg PIXEL Picture PesqPict("SA6","A6_SALATU")  SIZE 60,10
				
				@ 55,80 SAY OemToAnsi("Data Vencimento") SIZE 30, 8 OF oDlg PIXEL
				@ 62,80 MSGET dDataVenc Of oDlg PIXEL PICTURE "99/99/99"  SIZE 76,10
			
				DEFINE SBUTTON FROM 93, 223 TYPE 1  ACTION (lRet:=.T.,oDlg:End()) ENABLE OF oDlg
				DEFINE SBUTTON FROM 93, 253 TYPE 2  ACTION (lRet:=.F.,oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTERED
		EndIf
	EndIf

	If lRet
		If lCheck .OR. lMsmBco
			aBancos[1,1] := cBanco
			aBancos[1,2] := cAgencia
			aBancos[1,3] := cContaC
			aBancos[1,4] := nTaxa
			aBancos[1,5] := dDataVenc
			aBancos[1,6] := oGD01:nAt
		Else
//			If lIndival
				lAchei := .F.
				For xPosic:=2 To Len(aBancos)
					If aBancos[xPosic,6] == oGD01:nAt
						lAchei := .T.
						If cBanco <> aBancos[xPosic,1] .OR. cAgencia <> aBancos[xPosic,2] .OR. cContaC <> aBancos[xPosic,3] .OR. nTaxa <> aBancos[xPosic,4] .OR. dDataVenc <> aBancos[xPosic,5]
							aBancos[xPosic,1] := cBanco
							aBancos[xPosic,2] := cAgencia
							aBancos[xPosic,3] := cContaC
							aBancos[xPosic,4] := nTaxa
							aBancos[xPosic,5] := dDataVenc							
						EndIf
						
						Exit
					EndIf
				Next xPosic
		        
				If !lAchei
					AADD(aBancos, {cBanco, cAgencia, cContaC, nTaxa, dDataVenc, oGD01:nAt})
				EndIf
//			EndIf
		EndIf
	EndIf
    
	If lMsmBco
		If !lRet
			lCheck := lRet
		Else
			lCheck := !lCheck
		EndIf

		oCheck1:Refresh()
	EndIF
	
	cBanco	:= SPACE(TamSx3("A6_COD")[1])
	cAgencia:= SPACE(TamSx3("A6_AGENCIA")[1])
	cContaC := SPACE(TamSx3("A6_NUMCON")[1])
	nTaxa	:= 0
	dDataVenc := ddatabase
	
Return lCheck







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINK   บAutor  ณMicrosiga           บ Data ณ  12/22/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza informa็๕es do banco do item selecionado          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINK

Local nPos := oGD01:nAt
Local nLin := 0
	
	If lCheck
		cBanco		:= aBancos[1,1]
		cAgencia	:= aBancos[1,2]
		cContaC		:= aBancos[1,3]
		nTaxa		:= aBancos[1,4]
		dDataVenc	:= aBancos[1,5]
	Else
		If Len(aBancos) > 1
			For nPosi:=2 To Len(aBancos)
				If aBancos[nPosi,6] == nPos
					nLin := nPosi
					Exit
				EndIf
			Next nPosi
			
			If nLin > 0
				cBanco	 := aBancos[nLin,1]
				cAgencia := aBancos[nLin,2]
				cContaC	 := aBancos[nLin,3]
				nTaxa	 := aBancos[nLin,4]
				dDataVenc:= aBancos[nLin,5]
			EndIf
			
		EndIf	
	EndIf
	
	INTFINJ()
	
Return







/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออออหออออออัออออออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINL  บAutor  ณKF SYSTEM			    บ Data ณ04/06/12        บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออออสออออออฯออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para pegar os itens selecionados e chamar as fun็๕es de    บฑฑ
ฑฑ		     ณexclusใo dos tํtulos											    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ                                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                     	                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINL(aDados)

Local aTitulos	 := {}
Local lNot		 := .F.
Local cAlert	 := ""

Private aUpdates := {}
Private cMensagem:= ""

Default aDados	 := {}


	For x:=1 To Len(aDados)
		
		If aDados[x,2] .AND. !aDados[x,19]
			If cCodUser $ cUserAprv
				
				If aAux[x,4] <> "3" .AND. aAux[x,4] <> "4"
					lNot := .T.
					cAlert := "Seu usuแrio selecionou itens com status diferentes de 3 ou 4 para fazer o estorno! S๓ serแ estornado itens com status '3=PA Gerado' ou '4=PA Baixado' "
				EndIf
				
				If aAux[x,4] == "3" .OR. aAux[x,4] == "4"
					AADD(aTitulos, { 	aDados[x,1 ],;
										aDados[x,2 ],;
										aDados[x,3 ],;
										aDados[x,4 ],;
										aDados[x,5 ],;
										aDados[x,6 ],;
										aDados[x,7 ],;
										aDados[x,8 ],;
										aDados[x,9 ],;
										CTOD(aDados[x,11]),;
										CTOD(aDados[x,12]),;
										aDados[x,13],;
										aDados[x,14],;
										aDados[x,15],;
										aDados[x,16],;
										aAux [x,1 ],;
										"E"		   ,;
										aAux [x,3 ]  } )
					
					cMensagem += "Estorno da PA = '" + aDados[x][5] + "' / '" + aDados[x][4] + "' e Fornecedor = '" + aDados[x][9] + "' "
					cMensagem += "e altera็ใo do campos STATUS_LIB para '2' " + CHR(13) + CHR(10)
				EndIf				
			EndIf
			
			If cCodUser $ cUserLibe
				If aAux[x,4] <> "2"
					lNot := .T.
					cAlert := "Seu usuแrio selecionou itens com status diferentes de 2 para fazer o estorno! S๓ serแ estornado itens com status '2=Liberado pelo Financeiro'"
				EndIf
				
				If aAux[x,4] == "2"					
					AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP=' ', STATUS_LIB='1' WHERE R_E_C_N_O_=" + ALLTRIM( Str(aDados[x][15]) ) )
					
					cMensagem += "Estorno da PA = '" + aDados[x][5] + "' / '" + aDados[x][4] + "', Fornecedor = '" + aDados[x][9] + "' "
					cMensagem += "e altera็ใo do campos STATUS_LIB para '1' " + CHR(13) + CHR(10)
				EndIf
			EndIf
		EndIf

	Next x
	
	If lNot
		MsgAlert(cAlert, "Aviso!")
	EndIf
	
	If cCodUser $ cUserAprv
		BeginTran()
			INTFINB(aTitulos, .T.)
		EndTran()
	EndIf
	
	If Len(aUpdates) > 0
		//TcSetConn(_nTcConn2)
		For nNum:=1 To Len(aUpdates)
			TcSqlExec(aUpdates[nNum])
		Next nNum
	EndIf

	U_ExTelaMen("INTFIN - Processo de Estorno dos tํtulo concluido!!!", cMensagem, "Arial", 10, , .F., .T.)
	
	cMensagem := ""
	
Return .T.








/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLegenda   บAutor  ณMicrosiga           บ Data ณ  12/22/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda das cores                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINTFIN                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Legenda()

Local aLegenda := {}
    
	AADD(aLegenda,{"BR_BRANCO"	,"Integrado" 		  		})
	AADD(aLegenda,{"BR_VERDE" 	,"Liberado Compras SAG"		})
	AADD(aLegenda,{"BR_AZUL"	,"Liberado Financeiro" 		})
	AADD(aLegenda,{"BR_CINZA"	,"PA Gerado"		   		})
	AADD(aLegenda,{"BR_MARROM"	,"PA baixada"		   		})
	AADD(aLegenda,{"BR_VERMELHO","Error/Status Indefinido"	})
	
	BrwLegenda("Legenda", "Status PA", aLegenda)


Return Nil

                             	





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINA   บAutor  ณMicrosiga           บ Data ณ  04/16/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusao PA                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro - Projeto SAG II                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINA (nRec, aDados, aBco)

Local _aArea     := GetArea()
Local _lExporta  := .F.
Local _lRet      := .T.
Local lHtml      := .T.
Local cAnexo     := ""
Local cMsgError  := ""
Local dData		 := DDATABASE
Local cAliasF1	 := GetNextAlias()

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

Default nRec	:= 0
Default aDados	:= {}
Default aBco	:= {}

	_lJob    := .F.


//TESTA CONEXAO COM O BANCO DE INTEGRAวรO
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	_lRet     := .F.
	// 	cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
	// 	MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")
	// EndIf

	If nRec > 0
		//TcSetConn(_nTcConn2)
		
		cQry := "SELECT * FROM SGFIN010 WHERE R_E_C_N_O_="+AllTrim(Str(nRec))+" "
		DbUseArea(.t., "TOPCONN", TcGenQry(,, cQry), cAliasF1, .F., .T.)

		TcSetField( cAliasF1, "E2_EMISSAO", "D", 8, 0 )
		TcSetField( cAliasF1, "E2_VENCTO", "D", 8, 0 )
		
		While !(cAliasF1)->(Eof())
			AADD(aDados, {	Nil						,;
							.F.                 	,;
							(cAliasF1)->E2_FILIAL	,;
							(cAliasF1)->E2_PREFIXO	,;
							(cAliasF1)->E2_NUM		,;
							(cAliasF1)->E2_TIPO		,;
							(cAliasF1)->E2_PARCELA	,;
							(cAliasF1)->E2_NATUREZ	,;
							(cAliasF1)->E2_FORNECE	,;
							(cAliasF1)->E2_EMISSAO	,;
							(cAliasF1)->E2_VENCTO	,;
							(cAliasF1)->E2_VALOR	,;
							(cAliasF1)->E2_HIST		,;
							(cAliasF1)->R_E_C_N_O_	,;
							(cAliasF1)->E2_MOEDA	,;
							(cAliasF1)->STATUS_INT	,;
							(cAliasF1)->OPERACAO_INT,;
							(cAliasF1)->STATUS_PRC 	,;
							aBco[1]					,;
							aBco[2]					,;
							aBco[3]					,;
							aBco[4]					,;
							aBco[5]					  })
							
							
//							"001"					,;
//							"30813"					,;
//							"55170_8"				  })

			(cAliasF1)->(DbSkip())
		EndDo			
	EndIf 


//backup da filial corrente
	cFilBck := cFilAnt

	cChave:=""

	If EMPTY(aDados)
		cMensagem := "Sem registros a serem processados!" + CHR(13)+CHR(10)
	Endif

//If (cAliasF1)->(Eof())
//	cMensagem := "Sem registros a serem processados!"
//EndIf               

	For x:=1 to Len(aDados)

//While !(cAliasF1)->(Eof())
	//dbSelectArea(cAliasF1)
	
//	cFilAnt	:= (cAliasF1)->E2_FILIAL
//	cFilMOV := (cAliasF1)->E2_FILIAL
//	nRecMOV := (cAliasF1)->R_E_C_N_O_
//	cRecMov := StrZero((cAliasF1)->R_E_C_N_O_,10) // foi setado como caracter pois indices numericos dao problema no protheus 
	
		cFilAnt	:= (aDados[x][3])
		cFilMOV := (aDados[x][3])
		nRecMOV := (aDados[x][14])
		cRecMov := StrZero((aDados[x][14]),10)

		DDATABASE := (aDados[x][10])
	
		aCampos:={}
		
//	aAdd(aCampos,{ "E2_PREFIXO" , (cAliasF1)->E2_PREFIXO 	 			, NIL })
//	aAdd(aCampos,{ "E2_NUM"     , (cAliasF1)->E2_NUM 					, NIL })
//	aAdd(aCampos,{ "E2_TIPO"    , (cAliasF1)->E2_TIPO 	   				, NIL })
//	aAdd(aCampos,{ "E2_PARCELA" , (cAliasF1)->E2_PARCELA	 			, NIL }) 
//	aAdd(aCampos,{ "E2_NATUREZ" , (cAliasF1)->E2_NATUREZ  				, NIL }) 
//	aAdd(aCampos,{ "E2_FORNECE" , (cAliasF1)->E2_FORNECE 				, NIL })
//	aAdd(aCampos,{ "E2_EMISSAO" , (cAliasF1)->E2_EMISSAO				, NIL })
//	aAdd(aCampos,{ "E2_VENCTO"  , (cAliasF1)->E2_VENCTO				, NIL })
//	aAdd(aCampos,{ "E2_VALOR"   , (cAliasF1)->E2_VALOR					, NIL })
//	aAdd(aCampos,{ "E2_HIST"	, (cAliasF1)->E2_HIST		  			, NIL })	
//	aAdd(aCampos,{ "E2_XRECORI"	, cRecMov						, NIL })		
//	aAdd(aCampos,{ "E2_CCSOLIC", "5000"			   				, NIL }) //VERIFICAR
//	aAdd(aCampos,{ "AUTBANCO"   , "001" 		   				, NIL })  //VERIFICAR
//	aAdd(aCampos,{ "AUTAGENCIA" , "30813" 		   				, NIL })  //VERIFICAR
//	aAdd(aCampos,{ "AUTCONTA"   , "55170_8" 	   				, NIL })  //VERIFICAR
//
//	cFilMOV := (cAliasF1)->E2_FILIAL
//	nRecMOV := (cAliasF1)->R_E_C_N_O_
//	
//	cMensagem += "Inclusใo PA Numero = '" + (cAliasF1)->E2_NUM + "' / " + (cAliasF1)->E2_PREFIXO + CRLF + CRLF

		aAdd(aCampos,{ "E2_PREFIXO" , (aDados[x][4]	)	 			, NIL })
		aAdd(aCampos,{ "E2_NUM"     , (aDados[x][5]	)				, NIL })
		aAdd(aCampos,{ "E2_TIPO"    , (aDados[x][6]	)	   			, NIL })
		aAdd(aCampos,{ "E2_PARCELA" , (aDados[x][7]	)	 			, NIL })
		aAdd(aCampos,{ "E2_NATUREZ" , (aDados[x][8]	)  				, NIL })
		aAdd(aCampos,{ "E2_FORNECE" , (aDados[x][9]) 				, NIL })
		aAdd(aCampos,{ "E2_EMISSAO" , (aDados[x][10])				, NIL })
		aAdd(aCampos,{ "E2_VENCTO"  , (aDados[x][23])				, NIL }) //TODO: VERIFICAR
		aAdd(aCampos,{ "E2_VALOR"   , Iif(aDados[x][15] == Nil .Or. Empty(Alltrim(aDados[x][15])) .Or. aDados[x][15] == 1, aDados[x][12], aDados[x][12]*aDados[x][15]), NIL })
		aAdd(aCampos,{ "E2_HIST"	, (aDados[x][13])		  		, NIL })
		aAdd(aCampos,{ "E2_XRECORI"	, cRecMov						, NIL })
		aAdd(aCampos,{ "E2_CCSOLIC", "5000"			   				, NIL })
		aAdd(aCampos,{ "AUTBANCO"   , (aDados[x][19])  				, NIL })
		aAdd(aCampos,{ "AUTAGENCIA" , (aDados[x][20]) 				, NIL })
		aAdd(aCampos,{ "AUTCONTA"   , (aDados[x][21])  				, NIL })

		cFilMOV := (aDados[x][3])
		nRecMOV := (aDados[x][14])
	
		cMensagem += "Inclusใo PA Numero = '" + (aDados[x][5]) + "' / '" + (aDados[x][4]) + "',  Fornecedor = '" + aDados[x][9] + "' " 
		cMensagem += "e xRecOrigem = '" + cRecMov + "' " + CHR(13) + CHR(10)
	
		//TcSetConn(_nTcConn1)
		lMsErroAuto:=.F.
	
		Begin Transaction
			MSExecAuto({|x,y,z| FINA050(x,y,z)}, aCampos, 3)
		
			If lMsErroAuto
				DisarmTransaction()
				aErroLog:=GetAutoGrLog()
				cErro := Alltrim(aErrolog[1])
				For k := 1 to Len(aErroLog)
					If "INVALIDO" $ UPPER (aErroLog[k])
						cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
					EndIf
				Next
				cErro := Replace(cErro,Chr(13)+Chr(10)," ")
			
//				U_CCSGrvLog(cErro, cAliasF1, nRecMOV, 3, cFilMOV, .T.)
				U_CCSGrvLog(cErro, "SE2", nRecMOV, 3, cFilMOV, .T.)
			
				//TcSetConn(_nTcConn2)
			
				cMensagem += "ERRO: " + cErro + CHR(13)+CHR(10)
			
//				TcSqlExec("UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")

				AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
			
			Else
				dbSelectArea("SE2")
				dbOrderNickName("RECORI")
				dbSeek(cFilMov+cRecMov)
				If !Eof()
					//TcSetConn(_nTcConn2)
				
					cMensagem += "SUCESSO!!" + CHR(13)+CHR(10)
				
//					TcSqlExec("UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' ,MENSAGEM_INT='' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S' ,MENSAGEM_INT='', STATUS_LIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				Else
					//TcSetConn(_nTcConn2)
				
					cMensagem += "ERRO NรO IDENTIFICADO!" + CHR(13)+CHR(10)
				
//					TcSqlExec("UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='ERRO NAO IDENTIFICADO!' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='ERRO NAO IDENTIFICADO!', STATUS_LIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				EndIf
			EndIF
	
		End Transaction
	
		//TcSetConn(_nTcConn2)
	
		cMensagem += CHR(13)+CHR(10)
	
//		(cAliasF1)->(DbSkip())
	
//nCount ++ 

	Next x

//EndDo

//(cAliasF1)->(DbCloseArea())

//restaura filial corrente
	cFilAnt := cFilBck
	DDATABASE := dData
	
	RestArea(_aArea)
Return Nil


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINTFINB   บAutor  ณMicrosiga           บ Data ณ  04/16/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclusใo PA                                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Adoro - Projeto SAG II                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function INTFINB (aDados, lEstorno)

Local _aArea     := GetArea()
Local _lExporta  := .F.
Local _lRet      := .T.
Local lHtml      := .T.
Local cAnexo     := ""
Local cMsgError  := ""
Local dData		 := DDATABASE
Local xOper
Local cOper		 := ""
Local cAliasF2	 := GetNextAlias()

Private lMsErroAuto 	:= .F.
Private lMsHelpAuto 	:= .T.
Private lAutoErrNoFile 	:= .T.

Default aDados := {}
Default lEstorno := .F.

	_lJob    := .F.

//TESTA CONEXAO COM O BANCO DE INTEGRAวรO
	// If (_nTcConn2 := TcLink(_cNomBco2,_cSrvBco2,_cPortBco2))<0
	// 	_lRet     := .F.
	// 	cMsgError := "Nใo foi possํvel  conectar ao banco integra็ใo"
	// 	MsgInfo("Nใo foi possํvel  conectar ao banco integra็ใo, verifique com administrador","ERROR")
	// EndIf

//backup da filial corrente
	cFilBck := cFilAnt

	cChave:=""

	For x:=1 to Len(aDados)
	
		cFilAnt	:= (aDados[x][3])
		cFilMOV := (aDados[x][3])
		nRecMOV := (aDados[x][14])
		cRecMov := StrZero((aDados[x][14]),10)

		DDATABASE := (aDados[x][10])
	
		xOper	:= IIF((aDados[x][17])=='A',4,5)
		cOper   := IIF(xOper == 4, "Altera็ใo", "Exclusใo")
	
		cFilAnt := (aDados[x][3])

		cMensagem += cOper + " de PA Numero = '" + (aDados[x][5]) + "' / '" + (aDados[x][4]) + "', Fornecedor = '" + aDados[x][9] + "' "
		cMensagem += "e xRecOrigem = '" + cRecMov + "' " + CHR(13) + CHR(10)
		
		//TcSetConn(_nTcConn1)
	
		dbSelectArea("SE2")
		dbOrderNickName("RECORI")
		dbSeek(cFilMov+Padr(cRecMov,TamSX3("E2_XRECORI")[1]) )
		If ! Eof()	

			DDATABASE := aDados[x][10]
		
			aCampos:={}
				
//			//TcSetConn(_nTcConn2)
			
			aAdd(aCampos,{ "E2_PREFIXO" , SE2->E2_PREFIXO 	, NIL })
			aAdd(aCampos,{ "E2_NUM"     , SE2->E2_NUM		, NIL })
			aAdd(aCampos,{ "E2_PARCELA" , SE2->E2_PARCELA 	, NIL })
			aAdd(aCampos,{ "E2_FORNECE" , SE2->E2_FORNECE 	, NIL })
			aAdd(aCampos,{ "E2_LOJA"    , SE2->E2_LOJA		, NIL })
		
			//TcSetConn(_nTcConn1)
	
			lMsErroAuto:=.F.
		
			Begin Transaction
				MSExecAuto( { |x,y,z| FINA050(x,y,z)}, aCampos,,xOper)
			
				If lMsErroAuto
					
					DisarmTransaction()
					aErroLog:=GetAutoGrLog()
					cErro := Alltrim(aErrolog[1])
					For k := 1 to Len(aErroLog)
						If "INVALIDO" $ UPPER (aErroLog[k])
							cErro+= Alltrim(aErroLog[k]) //+ Chr(13)+Chr(10)
						EndIf
					Next
	
					cErro := Replace(cErro,Chr(13)+Chr(10)," ")
				
					U_CCSGrvLog(cErro, "SE2", nRecMOV, xOper, cFilMOV, .T.)
				
					cMensagem += "Erro: " +cOper + " de PA Numero = '" + SE2->E2_NUM + "' / '" + SE2->E2_PREFIXO + "',  Fornecedor = '" + SE2->E2_FORNECE + "' "
					cMensagem += "e xRecOrigem = '" + SE2->E2_XRECORI + "' " + CHR(13) + CHR(10)
					 
					AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='E', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
					
				Else
					
					If xOper == 4
						dbSelectArea("SE2")
						dbOrderNickName("RECORI")
						dbSeek(cFilMov+cRecMov)
						If ! Eof()
							cMensagem += "Sucesso: " +cOper + " de PA Numero = '" + SE2->E2_NUM + "' / '" + SE2->E2_PREFIXO + "', Fornecedor = '" + SE2->E2_FORNECE + "' "
							cMensagem += "e xRecOrigem = '" + SE2->E2_XRECORI + "' " + CHR(13) + CHR(10)
							
							AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', STATUS_LIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
						Else
							MsgInfo("PA nใo foi Excluํda!!!","ERROR")
						EndIf
					
					Else
						cMensagem += "Sucesso: " +cOper + " de PA Numero = '" + SE2->E2_NUM + "' / " + SE2->E2_PREFIXO + ", Fornecedor = '" + SE2->E2_FORNECE + "' "
						cMensagem += "e xRecOrigem = '" + SE2->E2_XRECORI + "' " + CHR(13) + CHR(10)

						If lEstorno
							AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP=' ',STATUS_INT='S', STATUS_LIB='2' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
						Else
							AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', STATUS_LIB='3' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
						EndIf
						
					EndIf
				EndIf
		
			End Transaction
		Else
	
			If xOper == 4

			//SE FOR ALTERAวรO E NรO ACHAR, EFETUA A INCLUSรO NOVAMENTE
				INTFINA(nRecMOV, Nil, {aDados[x][19], aDados[x][20], aDados[x][21], aDados[x][22], aDados[x][23]})
			
			Else
		
				cErro:= "PA NAO ENCONTRADA!"
			
				U_CCSGrvLog(cErro, "SE2", nRecMOV, xOper, cFilMOV, .T.)
					
				//TcSetConn(_nTcConn2)
			
				cMensagem += "Erro: " +cOper + " de PA Numero = '" + aDados[x,5] + "' / " + aDados[x,4] + " e Fornecedor = '" + aDados[x][9] + "' "
				cMensagem += "e xRecOrigem = '" + AllTrim(Str(nRecMOV)) + "' " + CHR(13) + CHR(10)
				
				cMensagem += "Produto Acabado nใo encontrado na tabela SE2 do Protheus " + CHR(13)+CHR(10)
			
				TcSqlExec("UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
				
				AADD(aUpdates, "UPDATE SGFIN010 SET E2_MSEXP='" +DTOS(DDATABASE) + "' ,STATUS_INT='S', MENSAGEM_INT='"+cErro+ "' WHERE R_E_C_N_O_="+AllTrim(Str(nRecMOV))+" ")
			
			EndIf
	
		EndIf
	
		//TcSetConn(_nTcConn2)
	
		cMensagem += CHR(13)+CHR(10)
	
//		(cAliasF2)->(DbSkip())

	Next x
	
//EndDo

//	(cAliasF2)->(DbCloseArea())

//restaura filial corrente
	cFilAnt := cFilBck
	DDATABASE := dData
	
	RestArea(_aArea)
Return Nil


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAjustaSX1 บAutor  ณClaudio D. de Souza บ Data ณ08.07.2004   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere novas perguntas ao sx1                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINR150                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AjustaSX1(cPerg)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para parametros ณ
//ณ mv_par01	  // Datade    			 ณ
//ณ mv_par02	  // Dataate   		     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	PutSx1(cPerg,"01", "Data de"    , "Data de" , "Data de"	, "mv_cha", "D", 8					   	 , 0, 1, "G", "", ""   , "", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	PutSx1(cPerg,"02", "Data ate"   , "Data ate", "Data ate", "mv_chb", "D", 8					   	 , 0, 1, "G", "", ""   , "", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "")
	PutSx1(cPerg,"03", "Status" 	, "Status"	, "Status"	, "mv_chc", "N", 1					   	 , 0, 1, "C", "", ""   , "", "", "mv_par03", "0=Integrado", "0=Integrado", "0=Integrado", "", "1=Liberado Compras SAG", "1=Liberado Compras SAG", "1=Liberado Compras SAG", "2=Liberado Financeiro", "2=Liberado Financeiro", "2=Liberado Financeiro", "3=PA Gerado", "3=PA Gerado", "3=PA Gerado", "4=PA Baixado", "4=PA Baixado", "4=PA Baixado" )
Return
