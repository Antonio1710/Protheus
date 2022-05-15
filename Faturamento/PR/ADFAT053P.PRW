#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://186.224.100.105:48884/WsGemba/Shed.asmx?WSDL
Gerado em        05/13/22 13:04:16
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _IYOUAIC ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSShed
------------------------------------------------------------------------------- */

WSCLIENT WSShed

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Insert

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSsheds                  AS Shed_ArrayOfShed
	WSDATA   oWSInsertResult           AS Shed_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSShed
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSShed
	::oWSsheds           := Shed_ARRAYOFSHED():New()
	::oWSInsertResult    := Shed_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSShed
	::oWSsheds           := NIL 
	::oWSInsertResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSShed
Local oClone := WSShed():New()
	oClone:_URL          := ::_URL 
	oClone:oWSsheds      :=  IIF(::oWSsheds = NIL , NIL ,::oWSsheds:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
Return oClone

// WSDL Method Insert of Service WSShed

WSMETHOD Insert WSSEND oWSsheds WSRECEIVE oWSInsertResult WSCLIENT WSShed
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("sheds", ::oWSsheds, oWSsheds , "ArrayOfShed", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Shed.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfShed

WSSTRUCT Shed_ArrayOfShed
	WSDATA   oWSshed                   AS Shed_shed OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Shed_ArrayOfShed
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Shed_ArrayOfShed
	::oWSshed              := {} // Array Of  Shed_SHED():New()
Return

WSMETHOD CLONE WSCLIENT Shed_ArrayOfShed
	Local oClone := Shed_ArrayOfShed():NEW()
	oClone:oWSshed := NIL
	If ::oWSshed <> NIL 
		oClone:oWSshed := {}
		aEval( ::oWSshed , { |x| aadd( oClone:oWSshed , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Shed_ArrayOfShed
	Local cSoap := ""
	aEval( ::oWSshed , {|x| cSoap := cSoap  +  WSSoapValue("shed", x , x , "shed", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStatus

WSSTRUCT Shed_ArrayOfStatus
	WSDATA   oWSStatus                 AS Shed_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Shed_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Shed_ArrayOfStatus
	::oWSStatus            := {} // Array Of  Shed_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT Shed_ArrayOfStatus
	Local oClone := Shed_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Shed_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , Shed_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure shed

WSSTRUCT Shed_shed
	WSDATA   cds_code_shed             AS string OPTIONAL
	WSDATA   cds_code_customer         AS string OPTIONAL
	WSDATA   cnm_shed                  AS string OPTIONAL
	WSDATA   cds_address               AS string OPTIONAL
	WSDATA   cnm_city                  AS string OPTIONAL
	WSDATA   csg_state                 AS string OPTIONAL
	WSDATA   cnm_country               AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Shed_shed
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Shed_shed
Return

WSMETHOD CLONE WSCLIENT Shed_shed
	Local oClone := Shed_shed():NEW()
	oClone:cds_code_shed        := ::cds_code_shed
	oClone:cds_code_customer    := ::cds_code_customer
	oClone:cnm_shed             := ::cnm_shed
	oClone:cds_address          := ::cds_address
	oClone:cnm_city             := ::cnm_city
	oClone:csg_state            := ::csg_state
	oClone:cnm_country          := ::cnm_country
	oClone:ccd_company_unit     := ::ccd_company_unit
Return oClone

WSMETHOD SOAPSEND WSCLIENT Shed_shed
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_shed", ::cds_code_shed, ::cds_code_shed , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_customer", ::cds_code_customer, ::cds_code_customer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_shed", ::cnm_shed, ::cnm_shed , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_address", ::cds_address, ::cds_address , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_city", ::cnm_city, ::cnm_city , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sg_state", ::csg_state, ::csg_state , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_country", ::cnm_country, ::cnm_country , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT Shed_Status
	WSDATA   cstatusCode               AS string OPTIONAL
	WSDATA   cidentification           AS string OPTIONAL
	WSDATA   cdescription              AS string OPTIONAL
	WSDATA   cname                     AS string OPTIONAL
	WSDATA   cvalue                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Shed_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Shed_Status
Return

WSMETHOD CLONE WSCLIENT Shed_Status
	Local oClone := Shed_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Shed_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return
