#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://apks-app-adoro.s3.us-east-2.amazonaws.com/OrderLoading.wsdl
Gerado em        05/10/22 14:35:37
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _MMOJGMO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSOrderLoading
------------------------------------------------------------------------------- */

WSCLIENT WSOrderLoading

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Insert
	WSMETHOD Update
	WSMETHOD Delete

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSordersLoading          AS OrderLoading_ArrayOfOrderLoading
	WSDATA   oWSInsertResult           AS OrderLoading_ArrayOfStatus
	WSDATA   cds_code_order_loading    AS string
	WSDATA   cnr_plate                 AS string
	WSDATA   oWSUpdateResult           AS OrderLoading_ArrayOfStatus
	WSDATA   cnr_bill_request          AS string
	WSDATA   oWSDeleteResult           AS OrderLoading_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSOrderLoading
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSOrderLoading
	::oWSordersLoading   := OrderLoading_ARRAYOFORDERLOADING():New()
	::oWSInsertResult    := OrderLoading_ARRAYOFSTATUS():New()
	::oWSUpdateResult    := OrderLoading_ARRAYOFSTATUS():New()
	::oWSDeleteResult    := OrderLoading_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSOrderLoading
	::oWSordersLoading   := NIL 
	::oWSInsertResult    := NIL 
	::cds_code_order_loading := NIL 
	::cnr_plate          := NIL 
	::oWSUpdateResult    := NIL 
	::cnr_bill_request   := NIL 
	::oWSDeleteResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSOrderLoading
Local oClone := WSOrderLoading():New()
	oClone:_URL          := ::_URL 
	oClone:oWSordersLoading :=  IIF(::oWSordersLoading = NIL , NIL ,::oWSordersLoading:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_plate     := ::cnr_plate
	oClone:oWSUpdateResult :=  IIF(::oWSUpdateResult = NIL , NIL ,::oWSUpdateResult:Clone() )
	oClone:cnr_bill_request := ::cnr_bill_request
	oClone:oWSDeleteResult :=  IIF(::oWSDeleteResult = NIL , NIL ,::oWSDeleteResult:Clone() )
Return oClone

// WSDL Method Insert of Service WSOrderLoading

WSMETHOD Insert WSSEND oWSordersLoading WSRECEIVE oWSInsertResult WSCLIENT WSOrderLoading
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ordersLoading", ::oWSordersLoading, oWSordersLoading , "ArrayOfOrderLoading", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/OrderLoading.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Update of Service WSOrderLoading

WSMETHOD Update WSSEND cds_code_order_loading,cnr_plate WSRECEIVE oWSUpdateResult WSCLIENT WSOrderLoading
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Update xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ds_code_order_loading", ::cds_code_order_loading, cds_code_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nr_plate", ::cnr_plate, cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Update>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Update",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/OrderLoading.asmx")

::Init()
::oWSUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_UPDATERESPONSE:_UPDATERESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Delete of Service WSOrderLoading

WSMETHOD Delete WSSEND cnr_bill_request WSRECEIVE oWSDeleteResult WSCLIENT WSOrderLoading
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Delete xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("nr_bill_request", ::cnr_bill_request, cnr_bill_request , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Delete>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Delete",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/OrderLoading.asmx")

::Init()
::oWSDeleteResult:SoapRecv( WSAdvValue( oXmlRet,"_DELETERESPONSE:_DELETERESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfOrderLoading

WSSTRUCT OrderLoading_ArrayOfOrderLoading
	WSDATA   oWSorderLoading           AS OrderLoading_orderLoading OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderLoading_ArrayOfOrderLoading
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_ArrayOfOrderLoading
	::oWSorderLoading      := {} // Array Of  OrderLoading_ORDERLOADING():New()
Return

WSMETHOD CLONE WSCLIENT OrderLoading_ArrayOfOrderLoading
	Local oClone := OrderLoading_ArrayOfOrderLoading():NEW()
	oClone:oWSorderLoading := NIL
	If ::oWSorderLoading <> NIL 
		oClone:oWSorderLoading := {}
		aEval( ::oWSorderLoading , { |x| aadd( oClone:oWSorderLoading , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderLoading_ArrayOfOrderLoading
	Local cSoap := ""
	aEval( ::oWSorderLoading , {|x| cSoap := cSoap  +  WSSoapValue("orderLoading", x , x , "orderLoading", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStatus

WSSTRUCT OrderLoading_ArrayOfStatus
	WSDATA   oWSStatus                 AS OrderLoading_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderLoading_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_ArrayOfStatus
	::oWSStatus            := {} // Array Of  OrderLoading_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT OrderLoading_ArrayOfStatus
	Local oClone := OrderLoading_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderLoading_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , OrderLoading_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure orderLoading

WSSTRUCT OrderLoading_orderLoading
	WSDATA   cds_code_order_loading    AS string OPTIONAL
	WSDATA   cdt_order_loading         AS string OPTIONAL
	WSDATA   cnr_plate                 AS string OPTIONAL
	WSDATA   cnm_driver                AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   oWSdetails                AS OrderLoading_ArrayOfOrderLoadingDetail OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderLoading_orderLoading
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_orderLoading
Return

WSMETHOD CLONE WSCLIENT OrderLoading_orderLoading
	Local oClone := OrderLoading_orderLoading():NEW()
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cdt_order_loading    := ::cdt_order_loading
	oClone:cnr_plate            := ::cnr_plate
	oClone:cnm_driver           := ::cnm_driver
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:oWSdetails           := IIF(::oWSdetails = NIL , NIL , ::oWSdetails:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderLoading_orderLoading
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_order_loading", ::cds_code_order_loading, ::cds_code_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dt_order_loading", ::cdt_order_loading, ::cdt_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_plate", ::cnr_plate, ::cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_driver", ::cnm_driver, ::cnm_driver , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("details", ::oWSdetails, ::oWSdetails , "ArrayOfOrderLoadingDetail", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT OrderLoading_Status
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

WSMETHOD NEW WSCLIENT OrderLoading_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_Status
Return

WSMETHOD CLONE WSCLIENT OrderLoading_Status
	Local oClone := OrderLoading_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderLoading_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfOrderLoadingDetail

WSSTRUCT OrderLoading_ArrayOfOrderLoadingDetail
	WSDATA   oWSorderLoadingDetail     AS OrderLoading_orderLoadingDetail OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderLoading_ArrayOfOrderLoadingDetail
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_ArrayOfOrderLoadingDetail
	::oWSorderLoadingDetail := {} // Array Of  OrderLoading_ORDERLOADINGDETAIL():New()
Return

WSMETHOD CLONE WSCLIENT OrderLoading_ArrayOfOrderLoadingDetail
	Local oClone := OrderLoading_ArrayOfOrderLoadingDetail():NEW()
	oClone:oWSorderLoadingDetail := NIL
	If ::oWSorderLoadingDetail <> NIL 
		oClone:oWSorderLoadingDetail := {}
		aEval( ::oWSorderLoadingDetail , { |x| aadd( oClone:oWSorderLoadingDetail , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderLoading_ArrayOfOrderLoadingDetail
	Local cSoap := ""
	aEval( ::oWSorderLoadingDetail , {|x| cSoap := cSoap  +  WSSoapValue("orderLoadingDetail", x , x , "orderLoadingDetail", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure orderLoadingDetail

WSSTRUCT OrderLoading_orderLoadingDetail
	WSDATA   cnr_bill_request          AS string OPTIONAL
	WSDATA   cds_code_product          AS string OPTIONAL
	WSDATA   cds_code_customer         AS string OPTIONAL
	WSDATA   cds_code_shed             AS string OPTIONAL
	WSDATA   cps_slide                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderLoading_orderLoadingDetail
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderLoading_orderLoadingDetail
Return

WSMETHOD CLONE WSCLIENT OrderLoading_orderLoadingDetail
	Local oClone := OrderLoading_orderLoadingDetail():NEW()
	oClone:cnr_bill_request     := ::cnr_bill_request
	oClone:cds_code_product     := ::cds_code_product
	oClone:cds_code_customer    := ::cds_code_customer
	oClone:cds_code_shed        := ::cds_code_shed
	oClone:cps_slide            := ::cps_slide
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderLoading_orderLoadingDetail
	Local cSoap := ""
	cSoap += WSSoapValue("nr_bill_request", ::cnr_bill_request, ::cnr_bill_request , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_product", ::cds_code_product, ::cds_code_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_customer", ::cds_code_customer, ::cds_code_customer , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_shed", ::cds_code_shed, ::cds_code_shed , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ps_slide", ::cps_slide, ::cps_slide , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


