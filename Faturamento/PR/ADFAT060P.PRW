#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://186.224.100.105:48884/WsGemba/Supplier.asmx?WSDL
Gerado em        19/07/22 13:39:19
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _QZIMOSK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSupplier
------------------------------------------------------------------------------- */

WSCLIENT WSSupplier

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Insert
	WSMETHOD Exists

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSsuppliers              AS Supplier_ArrayOfSupplier
	WSDATA   oWSInsertResult           AS Supplier_ArrayOfStatus
	WSDATA   cds_code_supplier         AS string
	WSDATA   oWSExistsResult           AS Supplier_ArrayOfStatus

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSupplier
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.210324P-20220312] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSupplier
	::oWSsuppliers       := Supplier_ARRAYOFSUPPLIER():New()
	::oWSInsertResult    := Supplier_ARRAYOFSTATUS():New()
	::oWSExistsResult    := Supplier_ARRAYOFSTATUS():New()
Return

WSMETHOD RESET WSCLIENT WSSupplier
	::oWSsuppliers       := NIL 
	::oWSInsertResult    := NIL 
	::cds_code_supplier  := NIL 
	::oWSExistsResult    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSupplier
Local oClone := WSSupplier():New()
	oClone:_URL          := ::_URL 
	oClone:oWSsuppliers  :=  IIF(::oWSsuppliers = NIL , NIL ,::oWSsuppliers:Clone() )
	oClone:oWSInsertResult :=  IIF(::oWSInsertResult = NIL , NIL ,::oWSInsertResult:Clone() )
	oClone:cds_code_supplier := ::cds_code_supplier
	oClone:oWSExistsResult :=  IIF(::oWSExistsResult = NIL , NIL ,::oWSExistsResult:Clone() )
Return oClone

// WSDL Method Insert of Service WSSupplier

WSMETHOD Insert WSSEND oWSsuppliers WSRECEIVE oWSInsertResult WSCLIENT WSSupplier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Insert xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("suppliers", ::oWSsuppliers, oWSsuppliers , "ArrayOfSupplier", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Insert>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Insert",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Supplier.asmx")

::Init()
::oWSInsertResult:SoapRecv( WSAdvValue( oXmlRet,"_INSERTRESPONSE:_INSERTRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Exists of Service WSSupplier

WSMETHOD Exists WSSEND cds_code_supplier WSRECEIVE oWSExistsResult WSCLIENT WSSupplier
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Exists xmlns="https://www.agpr5.com">'
cSoap += WSSoapValue("ds_code_supplier", ::cds_code_supplier, cds_code_supplier , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</Exists>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"https://www.agpr5.com/Exists",; 
	"DOCUMENT","https://www.agpr5.com",,,; 
	"http://186.224.100.105/WsGemba/Supplier.asmx")

::Init()
::oWSExistsResult:SoapRecv( WSAdvValue( oXmlRet,"_EXISTSRESPONSE:_EXISTSRESULT","ArrayOfStatus",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ArrayOfSupplier

WSSTRUCT Supplier_ArrayOfSupplier
	WSDATA   oWSsupplier               AS Supplier_supplier OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Supplier_ArrayOfSupplier
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Supplier_ArrayOfSupplier
	::oWSsupplier          := {} // Array Of  Supplier_SUPPLIER():New()
Return

WSMETHOD CLONE WSCLIENT Supplier_ArrayOfSupplier
	Local oClone := Supplier_ArrayOfSupplier():NEW()
	oClone:oWSsupplier := NIL
	If ::oWSsupplier <> NIL 
		oClone:oWSsupplier := {}
		aEval( ::oWSsupplier , { |x| aadd( oClone:oWSsupplier , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT Supplier_ArrayOfSupplier
	Local cSoap := ""
	aEval( ::oWSsupplier , {|x| cSoap := cSoap  +  WSSoapValue("supplier", x , x , "supplier", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfStatus

WSSTRUCT Supplier_ArrayOfStatus
	WSDATA   oWSStatus                 AS Supplier_Status OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Supplier_ArrayOfStatus
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Supplier_ArrayOfStatus
	::oWSStatus            := {} // Array Of  Supplier_STATUS():New()
Return

WSMETHOD CLONE WSCLIENT Supplier_ArrayOfStatus
	Local oClone := Supplier_ArrayOfStatus():NEW()
	oClone:oWSStatus := NIL
	If ::oWSStatus <> NIL 
		oClone:oWSStatus := {}
		aEval( ::oWSStatus , { |x| aadd( oClone:oWSStatus , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Supplier_ArrayOfStatus
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_STATUS","Status",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSStatus , Supplier_Status():New() )
			::oWSStatus[len(::oWSStatus)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure supplier

WSSTRUCT Supplier_supplier
	WSDATA   cds_code_supplier         AS string OPTIONAL
	WSDATA   cnm_supplier              AS string OPTIONAL
	WSDATA   cds_cnpj                  AS string OPTIONAL
	WSDATA   cds_cpf                   AS string OPTIONAL
	WSDATA   cds_address               AS string OPTIONAL
	WSDATA   cnr_phone                 AS string OPTIONAL
	WSDATA   cnr_cep                   AS string OPTIONAL
	WSDATA   cds_email                 AS string OPTIONAL
	WSDATA   cnm_city                  AS string OPTIONAL
	WSDATA   csg_state                 AS string OPTIONAL
	WSDATA   cnm_country               AS string OPTIONAL
	WSDATA   ccd_company_unit          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT Supplier_supplier
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Supplier_supplier
Return

WSMETHOD CLONE WSCLIENT Supplier_supplier
	Local oClone := Supplier_supplier():NEW()
	oClone:cds_code_supplier    := ::cds_code_supplier
	oClone:cnm_supplier         := ::cnm_supplier
	oClone:cds_cnpj             := ::cds_cnpj
	oClone:cds_cpf              := ::cds_cpf
	oClone:cds_address          := ::cds_address
	oClone:cnr_phone            := ::cnr_phone
	oClone:cnr_cep              := ::cnr_cep
	oClone:cds_email            := ::cds_email
	oClone:cnm_city             := ::cnm_city
	oClone:csg_state            := ::csg_state
	oClone:cnm_country          := ::cnm_country
	oClone:ccd_company_unit     := ::ccd_company_unit
Return oClone

WSMETHOD SOAPSEND WSCLIENT Supplier_supplier
	Local cSoap := ""
	cSoap += WSSoapValue("ds_code_supplier", ::cds_code_supplier, ::cds_code_supplier , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_supplier", ::cnm_supplier, ::cnm_supplier , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_cnpj", ::cds_cnpj, ::cds_cnpj , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_cpf", ::cds_cpf, ::cds_cpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_address", ::cds_address, ::cds_address , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_phone", ::cnr_phone, ::cnr_phone , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nr_cep", ::cnr_cep, ::cnr_cep , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ds_email", ::cds_email, ::cds_email , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_city", ::cnm_city, ::cnm_city , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("sg_state", ::csg_state, ::csg_state , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("nm_country", ::cnm_country, ::cnm_country , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("cd_company_unit", ::ccd_company_unit, ::ccd_company_unit , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure Status

WSSTRUCT Supplier_Status
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

WSMETHOD NEW WSCLIENT Supplier_Status
	::Init()
Return Self

WSMETHOD INIT WSCLIENT Supplier_Status
Return

WSMETHOD CLONE WSCLIENT Supplier_Status
	Local oClone := Supplier_Status():NEW()
	oClone:cstatusCode          := ::cstatusCode
	oClone:cidentification      := ::cidentification
	oClone:cdescription         := ::cdescription
	oClone:cname                := ::cname
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT Supplier_Status
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cstatusCode        :=  WSAdvValue( oResponse,"_STATUSCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cidentification    :=  WSAdvValue( oResponse,"_IDENTIFICATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cdescription       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cname              :=  WSAdvValue( oResponse,"_NAME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


