#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://apks-app-adoro.s3.us-east-2.amazonaws.com/LoadingDelivered.wsdl
Gerado em        05/10/22 14:39:12
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _RTZACNL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLoadingDelivered
------------------------------------------------------------------------------- */

WSCLIENT WSLoadingDelivered

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD SetDelivered
	WSMETHOD GetLotExpedition

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSloading                AS LoadingDelivered_loading
	WSDATA   oWSSetDeliveredResult     AS LoadingDelivered_ArrayOfStatus
	WSDATA   oWSlotExpedition          AS LoadingDelivered_lotExpedition
	WSDATA   oWSGetLotExpeditionResult AS LoadingDelivered_ArrayOfLotsExpedition

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLoadingDelivered
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLoadingDelivered
	::oWSloading         := LoadingDelivered_LOADING():New()
	::oWSSetDeliveredResult := LoadingDelivered_ARRAYOFSTATUS():New()
	::oWSlotExpedition   := LoadingDelivered_LOTEXPEDITION():New()
	::oWSGetLotExpeditionResult := LoadingDelivered_ARRAYOFLOTSEXPEDITION():New()
Return

WSMETHOD RESET WSCLIENT WSLoadingDelivered
	::oWSloading         := NIL 
	::oWSSetDeliveredResult := NIL 
	::oWSlotExpedition   := NIL 
	::oWSGetLotExpeditionResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLoadingDelivered
Local oClone := WSLoadingDelivered():New()
	oClone:_URL          := ::_URL 
	oClone:oWSloading    :=  IIF(::oWSloading = NIL , NIL ,::oWSloading:Clone() )
	oClone:oWSSetDeliveredResult :=  IIF(::oWSSetDeliveredResult = NIL , NIL ,::oWSSetDeliveredResult:Clone() )
	oClone:oWSlotExpedition :=  IIF(::oWSlotExpedition = NIL , NIL ,::oWSlotExpedition:Clone() )
	oClone:oWSGetLotExpeditionResult :=  IIF(::oWSGetLotExpeditionResult = NIL , NIL ,::oWSGetLotExpeditionResult:Clone() )
Return oClone

// WSDL Method SetDelivered of Service WSLoadingDelivered

WSMETHOD SetDelivered WSSEND oWSloading WSRECEIVE oWSSetDeliveredResult WSCLIENT WSLoadingDelivered
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SetDelivered xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("loading", ::oWSloading, oWSloading , "loading", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SetDelivered>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/SetDelivered",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/LoadingDelivered.asmx")

::Init()
::oWSSetDeliveredResult:SoapRecv( WSAdvValue( oXmlRet,"_SETDELIVEREDRESPONSE:_SETDELIVEREDRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GetLotExpedition of Service WSLoadingDelivered

WSMETHOD GetLotExpedition WSSEND oWSlotExpedition WSRECEIVE oWSGetLotExpeditionResult WSCLIENT WSLoadingDelivered
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GetLotExpedition xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("lotExpedition", ::oWSlotExpedition, oWSlotExpedition , "lotExpedition", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GetLotExpedition>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/GetLotExpedition",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/LoadingDelivered.asmx")

::Init()
::oWSGetLotExpeditionResult:SoapRecv( WSAdvValue( oXmlRet,"_GETLOTEXPEDITIONRESPONSE:_GETLOTEXPEDITIONRESULT","ArrayOfLotsExpedition",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure loading

WSSTRUCT LoadingDelivered_loading
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   cds_code_order_loading    AS string OPTIONAL
	WSDATA   cnr_bill_request          AS string OPTIONAL
	WSDATA   cps_delivered             AS string OPTIONAL
	WSDATA   ctp_status                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_loading
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_loading
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_loading
	Local oClone := LoadingDelivered_loading():NEW()
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_bill_request     := ::cnr_bill_request
	oClone:cps_delivered        := ::cps_delivered
	oClone:ctp_status           := ::ctp_status
Return oClone

WSMETHOD SOAPSEND WSCLIENT LoadingDelivered_loading
	Local cSoap := ""
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_order_loading", ::cds_code_order_loading, ::cds_code_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_bill_request", ::cnr_bill_request, ::cnr_bill_request , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ps_delivered", ::cps_delivered, ::cps_delivered , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("tp_status", ::ctp_status, ::ctp_status , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfStatus

WSSTRUCT LoadingDelivered_ArrayOfStatus
	WSDATA   oWSStatus                 AS LoadingDelivered_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_ArrayOfStatus
	::oWSStatus            := {} // Array Of  LoadingDelivered_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_ArrayOfStatus
	Local oClone := LoadingDelivered_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , LoadingDelivered_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure lotExpedition

WSSTRUCT LoadingDelivered_lotExpedition
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   cds_code_order_loading    AS string OPTIONAL
	WSDATA   cnr_bill_request          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_lotExpedition
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_lotExpedition
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_lotExpedition
	Local oClone := LoadingDelivered_lotExpedition():NEW()
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_bill_request     := ::cnr_bill_request
Return oClone

WSMETHOD SOAPSEND WSCLIENT LoadingDelivered_lotExpedition
	Local cSoap := ""
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_order_loading", ::cds_code_order_loading, ::cds_code_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_bill_request", ::cnr_bill_request, ::cnr_bill_request , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfLotsExpedition

WSSTRUCT LoadingDelivered_ArrayOfLotsExpedition
	WSDATA   oWSlotsExpedition         AS LoadingDelivered_lotsExpedition OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_ArrayOfLotsExpedition
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_ArrayOfLotsExpedition
	::oWSlotsExpedition    := {} // Array Of  LoadingDelivered_LOTSEXPEDITION():New()
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_ArrayOfLotsExpedition
	Local oClone := LoadingDelivered_ArrayOfLotsExpedition():NEW()
	oClone:oWSlotsExpedition := NIL
	If ::oWSlotsExpedition <> NIL 
		oClone:oWSlotsExpedition := {}
		aEval( ::oWSlotsExpedition , { |x| aadd( oClone:oWSlotsExpedition , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_ArrayOfLotsExpedition
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOTSEXPEDITION","lotsExpedition",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSlotsExpedition , LoadingDelivered_lotsExpedition():New() )
			::oWSlotsExpedition[len(::oWSlotsExpedition)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure Status

WSSTRUCT LoadingDelivered_Status
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

WSMETHOD NEW WSCLIENT LoadingDelivered_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_Status
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_Status
	Local oClone := LoadingDelivered_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure lotsExpedition

WSSTRUCT LoadingDelivered_lotsExpedition
	WSDATA   cds_code_order_loading    AS string OPTIONAL
	WSDATA   cnr_bill_request          AS string OPTIONAL
	WSDATA   cds_code_product          AS string OPTIONAL
	WSDATA   cps_delivered             AS string OPTIONAL
	WSDATA   cdt_order_loading_initial AS string OPTIONAL
	WSDATA   cdt_order_loading_final   AS string OPTIONAL
	WSDATA   oWSlots                   AS LoadingDelivered_ArrayOfLot OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_lotsExpedition
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_lotsExpedition
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_lotsExpedition
	Local oClone := LoadingDelivered_lotsExpedition():NEW()
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_bill_request     := ::cnr_bill_request
	oClone:cds_code_product     := ::cds_code_product
	oClone:cps_delivered        := ::cps_delivered
	oClone:cdt_order_loading_initial := ::cdt_order_loading_initial
	oClone:cdt_order_loading_final := ::cdt_order_loading_final
	oClone:oWSlots              := IIF(::oWSlots = NIL , NIL , ::oWSlots:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_lotsExpedition
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cds_code_order_loading :=  WSAdvValue( oResponse,"_DS_CODE_ORDER_LOADING","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnr_bill_request   :=  WSAdvValue( oResponse,"_NR_BILL_REQUEST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cds_code_product   :=  WSAdvValue( oResponse,"_DS_CODE_PRODUCT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cps_delivered      :=  WSAdvValue( oResponse,"_PS_DELIVERED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdt_order_loading_initial :=  WSAdvValue( oResponse,"_DT_ORDER_LOADING_INITIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdt_order_loading_final :=  WSAdvValue( oResponse,"_DT_ORDER_LOADING_FINAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_LOTS","ArrayOfLot",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSlots := LoadingDelivered_ArrayOfLot():New()
		::oWSlots:SoapRecv(oNode7)
	EndIf
Return

// WSDL Data Structure ArrayOfLot

WSSTRUCT LoadingDelivered_ArrayOfLot
	WSDATA   oWSlot                    AS LoadingDelivered_lot OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_ArrayOfLot
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_ArrayOfLot
	::oWSlot               := {} // Array Of  LoadingDelivered_LOT():New()
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_ArrayOfLot
	Local oClone := LoadingDelivered_ArrayOfLot():NEW()
	oClone:oWSlot := NIL
	If ::oWSlot <> NIL 
		oClone:oWSlot := {}
		aEval( ::oWSlot , { |x| aadd( oClone:oWSlot , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_ArrayOfLot
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOT","lot",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSlot , LoadingDelivered_lot():New() )
			::oWSlot[len(::oWSlot)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure lot

WSSTRUCT LoadingDelivered_lot
	WSDATA   cds_code_order_production AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT LoadingDelivered_lot
	::Init()
Return Self

WSMETHOD INIT WSCLIENT LoadingDelivered_lot
Return

WSMETHOD CLONE WSCLIENT LoadingDelivered_lot
	Local oClone := LoadingDelivered_lot():NEW()
	oClone:cds_code_order_production := ::cds_code_order_production
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT LoadingDelivered_lot
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cds_code_order_production :=  WSAdvValue( oResponse,"_DS_CODE_ORDER_PRODUCTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


