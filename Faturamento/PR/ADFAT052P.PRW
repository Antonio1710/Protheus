#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://186.224.100.105:48884/WsGemba/Customer.asmx?WSDL
Gerado em        05/13/22 11:51:23
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _UQQIRRM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCustomer
------------------------------------------------------------------------------- */

WSCLIENT WSCustomer

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Exists
	WSMETHOD Insert

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cds_code_customer         AS string
	WSDATA   oWSExistsResult           AS Customer_ArrayOfStatus
	WSDATA   oWScustomers              AS Customer_ArrayOfCustomer
	WSDATA   oWSInsertResult           AS Customer_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCustomer
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCustomer
	::oWSExistsResult    := Customer_ARRAYOFSTATUS():New()
	::oWScustomers       := Customer_ARRAYOFCUSTOMER():New()
	::oWSInsertResult    := Customer_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSCustomer
	::cds_code_customer  := NIL 
	::oWSExistsResult    := NIL 
	::oWScustomers       := NIL 
	::oWSInsertResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCustomer
Local oClone := WSCustomer():New()
	oClone:_URL          := ::_URL 
	oClone:cds_code_customer := ::cds_code_customer
	oClone:oWSExistsResult :=  IIF(::oWSExistsResult = NIL , NIL ,::oWSExistsResult:Clone() )
	oClone:oWScustomers  :=  IIF(::oWScustomers = NIL , NIL ,::oWScustomers:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
Return oClone

// WSDL Method Exists of Service WSCustomer

WSMETHOD Exists WSSEND cds_code_customer WSRECEIVE oWSExistsResult WSCLIENT WSCustomer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Exists xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ds_code_customer", ::cds_code_customer, cds_code_customer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Exists>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Exists",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Customer.asmx")

::Init()
::oWSExistsResult:SoapRecv( WSAdvValue( oXmlRet,"_EXISTSRESPONSE:_EXISTSRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Insert of Service WSCustomer

WSMETHOD Insert WSSEND oWScustomers WSRECEIVE oWSInsertResult WSCLIENT WSCustomer
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("customers", ::oWScustomers, oWScustomers , "ArrayOfCustomer", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Customer.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfStatus

WSSTRUCT Customer_ArrayOfStatus
	WSDATA   oWSStatus                 AS Customer_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Customer_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Customer_ArrayOfStatus
	::oWSStatus            := {} // Array Of  Customer_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT Customer_ArrayOfStatus
	Local oClone := Customer_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Customer_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , Customer_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfCustomer

WSSTRUCT Customer_ArrayOfCustomer
	WSDATA   oWScustomer               AS Customer_customer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Customer_ArrayOfCustomer
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Customer_ArrayOfCustomer
	::oWScustomer          := {} // Array Of  Customer_CUSTOMER():New()
Return

WSMETHOD CLONE WSCLIENT Customer_ArrayOfCustomer
	Local oClone := Customer_ArrayOfCustomer():NEW()
	oClone:oWScustomer := NIL
	If ::oWScustomer <> NIL 
		oClone:oWScustomer := {}
		aEval( ::oWScustomer , { |x| aadd( oClone:oWScustomer , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Customer_ArrayOfCustomer
	Local cSoap := ""
	aEval( ::oWScustomer , {|x| cSoap := cSoap  +  WSSoapValue("customer", x , x , "customer", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT Customer_Status
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

WSMETHOD NEW WSCLIENT Customer_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Customer_Status
Return

WSMETHOD CLONE WSCLIENT Customer_Status
	Local oClone := Customer_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Customer_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure customer

WSSTRUCT Customer_customer
	WSDATA   cds_code_customer         AS string OPTIONAL
	WSDATA   cnm_customer              AS string OPTIONAL
	WSDATA   cnr_phone                 AS string OPTIONAL
	WSDATA   cds_email                 AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Customer_customer
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Customer_customer
Return

WSMETHOD CLONE WSCLIENT Customer_customer
	Local oClone := Customer_customer():NEW()
	oClone:cds_code_customer    := ::cds_code_customer
	oClone:cnm_customer         := ::cnm_customer
	oClone:cnr_phone            := ::cnr_phone
	oClone:cds_email            := ::cds_email
	oClone:ccd_company_unit     := ::ccd_company_unit
Return oClone

WSMETHOD SOAPSEND WSCLIENT Customer_customer
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_customer", ::cds_code_customer, ::cds_code_customer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_customer", ::cnm_customer, ::cnm_customer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_phone", ::cnr_phone, ::cnr_phone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_email", ::cds_email, ::cds_email , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


