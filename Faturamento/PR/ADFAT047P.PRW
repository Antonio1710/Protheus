#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://apks-app-adoro.s3.us-east-2.amazonaws.com/Loading.wsdl
Gerado em        05/10/22 14:37:49
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _MTSRGZG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSLoading
------------------------------------------------------------------------------- */

WSCLIENT WSLoading

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Get

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ccd_company_unit          AS string
	WSDATA   cds_code_order_loading    AS string
	WSDATA   cnr_bill_request          AS string
	WSDATA   oWSGetResult              AS Loading_ArrayOfLoading

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSLoading
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSLoading
	::oWSGetResult       := Loading_ARRAYOFLOADING():New()
Return

WSMETHOD RESET WSCLIENT WSLoading
	::ccd_company_unit   := NIL 
	::cds_code_order_loading := NIL 
	::cnr_bill_request   := NIL 
	::oWSGetResult       := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSLoading
Local oClone := WSLoading():New()
	oClone:_URL          := ::_URL 
	oClone:ccd_company_unit := ::ccd_company_unit
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_bill_request := ::cnr_bill_request
	oClone:oWSGetResult  :=  IIF(::oWSGetResult = NIL , NIL ,::oWSGetResult:Clone() )
Return oClone

// WSDL Method Get of Service WSLoading

WSMETHOD Get WSSEND ccd_company_unit,cds_code_order_loading,cnr_bill_request WSRECEIVE oWSGetResult WSCLIENT WSLoading
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Get xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ds_code_order_loading", ::cds_code_order_loading, cds_code_order_loading , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nr_bill_request", ::cnr_bill_request, cnr_bill_request , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Get>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Get",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Loading.asmx")

::Init()
::oWSGetResult:SoapRecv( WSAdvValue( oXmlRet,"_GETRESPONSE:_GETRESULT","ArrayOfLoading",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfLoading

WSSTRUCT Loading_ArrayOfLoading
	WSDATA   oWSloading                AS Loading_loading OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Loading_ArrayOfLoading
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Loading_ArrayOfLoading
	::oWSloading           := {} // Array Of  Loading_LOADING():New()
Return

WSMETHOD CLONE WSCLIENT Loading_ArrayOfLoading
	Local oClone := Loading_ArrayOfLoading():NEW()
	oClone:oWSloading := NIL
	If ::oWSloading <> NIL 
		oClone:oWSloading := {}
		aEval( ::oWSloading , { |x| aadd( oClone:oWSloading , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Loading_ArrayOfLoading
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOADING","loading",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSloading , Loading_loading():New() )
			::oWSloading[len(::oWSloading)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure loading

WSSTRUCT Loading_loading
	WSDATA   cds_code_order_loading    AS string OPTIONAL
	WSDATA   cnr_bill_request          AS string OPTIONAL
	WSDATA   cnr_plate                 AS string OPTIONAL
	WSDATA   cds_code_customer         AS string OPTIONAL
	WSDATA   cds_code_shed             AS string OPTIONAL
	WSDATA   cds_seal                  AS string OPTIONAL
	WSDATA   oWSdetails                AS Loading_ArrayOfLoadingDetail OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Loading_loading
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Loading_loading
Return

WSMETHOD CLONE WSCLIENT Loading_loading
	Local oClone := Loading_loading():NEW()
	oClone:cds_code_order_loading := ::cds_code_order_loading
	oClone:cnr_bill_request     := ::cnr_bill_request
	oClone:cnr_plate            := ::cnr_plate
	oClone:cds_code_customer    := ::cds_code_customer
	oClone:cds_code_shed        := ::cds_code_shed
	oClone:cds_seal             := ::cds_seal
	oClone:oWSdetails           := IIF(::oWSdetails = NIL , NIL , ::oWSdetails:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Loading_loading
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cds_code_order_loading :=  WSAdvValue( oResponse,"_DS_CODE_ORDER_LOADING","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnr_bill_request   :=  WSAdvValue( oResponse,"_NR_BILL_REQUEST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnr_plate          :=  WSAdvValue( oResponse,"_NR_PLATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cds_code_customer  :=  WSAdvValue( oResponse,"_DS_CODE_CUSTOMER","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cds_code_shed      :=  WSAdvValue( oResponse,"_DS_CODE_SHED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cds_seal           :=  WSAdvValue( oResponse,"_DS_SEAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_DETAILS","ArrayOfLoadingDetail",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode7 != NIL
		::oWSdetails := Loading_ArrayOfLoadingDetail():New()
		::oWSdetails:SoapRecv(oNode7)
	EndIf
Return

// WSDL Data Structure ArrayOfLoadingDetail

WSSTRUCT Loading_ArrayOfLoadingDetail
	WSDATA   oWSloadingDetail          AS Loading_loadingDetail OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Loading_ArrayOfLoadingDetail
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Loading_ArrayOfLoadingDetail
	::oWSloadingDetail     := {} // Array Of  Loading_LOADINGDETAIL():New()
Return

WSMETHOD CLONE WSCLIENT Loading_ArrayOfLoadingDetail
	Local oClone := Loading_ArrayOfLoadingDetail():NEW()
	oClone:oWSloadingDetail := NIL
	If ::oWSloadingDetail <> NIL 
		oClone:oWSloadingDetail := {}
		aEval( ::oWSloadingDetail , { |x| aadd( oClone:oWSloadingDetail , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Loading_ArrayOfLoadingDetail
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOADINGDETAIL","loadingDetail",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSloadingDetail , Loading_loadingDetail():New() )
			::oWSloadingDetail[len(::oWSloadingDetail)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure loadingDetail

WSSTRUCT Loading_loadingDetail
	WSDATA   cds_code_product          AS string OPTIONAL
	WSDATA   cps_slide                 AS string OPTIONAL
	WSDATA   cnm_silo                  AS string OPTIONAL
	WSDATA   cds_box                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Loading_loadingDetail
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Loading_loadingDetail
Return

WSMETHOD CLONE WSCLIENT Loading_loadingDetail
	Local oClone := Loading_loadingDetail():NEW()
	oClone:cds_code_product     := ::cds_code_product
	oClone:cps_slide            := ::cps_slide
	oClone:cnm_silo             := ::cnm_silo
	oClone:cds_box              := ::cds_box
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Loading_loadingDetail
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cds_code_product   :=  WSAdvValue( oResponse,"_DS_CODE_PRODUCT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cps_slide          :=  WSAdvValue( oResponse,"_PS_SLIDE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cnm_silo           :=  WSAdvValue( oResponse,"_NM_SILO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cds_box            :=  WSAdvValue( oResponse,"_DS_BOX","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


