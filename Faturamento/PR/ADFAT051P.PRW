#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://186.224.100.105:48884/WsGemba/Product.asmx?WSDL
Gerado em        05/13/22 10:52:51
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _THPNOPH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSProduct
------------------------------------------------------------------------------- */

WSCLIENT WSProduct

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Exists
	WSMETHOD Insert

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cds_code_product          AS string
	WSDATA   oWSExistsResult           AS Product_ArrayOfStatus
	WSDATA   oWSproducts               AS Product_ArrayOfProduct
	WSDATA   oWSInsertResult           AS Product_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSProduct
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSProduct
	::oWSExistsResult    := Product_ARRAYOFSTATUS():New()
	::oWSproducts        := Product_ARRAYOFPRODUCT():New()
	::oWSInsertResult    := Product_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSProduct
	::cds_code_product   := NIL 
	::oWSExistsResult    := NIL 
	::oWSproducts        := NIL 
	::oWSInsertResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSProduct
Local oClone := WSProduct():New()
	oClone:_URL          := ::_URL 
	oClone:cds_code_product := ::cds_code_product
	oClone:oWSExistsResult :=  IIF(::oWSExistsResult = NIL , NIL ,::oWSExistsResult:Clone() )
	oClone:oWSproducts   :=  IIF(::oWSproducts = NIL , NIL ,::oWSproducts:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
Return oClone

// WSDL Method Exists of Service WSProduct

WSMETHOD Exists WSSEND cds_code_product WSRECEIVE oWSExistsResult WSCLIENT WSProduct
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Exists xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ds_code_product", ::cds_code_product, cds_code_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Exists>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Exists",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Product.asmx")

::Init()
::oWSExistsResult:SoapRecv( WSAdvValue( oXmlRet,"_EXISTSRESPONSE:_EXISTSRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Insert of Service WSProduct

WSMETHOD Insert WSSEND oWSproducts WSRECEIVE oWSInsertResult WSCLIENT WSProduct
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("products", ::oWSproducts, oWSproducts , "ArrayOfProduct", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Product.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfStatus

WSSTRUCT Product_ArrayOfStatus
	WSDATA   oWSStatus                 AS Product_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Product_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Product_ArrayOfStatus
	::oWSStatus            := {} // Array Of  Product_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT Product_ArrayOfStatus
	Local oClone := Product_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Product_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , Product_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfProduct

WSSTRUCT Product_ArrayOfProduct
	WSDATA   oWSproduct                AS Product_product OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Product_ArrayOfProduct
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Product_ArrayOfProduct
	::oWSproduct           := {} // Array Of  Product_PRODUCT():New()
Return

WSMETHOD CLONE WSCLIENT Product_ArrayOfProduct
	Local oClone := Product_ArrayOfProduct():NEW()
	oClone:oWSproduct := NIL
	If ::oWSproduct <> NIL 
		oClone:oWSproduct := {}
		aEval( ::oWSproduct , { |x| aadd( oClone:oWSproduct , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Product_ArrayOfProduct
	Local cSoap := ""
	aEval( ::oWSproduct , {|x| cSoap := cSoap  +  WSSoapValue("product", x , x , "product", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT Product_Status
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

WSMETHOD NEW WSCLIENT Product_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Product_Status
Return

WSMETHOD CLONE WSCLIENT Product_Status
	Local oClone := Product_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Product_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure product

WSSTRUCT Product_product
	WSDATA   cds_code_product          AS string OPTIONAL
	WSDATA   cnm_product               AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   ctp_product               AS string OPTIONAL
	WSDATA   csg_product               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Product_product
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Product_product
Return

WSMETHOD CLONE WSCLIENT Product_product
	Local oClone := Product_product():NEW()
	oClone:cds_code_product     := ::cds_code_product
	oClone:cnm_product          := ::cnm_product
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:ctp_product          := ::ctp_product
	oClone:csg_product          := ::csg_product
Return oClone

WSMETHOD SOAPSEND WSCLIENT Product_product
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_product", ::cds_code_product, ::cds_code_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_product", ::cnm_product, ::cnm_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("tp_product", ::ctp_product, ::ctp_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sg_product", ::csg_product, ::csg_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap
