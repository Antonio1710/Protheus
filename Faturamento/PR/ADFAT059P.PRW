#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://186.224.100.105:48884/WsGemba/OrderReceiving.asmx?WSDL
Gerado em        19/07/22 11:19:41
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _GCQMPOH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSOrderReceiving
------------------------------------------------------------------------------- */

WSCLIENT WSOrderReceiving

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Insert
	WSMETHOD SetTareWeight

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSordersReceiving        AS OrderReceiving_ArrayOfOrderReceiving
	WSDATA   oWSInsertResult           AS OrderReceiving_ArrayOfStatus
	WSDATA   ccd_company_unit          AS string
	WSDATA   cds_code_receiving        AS string
	WSDATA   cps_tare_quantity         AS string
	WSDATA   oWSSetTareWeightResult    AS OrderReceiving_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSOrderReceiving
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.210324P-20220312] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSOrderReceiving
	::oWSordersReceiving := OrderReceiving_ARRAYOFORDERRECEIVING():New()
	::oWSInsertResult    := OrderReceiving_ARRAYOFSTATUS():New()
	::oWSSetTareWeightResult := OrderReceiving_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSOrderReceiving
	::oWSordersReceiving := NIL 
	::oWSInsertResult    := NIL 
	::ccd_company_unit   := NIL 
	::cds_code_receiving := NIL 
	::cps_tare_quantity  := NIL 
	::oWSSetTareWeightResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSOrderReceiving
Local oClone := WSOrderReceiving():New()
	oClone:_URL          := ::_URL 
	oClone:oWSordersReceiving :=  IIF(::oWSordersReceiving = NIL , NIL ,::oWSordersReceiving:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
	oClone:ccd_company_unit := ::ccd_company_unit
	oClone:cds_code_receiving := ::cds_code_receiving
	oClone:cps_tare_quantity := ::cps_tare_quantity
	oClone:oWSSetTareWeightResult :=  IIF(::oWSSetTareWeightResult = NIL , NIL ,::oWSSetTareWeightResult:Clone() )
Return oClone

// WSDL Method Insert of Service WSOrderReceiving

WSMETHOD Insert WSSEND oWSordersReceiving WSRECEIVE oWSInsertResult WSCLIENT WSOrderReceiving
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ordersReceiving", ::oWSordersReceiving, oWSordersReceiving , "ArrayOfOrderReceiving", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/OrderReceiving.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SetTareWeight of Service WSOrderReceiving

WSMETHOD SetTareWeight WSSEND ccd_company_unit,cds_code_receiving,cps_tare_quantity WSRECEIVE oWSSetTareWeightResult WSCLIENT WSOrderReceiving
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SetTareWeight xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ds_code_receiving", ::cds_code_receiving, cds_code_receiving , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ps_tare_quantity", ::cps_tare_quantity, cps_tare_quantity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SetTareWeight>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/SetTareWeight",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/OrderReceiving.asmx")

::Init()
::oWSSetTareWeightResult:SoapRecv( WSAdvValue( oXmlRet,"_SETTAREWEIGHTRESPONSE:_SETTAREWEIGHTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfOrderReceiving

WSSTRUCT OrderReceiving_ArrayOfOrderReceiving
	WSDATA   oWSorderReceiving         AS OrderReceiving_orderReceiving OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderReceiving_ArrayOfOrderReceiving
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderReceiving_ArrayOfOrderReceiving
	::oWSorderReceiving    := {} // Array Of  OrderReceiving_ORDERRECEIVING():New()
Return

WSMETHOD CLONE WSCLIENT OrderReceiving_ArrayOfOrderReceiving
	Local oClone := OrderReceiving_ArrayOfOrderReceiving():NEW()
	oClone:oWSorderReceiving := NIL
	If ::oWSorderReceiving <> NIL 
		oClone:oWSorderReceiving := {}
		aEval( ::oWSorderReceiving , { |x| aadd( oClone:oWSorderReceiving , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderReceiving_ArrayOfOrderReceiving
	Local cSoap := ""
	aEval( ::oWSorderReceiving , {|x| cSoap := cSoap  +  WSSoapValue("orderReceiving", x , x , "orderReceiving", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStatus

WSSTRUCT OrderReceiving_ArrayOfStatus
	WSDATA   oWSStatus                 AS OrderReceiving_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderReceiving_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderReceiving_ArrayOfStatus
	::oWSStatus            := {} // Array Of  OrderReceiving_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT OrderReceiving_ArrayOfStatus
	Local oClone := OrderReceiving_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderReceiving_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , OrderReceiving_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure orderReceiving

WSSTRUCT OrderReceiving_orderReceiving
	WSDATA   cds_code_receiving        AS string OPTIONAL
	WSDATA   cnr_plate                 AS string OPTIONAL
	WSDATA   cnm_driver                AS string OPTIONAL
	WSDATA   cvl_document_number       AS string OPTIONAL
	WSDATA   cds_code_supplier         AS string OPTIONAL
	WSDATA   cds_code_product          AS string OPTIONAL
	WSDATA   cps_nominal_quantity      AS string OPTIONAL
	WSDATA   cps_brute_quantity        AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   cdt_validity              AS string OPTIONAL
	WSDATA   cdt_manufacture           AS string OPTIONAL
	WSDATA   ctp_product_receiving     AS string OPTIONAL
	WSDATA   cnr_lot                   AS string OPTIONAL
	WSDATA   cds_observation           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT OrderReceiving_orderReceiving
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderReceiving_orderReceiving
Return

WSMETHOD CLONE WSCLIENT OrderReceiving_orderReceiving
	Local oClone := OrderReceiving_orderReceiving():NEW()
	oClone:cds_code_receiving   := ::cds_code_receiving
	oClone:cnr_plate            := ::cnr_plate
	oClone:cnm_driver           := ::cnm_driver
	oClone:cvl_document_number  := ::cvl_document_number
	oClone:cds_code_supplier    := ::cds_code_supplier
	oClone:cds_code_product     := ::cds_code_product
	oClone:cps_nominal_quantity := ::cps_nominal_quantity
	oClone:cps_brute_quantity   := ::cps_brute_quantity
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:cdt_validity         := ::cdt_validity
	oClone:cdt_manufacture      := ::cdt_manufacture
	oClone:ctp_product_receiving := ::ctp_product_receiving
	oClone:cnr_lot              := ::cnr_lot
	oClone:cds_observation      := ::cds_observation
Return oClone

WSMETHOD SOAPSEND WSCLIENT OrderReceiving_orderReceiving
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_receiving", ::cds_code_receiving, ::cds_code_receiving , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_plate", ::cnr_plate, ::cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_driver", ::cnm_driver, ::cnm_driver , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("vl_document_number", ::cvl_document_number, ::cvl_document_number , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_supplier", ::cds_code_supplier, ::cds_code_supplier , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_code_product", ::cds_code_product, ::cds_code_product , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ps_nominal_quantity", ::cps_nominal_quantity, ::cps_nominal_quantity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ps_brute_quantity", ::cps_brute_quantity, ::cps_brute_quantity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dt_validity", ::cdt_validity, ::cdt_validity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("dt_manufacture", ::cdt_manufacture, ::cdt_manufacture , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("tp_product_receiving", ::ctp_product_receiving, ::ctp_product_receiving , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_lot", ::cnr_lot, ::cnr_lot , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_observation", ::cds_observation, ::cds_observation , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT OrderReceiving_Status
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

WSMETHOD NEW WSCLIENT OrderReceiving_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT OrderReceiving_Status
Return

WSMETHOD CLONE WSCLIENT OrderReceiving_Status
	Local oClone := OrderReceiving_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT OrderReceiving_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return
