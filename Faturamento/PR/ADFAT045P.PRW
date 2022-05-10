#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://apks-app-adoro.s3.us-east-2.amazonaws.com/Truck.wsdl
Gerado em        05/10/22 13:49:28
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _FJWUNLG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTruck
------------------------------------------------------------------------------- */

WSCLIENT WSTruck

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Exists
	WSMETHOD Update
	WSMETHOD Insert
	WSMETHOD Activate
	WSMETHOD Deactivate

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cnr_plate                 AS string
	WSDATA   oWSExistsResult           AS Truck_ArrayOfStatus
	WSDATA   cds_code_truck            AS string
	WSDATA   cnm_driver                AS string
	WSDATA   oWSUpdateResult           AS Truck_ArrayOfStatus
	WSDATA   oWStrucks                 AS Truck_ArrayOfTruck
	WSDATA   oWSInsertResult           AS Truck_ArrayOfStatus
	WSDATA   oWSActivateResult         AS Truck_ArrayOfStatus
	WSDATA   oWSDeactivateResult       AS Truck_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTruck
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20211019] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTruck
	::oWSExistsResult    := Truck_ARRAYOFSTATUS():New()
	::oWSUpdateResult    := Truck_ARRAYOFSTATUS():New()
	::oWStrucks          := Truck_ARRAYOFTRUCK():New()
	::oWSInsertResult    := Truck_ARRAYOFSTATUS():New()
	::oWSActivateResult  := Truck_ARRAYOFSTATUS():New()
	::oWSDeactivateResult := Truck_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSTruck
	::cnr_plate          := NIL 
	::oWSExistsResult    := NIL 
	::cds_code_truck     := NIL 
	::cnm_driver         := NIL 
	::oWSUpdateResult    := NIL 
	::oWStrucks          := NIL 
	::oWSInsertResult    := NIL 
	::oWSActivateResult  := NIL 
	::oWSDeactivateResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTruck
Local oClone := WSTruck():New()
	oClone:_URL          := ::_URL 
	oClone:cnr_plate     := ::cnr_plate
	oClone:oWSExistsResult :=  IIF(::oWSExistsResult = NIL , NIL ,::oWSExistsResult:Clone() )
	oClone:cds_code_truck := ::cds_code_truck
	oClone:cnm_driver    := ::cnm_driver
	oClone:oWSUpdateResult :=  IIF(::oWSUpdateResult = NIL , NIL ,::oWSUpdateResult:Clone() )
	oClone:oWStrucks     :=  IIF(::oWStrucks = NIL , NIL ,::oWStrucks:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
	oClone:oWSActivateResult :=  IIF(::oWSActivateResult = NIL , NIL ,::oWSActivateResult:Clone() )
	oClone:oWSDeactivateResult :=  IIF(::oWSDeactivateResult = NIL , NIL ,::oWSDeactivateResult:Clone() )
Return oClone

// WSDL Method Exists of Service WSTruck

WSMETHOD Exists WSSEND cnr_plate WSRECEIVE oWSExistsResult WSCLIENT WSTruck
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Exists xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("nr_plate", ::cnr_plate, cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Exists>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Exists",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Truck.asmx")

::Init()
::oWSExistsResult:SoapRecv( WSAdvValue( oXmlRet,"_EXISTSRESPONSE:_EXISTSRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Update of Service WSTruck

WSMETHOD Update WSSEND cds_code_truck,cnr_plate,cnm_driver WSRECEIVE oWSUpdateResult WSCLIENT WSTruck
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Update xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ds_code_truck", ::cds_code_truck, cds_code_truck , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nr_plate", ::cnr_plate, cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("nm_driver", ::cnm_driver, cnm_driver , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Update>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Update",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Truck.asmx")

::Init()
::oWSUpdateResult:SoapRecv( WSAdvValue( oXmlRet,"_UPDATERESPONSE:_UPDATERESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Insert of Service WSTruck

WSMETHOD Insert WSSEND oWStrucks WSRECEIVE oWSInsertResult WSCLIENT WSTruck
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("trucks", ::oWStrucks, oWStrucks , "ArrayOfTruck", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Truck.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Activate of Service WSTruck

WSMETHOD Activate WSSEND cnr_plate WSRECEIVE oWSActivateResult WSCLIENT WSTruck
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Activate xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("nr_plate", ::cnr_plate, cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Activate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Activate",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Truck.asmx")

::Init()
::oWSActivateResult:SoapRecv( WSAdvValue( oXmlRet,"_ACTIVATERESPONSE:_ACTIVATERESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Deactivate of Service WSTruck

WSMETHOD Deactivate WSSEND cnr_plate WSRECEIVE oWSDeactivateResult WSCLIENT WSTruck
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Deactivate xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("nr_plate", ::cnr_plate, cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Deactivate>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Deactivate",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://localhost:4901/Truck.asmx")

::Init()
::oWSDeactivateResult:SoapRecv( WSAdvValue( oXmlRet,"_DEACTIVATERESPONSE:_DEACTIVATERESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfStatus

WSSTRUCT Truck_ArrayOfStatus
	WSDATA   oWSStatus                 AS Truck_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Truck_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_ArrayOfStatus
	::oWSStatus            := {} // Array Of  Truck_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT Truck_ArrayOfStatus
	Local oClone := Truck_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Truck_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , Truck_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfTruck

WSSTRUCT Truck_ArrayOfTruck
	WSDATA   oWStruck                  AS Truck_truck OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Truck_ArrayOfTruck
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_ArrayOfTruck
	::oWStruck             := {} // Array Of  Truck_TRUCK():New()
Return

WSMETHOD CLONE WSCLIENT Truck_ArrayOfTruck
	Local oClone := Truck_ArrayOfTruck():NEW()
	oClone:oWStruck := NIL
	If ::oWStruck <> NIL 
		oClone:oWStruck := {}
		aEval( ::oWStruck , { |x| aadd( oClone:oWStruck , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Truck_ArrayOfTruck
	Local cSoap := ""
	aEval( ::oWStruck , {|x| cSoap := cSoap  +  WSSoapValue("truck", x , x , "truck", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT Truck_Status
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

WSMETHOD NEW WSCLIENT Truck_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_Status
Return

WSMETHOD CLONE WSCLIENT Truck_Status
	Local oClone := Truck_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Truck_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure truck

WSSTRUCT Truck_truck
	WSDATA   cds_code_truck            AS string OPTIONAL
	WSDATA   cnr_plate                 AS string OPTIONAL
	WSDATA   cnm_driver                AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSDATA   oWSboxes                  AS Truck_ArrayOfBox OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Truck_truck
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_truck
Return

WSMETHOD CLONE WSCLIENT Truck_truck
	Local oClone := Truck_truck():NEW()
	oClone:cds_code_truck       := ::cds_code_truck
	oClone:cnr_plate            := ::cnr_plate
	oClone:cnm_driver           := ::cnm_driver
	oClone:ccd_company_unit     := ::ccd_company_unit
	oClone:oWSboxes             := IIF(::oWSboxes = NIL , NIL , ::oWSboxes:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT Truck_truck
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_truck", ::cds_code_truck, ::cds_code_truck , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_plate", ::cnr_plate, ::cnr_plate , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_driver", ::cnm_driver, ::cnm_driver , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("boxes", ::oWSboxes, ::oWSboxes , "ArrayOfBox", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ArrayOfBox

WSSTRUCT Truck_ArrayOfBox
	WSDATA   oWSbox                    AS Truck_box OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Truck_ArrayOfBox
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_ArrayOfBox
	::oWSbox               := {} // Array Of  Truck_BOX():New()
Return

WSMETHOD CLONE WSCLIENT Truck_ArrayOfBox
	Local oClone := Truck_ArrayOfBox():NEW()
	oClone:oWSbox := NIL
	If ::oWSbox <> NIL 
		oClone:oWSbox := {}
		aEval( ::oWSbox , { |x| aadd( oClone:oWSbox , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Truck_ArrayOfBox
	Local cSoap := ""
	aEval( ::oWSbox , {|x| cSoap := cSoap  +  WSSoapValue("box", x , x , "box", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure box

WSSTRUCT Truck_box
	WSDATA   cnr_box                   AS string OPTIONAL
	WSDATA   cvl_capacity              AS string OPTIONAL
	WSDATA   cvl_density               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Truck_box
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Truck_box
Return

WSMETHOD CLONE WSCLIENT Truck_box
	Local oClone := Truck_box():NEW()
	oClone:cnr_box              := ::cnr_box
	oClone:cvl_capacity         := ::cvl_capacity
	oClone:cvl_density          := ::cvl_density
Return oClone

WSMETHOD SOAPSEND WSCLIENT Truck_box
	Local cSoap := ""
	cSoap += WSSoapValue("nr_box", ::cnr_box, ::cnr_box , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("vl_capacity", ::cvl_capacity, ::cvl_capacity , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("vl_density", ::cvl_density, ::cvl_density , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


